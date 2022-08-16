
//template <typename T>
//struct Converter {
//  static runtime::Value toScript(runtime::Context ctx, T& value);
//  static T toCpp(runtime::Context ctx, const runtime::Value& value, Bindings * bindings, std::vector<runtime::Value>& retainedValues);
//};

template <typename Object>
struct Converter {
  static runtime::Value toScript(runtime::Context ctx, Object * obj, Bindings * bindings) {
    auto privateData = new ViewPrivateData<Object>();
    privateData->view = obj;
    privateData->bindings = bindings;
//    privateData->ctx = ctx;

    obj->increaseReferenceCount(); // decreased in finalizer

    auto className = obj->instanceClassName();
    auto registeredClass = bindings->getRegisteredClass(className);

    auto object = JS_NewObjectClass(ctx, registeredClass.classId);
    JS_SetOpaque(object, privateData);
    JS_SetPrototype(ctx, object, registeredClass.prototype);
    JS_SetPropertyStr(ctx, object, "__className", JS_NewString(ctx, className.c_str()));

    return object;
  }
  static Object * toCpp(runtime::Context ctx, const runtime::Value& value, Bindings * bindings, std::vector<runtime::Value>& retainedValues) {
    auto className = Object::ClassName();
    auto registeredClass = bindings->getRegisteredClass(className);
    auto privateData = static_cast<ViewPrivateData<Object> *>(JS_GetOpaque(value, registeredClass.classId));
    auto obj = privateData->view;
    return obj;
  }
};

template <>
struct Converter<std::string> {
  static JSValue toScript(JSContext * ctx, std::string value, Bindings * bindings = nullptr) {
    return JS_NewString(ctx, value.c_str());
  }
  static std::string toCpp(JSContext * ctx, const JSValue str, Bindings * bindings, std::vector<JSValue>& retainedValues) {
    if (JS_IsString(str)) {
      return JS_ToCString(ctx, str);
    }
    return "";
  }
};

template <>
struct Converter<bool> {
  static JSValue toScript(JSContext * ctx, bool& value, Bindings * bindings = nullptr) {
    return JS_NewBool(ctx, value);
  }
  static bool toCpp(JSContext * ctx, const JSValue& value, Bindings * bindings, std::vector<JSValue>& retainedValues) {
    return JS_ToBool(ctx, value);
  }
};

template <>
struct Converter<int> {
  static JSValue toScript(JSContext * ctx, int& value, Bindings * bindings = nullptr) {
    return JS_NewInt32(ctx, value);
  }
  static int toCpp(JSContext * ctx, const JSValue& value, Bindings * bindings, std::vector<JSValue>& retainedValues) {
    int v;
    JS_ToInt32(ctx, &v, value);
    return v;
  }
};

template <>
struct Converter<float> {
  static JSValue toScript(JSContext * ctx, float value, Bindings * bindings = nullptr) {
    return JS_NewFloat64(ctx, value);
  }
  static float toCpp(JSContext * ctx, const JSValue& value, Bindings * bindings, std::vector<JSValue>& retainedValues) {
    double v;
    JS_ToFloat64(ctx, &v, value);
    return v;
  }
};

template <>
struct Converter<double> {
  static JSValue toScript(JSContext * ctx, double value, Bindings * bindings = nullptr) {
    return JS_NewFloat64(ctx, value);
  }
  static double toCpp(JSContext * ctx, const JSValue& value, Bindings * bindings, std::vector<JSValue>& retainedValues) {
    double v;
    JS_ToFloat64(ctx, &v, value);
    return v;
  }
};

template <typename FN>
class FunctionContainer : public rehaxUtils::Object<FunctionContainer<FN>> {
public:
  static std::string ClassName() {
    return typeid(FN).name();
  }
  std::string instanceClassName() {
    return typeid(FN).name();
  }
  FN fn;
};

template <>
struct Converter<std::function<void(void)>> {
  static JSValue toScript(JSContext * ctx, std::function<void(void)> value, Bindings * bindings = nullptr) {
    using ContainerFnType = FunctionContainer<std::function<void(void)>>;
    auto fnPtr = rehaxUtils::Object<ContainerFnType>::Create();
    fnPtr->fn = value;
    if (!bindings->hasRegisteredClass(ContainerFnType::ClassName())) {
      bindings->defineClass<ContainerFnType>(ContainerFnType::ClassName(), nullptr);
    }
    auto funData2 = Converter<ContainerFnType>::toScript(ctx, fnPtr.get(), bindings);
      
    auto funData1 = JS_NewObjectClass(ctx, kPointerClassId);
    JS_SetOpaque(funData1, bindings);

    std::array<JSValue, 2> funDataArray {
      funData1,
      funData2,
    };

    auto fn = JS_NewCFunctionData(
      ctx,
      [] (JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic, JSValue* func_data) {
        auto bindings = (Bindings *) JS_GetOpaque(func_data[0], kPointerClassId);
        auto fnPrivateData = static_cast<ViewPrivateData<ContainerFnType> *>(JS_GetOpaque(func_data[1], bindings->getRegisteredClass(ContainerFnType::ClassName()).classId));
          
        auto fnPtr = Converter<ContainerFnType>::toCpp(ctx, func_data[1], fnPrivateData->bindings, fnPrivateData->retainedValues);
        fnPtr->fn();
        return JS_UNDEFINED;
      },
      0, 0, funDataArray.size(), funDataArray.data()
    );

    for (auto v : funDataArray) {
      JS_FreeValue(ctx, v);
    }
    return fn;
  }
  static std::function<void(void)> toCpp(JSContext * ctx, const JSValue& value, Bindings * bindings, std::vector<JSValue>& retainedValues) {
    JSValue duped = JS_DupValue(ctx, value);
    retainedValues.push_back(duped);
    auto fn = [ctx, duped] () {
      JS_Call(ctx, duped, JS_NULL, 0, {});
    };
    return fn;
  }
};

template <typename T1>
struct Converter<std::function<void(T1)>> {
  static JSValue toScript(JSContext * ctx, std::function<void(T1)> value, Bindings * bindings = nullptr) {
    using FnType = std::function<void(T1)>;
    using ContainerFnType = FunctionContainer<FnType>;
    auto fnPtr = rehaxUtils::Object<ContainerFnType>::Create();
    fnPtr->fn = value;
    if (!bindings->hasRegisteredClass(ContainerFnType::ClassName())) {
      bindings->defineClass<ContainerFnType>(ContainerFnType::ClassName(), nullptr);
    }
    auto funData2 = Converter<ContainerFnType>::toScript(ctx, fnPtr.get(), bindings);
      
    auto funData1 = JS_NewObjectClass(ctx, kPointerClassId);
    JS_SetOpaque(funData1, bindings);

    std::array<JSValue, 2> funDataArray {
      funData1,
      funData2,
    };

    auto fn = JS_NewCFunctionData(
      ctx,
      [] (JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic, JSValue* func_data) {
        auto bindings = (Bindings *) JS_GetOpaque(func_data[0], kPointerClassId);
        auto fnPrivateData = static_cast<ViewPrivateData<ContainerFnType> *>(JS_GetOpaque(func_data[1], bindings->getRegisteredClass(ContainerFnType::ClassName()).classId));
          
        auto fnPtr = Converter<ContainerFnType>::toCpp(ctx, func_data[1], fnPrivateData->bindings, fnPrivateData->retainedValues);
        fnPtr->fn(
          Converter<T1>::toCpp(ctx, argv[0], bindings, fnPrivateData->retainedValues)
        );
        return JS_UNDEFINED;
      },
      0, 0, funDataArray.size(), funDataArray.data()
    );

    for (auto v : funDataArray) {
      JS_FreeValue(ctx, v);
    }
    return fn;
  }
  static std::function<void(T1)> toCpp(JSContext * ctx, const JSValue& value, Bindings * bindings, std::vector<JSValue>& retainedValues) {
    JSValue duped = JS_DupValue(ctx, value);
    retainedValues.push_back(duped);
    auto fn = [ctx, duped, bindings] (T1 x) {
      JSValue args[] = {
        Converter<T1>::toScript(ctx, x, bindings),
      };
      JS_Call(ctx, duped, JS_NULL, 1, args);
    };
    return fn;
  }
};

template <typename T1, typename T2>
struct Converter<std::function<void(T1, T2)>> {
  static JSValue toScript(JSContext * ctx, std::function<void(T1, T2)> value, Bindings * bindings = nullptr) {
    using FnType = std::function<void(T1, T2)>;
    using ContainerFnType = FunctionContainer<FnType>;
    auto fnPtr = rehaxUtils::Object<ContainerFnType>::Create();
    fnPtr->fn = value;
    if (!bindings->hasRegisteredClass(ContainerFnType::ClassName())) {
      bindings->defineClass<ContainerFnType>(ContainerFnType::ClassName(), nullptr);
    }
    auto funData2 = Converter<ContainerFnType>::toScript(ctx, fnPtr.get(), bindings);
      
    auto funData1 = JS_NewObjectClass(ctx, kPointerClassId);
    JS_SetOpaque(funData1, bindings);

    std::array<JSValue, 2> funDataArray {
      funData1,
      funData2,
    };

    auto fn = JS_NewCFunctionData(
      ctx,
      [] (JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic, JSValue* func_data) {
        auto bindings = (Bindings *) JS_GetOpaque(func_data[0], kPointerClassId);
        auto fnPrivateData = static_cast<ViewPrivateData<ContainerFnType> *>(JS_GetOpaque(func_data[1], bindings->getRegisteredClass(ContainerFnType::ClassName()).classId));
          
        auto fnPtr = Converter<ContainerFnType>::toCpp(ctx, func_data[1], fnPrivateData->bindings, fnPrivateData->retainedValues);
        fnPtr->fn(
          Converter<T1>::toCpp(ctx, argv[0], bindings, fnPrivateData->retainedValues),
          Converter<T2>::toCpp(ctx, argv[1], bindings, fnPrivateData->retainedValues)
        );
        return JS_UNDEFINED;
      },
      0, 0, funDataArray.size(), funDataArray.data()
    );

    for (auto v : funDataArray) {
      JS_FreeValue(ctx, v);
    }
    return fn;
  }
  static std::function<void(T1, T2)> toCpp(JSContext * ctx, const JSValue& value, Bindings * bindings, std::vector<JSValue>& retainedValues) {
    JSValue duped = JS_DupValue(ctx, value);
    retainedValues.push_back(duped);
    auto fn = [ctx, duped] (T1 a, T2 b) {
      JSValue args[] = {
        Converter<T1>::toScript(ctx, a),
        Converter<T2>::toScript(ctx, b),
      };
      JS_Call(ctx, duped, JS_NULL, 2, args);
    };
    return fn;
  }
};

template <typename T1, typename T2, typename T3>
struct Converter<std::function<void(T1, T2, T3)>> {
  static JSValue toScript(JSContext * ctx, std::function<void(T1, T2, T3)> value, Bindings * bindings = nullptr) {
    using FnType = std::function<void(T1, T2, T3)>;
    using ContainerFnType = FunctionContainer<FnType>;
    auto fnPtr = rehaxUtils::Object<ContainerFnType>::Create();
    fnPtr->fn = value;
    if (!bindings->hasRegisteredClass(ContainerFnType::ClassName())) {
      bindings->defineClass<ContainerFnType>(ContainerFnType::ClassName(), nullptr);
    }
    auto funData2 = Converter<ContainerFnType>::toScript(ctx, fnPtr.get(), bindings);
      
    auto funData1 = JS_NewObjectClass(ctx, kPointerClassId);
    JS_SetOpaque(funData1, bindings);

    std::array<JSValue, 2> funDataArray {
      funData1,
      funData2,
    };

    auto fn = JS_NewCFunctionData(
      ctx,
      [] (JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic, JSValue* func_data) {
        auto bindings = (Bindings *) JS_GetOpaque(func_data[0], kPointerClassId);
        auto fnPrivateData = static_cast<ViewPrivateData<ContainerFnType> *>(JS_GetOpaque(func_data[1], bindings->getRegisteredClass(ContainerFnType::ClassName()).classId));
          
        auto fnPtr = Converter<ContainerFnType>::toCpp(ctx, func_data[1], fnPrivateData->bindings, fnPrivateData->retainedValues);
        fnPtr->fn(
          Converter<T1>::toCpp(ctx, argv[0], bindings, fnPrivateData->retainedValues),
          Converter<T2>::toCpp(ctx, argv[1], bindings, fnPrivateData->retainedValues),
          Converter<T3>::toCpp(ctx, argv[2], bindings, fnPrivateData->retainedValues)
        );
        return JS_UNDEFINED;
      },
      0, 0, funDataArray.size(), funDataArray.data()
    );

    for (auto v : funDataArray) {
      JS_FreeValue(ctx, v);
    }
    return fn;
  }
  static std::function<void(T1, T2, T3)> toCpp(JSContext * ctx, const JSValue& value, Bindings * bindings, std::vector<JSValue>& retainedValues) {
    JSValue duped = JS_DupValue(ctx, value);
    retainedValues.push_back(duped);
    auto fn = [ctx, duped] (T1 a, T2 b, T3 c) {
      JSValue args[] = {
        Converter<T1>::toScript(ctx, a),
        Converter<T2>::toScript(ctx, b),
        Converter<T3>::toScript(ctx, c),
      };
      JS_Call(ctx, duped, JS_NULL, 3, args);
    };
    return fn;
  }
};

template <typename R1>
struct Converter<std::function<R1(void)>> {
  static JSValue toScript(JSContext * ctx, std::function<R1(void)> value, Bindings * bindings = nullptr) {
    using FnType = std::function<R1(void)>;
    using ContainerFnType = FunctionContainer<FnType>;
    auto fnPtr = rehaxUtils::Object<ContainerFnType>::Create();
    fnPtr->fn = value;
    if (!bindings->hasRegisteredClass(ContainerFnType::ClassName())) {
      bindings->defineClass<ContainerFnType>(ContainerFnType::ClassName(), nullptr);
    }
    auto funData2 = Converter<ContainerFnType>::toScript(ctx, fnPtr.get(), bindings);
      
    auto funData1 = JS_NewObjectClass(ctx, kPointerClassId);
    JS_SetOpaque(funData1, bindings);

    std::array<JSValue, 2> funDataArray {
      funData1,
      funData2,
    };

    auto fn = JS_NewCFunctionData(
      ctx,
      [] (JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic, JSValue* func_data) {
        auto bindings = (Bindings *) JS_GetOpaque(func_data[0], kPointerClassId);
        auto fnPrivateData = static_cast<ViewPrivateData<ContainerFnType> *>(JS_GetOpaque(func_data[1], bindings->getRegisteredClass(ContainerFnType::ClassName()).classId));
          
        auto fnPtr = Converter<ContainerFnType>::toCpp(ctx, func_data[1], fnPrivateData->bindings, fnPrivateData->retainedValues);
        auto ret = fnPtr->fn();
        return Converter<R1>::toScript(ctx, ret, bindings);
      },
      0, 0, funDataArray.size(), funDataArray.data()
    );

    for (auto v : funDataArray) {
      JS_FreeValue(ctx, v);
    }
    return fn;
  }
  static std::function<R1(void)> toCpp(JSContext * ctx, const JSValue& value, Bindings * bindings, std::vector<JSValue>& retainedValues) {
    JSValue duped = JS_DupValue(ctx, value);
    retainedValues.push_back(duped);
    auto fn = [ctx, duped, &bindings, &retainedValues] () {
      auto ret = JS_Call(ctx, duped, JS_NULL, 0, {});
      return Converter<R1>::toCpp(ctx, ret, bindings, retainedValues);
    };
    return fn;
  }
};

template <typename R1, typename T1>
struct Converter<std::function<R1(T1)>> {
  static JSValue toScript(JSContext * ctx, std::function<R1(T1)> value, Bindings * bindings = nullptr) {
    using FnType = std::function<R1(T1)>;
    using ContainerFnType = FunctionContainer<FnType>;
    auto fnPtr = rehaxUtils::Object<ContainerFnType>::Create();
    fnPtr->fn = value;
    if (!bindings->hasRegisteredClass(ContainerFnType::ClassName())) {
      bindings->defineClass<ContainerFnType>(ContainerFnType::ClassName(), nullptr);
    }
    auto funData2 = Converter<ContainerFnType>::toScript(ctx, fnPtr.get(), bindings);
      
    auto funData1 = JS_NewObjectClass(ctx, kPointerClassId);
    JS_SetOpaque(funData1, bindings);

    std::array<JSValue, 2> funDataArray {
      funData1,
      funData2,
    };

    auto fn = JS_NewCFunctionData(
      ctx,
      [] (JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic, JSValue* func_data) {
        auto bindings = (Bindings *) JS_GetOpaque(func_data[0], kPointerClassId);
        auto fnPrivateData = static_cast<ViewPrivateData<ContainerFnType> *>(JS_GetOpaque(func_data[1], bindings->getRegisteredClass(ContainerFnType::ClassName()).classId));
          
        auto fnPtr = Converter<ContainerFnType>::toCpp(ctx, func_data[1], fnPrivateData->bindings, fnPrivateData->retainedValues);
        auto ret = fnPtr->fn(
          Converter<T1>::toCpp(ctx, argv[0], bindings, fnPrivateData->retainedValues)
        );
        return Converter<R1>::toScript(ctx, ret, bindings);
      },
      0, 0, funDataArray.size(), funDataArray.data()
    );

    for (auto v : funDataArray) {
      JS_FreeValue(ctx, v);
    }
    return fn;
  }
  static std::function<R1(T1)> toCpp(JSContext * ctx, const JSValue& value, Bindings * bindings, std::vector<JSValue>& retainedValues) {
    JSValue duped = JS_DupValue(ctx, value);
    retainedValues.push_back(duped);
    auto fn = [ctx, duped, &bindings, &retainedValues] (T1 a) {
      JSValue args[] = {
        Converter<T1>::toScript(ctx, a),
      };
      auto ret = JS_Call(ctx, duped, JS_NULL, 1, args);
      return Converter<R1>::toCpp(ctx, ret, bindings, retainedValues);
    };
    return fn;
  }
};

template <typename R1, typename T1, typename T2>
struct Converter<std::function<R1(T1, T2)>> {
  static JSValue toScript(JSContext * ctx, std::function<R1(T1, T2)> value, Bindings * bindings = nullptr) {
    using FnType = std::function<R1(T1, T2)>;
    using ContainerFnType = FunctionContainer<FnType>;
    auto fnPtr = rehaxUtils::Object<ContainerFnType>::Create();
    fnPtr->fn = value;
    if (!bindings->hasRegisteredClass(ContainerFnType::ClassName())) {
      bindings->defineClass<ContainerFnType>(ContainerFnType::ClassName(), nullptr);
    }
    auto funData2 = Converter<ContainerFnType>::toScript(ctx, fnPtr.get(), bindings);
      
    auto funData1 = JS_NewObjectClass(ctx, kPointerClassId);
    JS_SetOpaque(funData1, bindings);

    std::array<JSValue, 2> funDataArray {
      funData1,
      funData2,
    };

    auto fn = JS_NewCFunctionData(
      ctx,
      [] (JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic, JSValue* func_data) {
        auto bindings = (Bindings *) JS_GetOpaque(func_data[0], kPointerClassId);
        auto fnPrivateData = static_cast<ViewPrivateData<ContainerFnType> *>(JS_GetOpaque(func_data[1], bindings->getRegisteredClass(ContainerFnType::ClassName()).classId));
          
        auto fnPtr = Converter<ContainerFnType>::toCpp(ctx, func_data[1], fnPrivateData->bindings, fnPrivateData->retainedValues);
        auto ret = fnPtr->fn(
          Converter<T1>::toCpp(ctx, argv[0], bindings, fnPrivateData->retainedValues),
          Converter<T2>::toCpp(ctx, argv[1], bindings, fnPrivateData->retainedValues)
        );
        return Converter<R1>::toScript(ctx, ret, bindings);
      },
      0, 0, funDataArray.size(), funDataArray.data()
    );

    for (auto v : funDataArray) {
      JS_FreeValue(ctx, v);
    }
    return fn;
  }
  static std::function<R1(T1, T2)> toCpp(JSContext * ctx, const JSValue& value, Bindings * bindings, std::vector<JSValue>& retainedValues) {
    JSValue duped = JS_DupValue(ctx, value);
    retainedValues.push_back(duped);
    auto fn = [ctx, duped, &bindings, &retainedValues] (T1 a, T2 b) {
      JSValue args[] = {
        Converter<T1>::toScript(ctx, a),
        Converter<T2>::toScript(ctx, b),
      };
      auto ret = JS_Call(ctx, duped, JS_NULL, 2, args);
      return Converter<R1>::toCpp(ctx, ret, bindings, retainedValues);
    };
    return fn;
  }
};

template <typename R1, typename T1, typename T2, typename T3>
struct Converter<std::function<R1(T1, T2, T3)>> {
  static JSValue toScript(JSContext * ctx, std::function<R1(T1, T2, T3)> value, Bindings * bindings = nullptr) {
    using FnType = std::function<R1(T1, T2, T3)>;
    using ContainerFnType = FunctionContainer<FnType>;
    auto fnPtr = rehaxUtils::Object<ContainerFnType>::Create();
    fnPtr->fn = value;
    if (!bindings->hasRegisteredClass(ContainerFnType::ClassName())) {
      bindings->defineClass<ContainerFnType>(ContainerFnType::ClassName(), nullptr);
    }
    auto funData2 = Converter<ContainerFnType>::toScript(ctx, fnPtr.get(), bindings);
      
    auto funData1 = JS_NewObjectClass(ctx, kPointerClassId);
    JS_SetOpaque(funData1, bindings);

    std::array<JSValue, 2> funDataArray {
      funData1,
      funData2,
    };

    auto fn = JS_NewCFunctionData(
      ctx,
      [] (JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic, JSValue* func_data) {
        auto bindings = (Bindings *) JS_GetOpaque(func_data[0], kPointerClassId);
        auto fnPrivateData = static_cast<ViewPrivateData<ContainerFnType> *>(JS_GetOpaque(func_data[1], bindings->getRegisteredClass(ContainerFnType::ClassName()).classId));
          
        auto fnPtr = Converter<ContainerFnType>::toCpp(ctx, func_data[1], fnPrivateData->bindings, fnPrivateData->retainedValues);
        auto ret = fnPtr->fn(
          Converter<T1>::toCpp(ctx, argv[0], bindings, fnPrivateData->retainedValues),
          Converter<T2>::toCpp(ctx, argv[1], bindings, fnPrivateData->retainedValues),
          Converter<T3>::toCpp(ctx, argv[2], bindings, fnPrivateData->retainedValues)
        );
        return Converter<R1>::toScript(ctx, ret, bindings);
      },
      0, 0, funDataArray.size(), funDataArray.data()
    );

    for (auto v : funDataArray) {
      JS_FreeValue(ctx, v);
    }
    return fn;
  }
  static std::function<R1(T1, T2, T3)> toCpp(JSContext * ctx, const JSValue& value, Bindings * bindings, std::vector<JSValue>& retainedValues) {
    JSValue duped = JS_DupValue(ctx, value);
    retainedValues.push_back(duped);
    auto fn = [ctx, duped, &bindings, &retainedValues] (T1 a, T2 b, T3 c) {
      JSValue args[] = {
        Converter<T1>::toScript(ctx, a),
        Converter<T2>::toScript(ctx, b),
        Converter<T3>::toScript(ctx, c),
      };
      auto ret = JS_Call(ctx, duped, JS_NULL, 3, args);
      return Converter<R1>::toCpp(ctx, ret, bindings, retainedValues);
    };
    return fn;
  }
};

#include "../common/converters.h"
