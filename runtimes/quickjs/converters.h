
//template <typename T>
//struct Converter {
//  static runtime::Value toScript(runtime::Context ctx, T& value);
//  static T toCpp(runtime::Context ctx, const runtime::Value& value, Bindings * bindings);
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
  static Object * toCpp(runtime::Context ctx, const runtime::Value& value, Bindings * bindings) {
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
  static std::string toCpp(JSContext * ctx, const JSValue str, Bindings * bindings) {
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
  static bool toCpp(JSContext * ctx, const JSValue& value, Bindings * bindings) {
    return JS_ToBool(ctx, value);
  }
};

template <>
struct Converter<int> {
  static JSValue toScript(JSContext * ctx, int& value, Bindings * bindings = nullptr) {
    return JS_NewInt32(ctx, value);
  }
  static int toCpp(JSContext * ctx, const JSValue& value, Bindings * bindings) {
    int v;
    JS_ToInt32(ctx, &v, value);
    return v;
  }
};

template <>
struct Converter<uint32_t> {
  static JSValue toScript(JSContext * ctx, uint32_t& value, Bindings * bindings = nullptr) {
    return JS_NewUint32(ctx, value);
  }
  static uint32_t toCpp(JSContext * ctx, const JSValue& value, Bindings * bindings) {
    uint32_t v;
    JS_ToUint32(ctx, &v, value);
    return v;
  }
};

template <>
struct Converter<size_t> {
  static JSValue toScript(JSContext * ctx, size_t& value, Bindings * bindings = nullptr) {
    return JS_NewInt64(ctx, value);
  }
  static size_t toCpp(JSContext * ctx, const JSValue& value, Bindings * bindings) {
//    size_t v;
    uint64_t v;
    JS_ToIndex(ctx, &v, value);
    return v;
  }
};

template <>
struct Converter<float> {
  static JSValue toScript(JSContext * ctx, float value, Bindings * bindings = nullptr) {
    return JS_NewFloat64(ctx, value);
  }
  static float toCpp(JSContext * ctx, const JSValue& value, Bindings * bindings) {
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
  static double toCpp(JSContext * ctx, const JSValue& value, Bindings * bindings) {
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

class ScriptFunctionContainer : public rehaxUtils::Object<ScriptFunctionContainer> {
public:
  ScriptFunctionContainer(JSContext * ctx, JSValue fn)
  :ctx(ctx), fn(JS_DupValue(ctx, fn)) {}

  ~ScriptFunctionContainer() {
    JS_FreeValue(ctx, fn);
  }
  JSValue call(JSContext * ctx, size_t numArgs, JSValue * args) {
    auto ret = JS_Call(ctx, fn, JS_NULL, numArgs, args);
    return ret;
  }
private:
  JSContext * ctx;
  JSValue fn;
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
          
        auto fnPtr = Converter<ContainerFnType>::toCpp(ctx, func_data[1], fnPrivateData->bindings);
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
  static std::function<void(void)> toCpp(JSContext * ctx, const JSValue& value, Bindings * bindings) {
    rehaxUtils::ObjectPointer<ScriptFunctionContainer> fnPtr = rehaxUtils::Object<ScriptFunctionContainer>::Create(ctx, value);
    auto fn = [ctx, fnPtr] () {
      fnPtr->call(ctx, 0, {});
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
          
        auto fnPtr = Converter<ContainerFnType>::toCpp(ctx, func_data[1], fnPrivateData->bindings);
        fnPtr->fn(
          Converter<T1>::toCpp(ctx, argv[0], bindings)
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
  static std::function<void(T1)> toCpp(JSContext * ctx, const JSValue& value, Bindings * bindings) {
    rehaxUtils::ObjectPointer<ScriptFunctionContainer> fnPtr = rehaxUtils::Object<ScriptFunctionContainer>::Create(ctx, value);
    auto fn = [ctx, fnPtr, bindings] (T1 x) {
      JSValue args[] = {
        Converter<T1>::toScript(ctx, x, bindings),
      };
      fnPtr->call(ctx, 1, args);
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
          
        auto fnPtr = Converter<ContainerFnType>::toCpp(ctx, func_data[1], fnPrivateData->bindings);
        fnPtr->fn(
          Converter<T1>::toCpp(ctx, argv[0], bindings),
          Converter<T2>::toCpp(ctx, argv[1], bindings)
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
  static std::function<void(T1, T2)> toCpp(JSContext * ctx, const JSValue& value, Bindings * bindings) {
    rehaxUtils::ObjectPointer<ScriptFunctionContainer> fnPtr = rehaxUtils::Object<ScriptFunctionContainer>::Create(ctx, value);
    auto fn = [ctx, bindings, fnPtr] (T1 a, T2 b) {
      JSValue args[] = {
        Converter<T1>::toScript(ctx, a, bindings),
        Converter<T2>::toScript(ctx, b, bindings),
      };
      fnPtr->call(ctx, 2, args);
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
          
        auto fnPtr = Converter<ContainerFnType>::toCpp(ctx, func_data[1], fnPrivateData->bindings);
        fnPtr->fn(
          Converter<T1>::toCpp(ctx, argv[0], bindings),
          Converter<T2>::toCpp(ctx, argv[1], bindings),
          Converter<T3>::toCpp(ctx, argv[2], bindings)
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
  static std::function<void(T1, T2, T3)> toCpp(JSContext * ctx, const JSValue& value, Bindings * bindings) {
    rehaxUtils::ObjectPointer<ScriptFunctionContainer> fnPtr = rehaxUtils::Object<ScriptFunctionContainer>::Create(ctx, value);
    auto fn = [ctx, fnPtr] (T1 a, T2 b, T3 c) {
      JSValue args[] = {
        Converter<T1>::toScript(ctx, a),
        Converter<T2>::toScript(ctx, b),
        Converter<T3>::toScript(ctx, c),
      };
      fnPtr->call(ctx, 3, args);
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
          
        auto fnPtr = Converter<ContainerFnType>::toCpp(ctx, func_data[1], fnPrivateData->bindings);
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
  static std::function<R1(void)> toCpp(JSContext * ctx, const JSValue& value, Bindings * bindings) {
    rehaxUtils::ObjectPointer<ScriptFunctionContainer> fnPtr = rehaxUtils::Object<ScriptFunctionContainer>::Create(ctx, value);
    auto fn = [ctx, fnPtr, &bindings] () {
      auto ret = fnPtr->call(ctx, 0, {});
      return Converter<R1>::toCpp(ctx, ret, bindings);
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
          
        auto fnPtr = Converter<ContainerFnType>::toCpp(ctx, func_data[1], fnPrivateData->bindings);
        auto ret = fnPtr->fn(
          Converter<T1>::toCpp(ctx, argv[0], bindings)
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
  static std::function<R1(T1)> toCpp(JSContext * ctx, const JSValue& value, Bindings * bindings) {
    rehaxUtils::ObjectPointer<ScriptFunctionContainer> fnPtr = rehaxUtils::Object<ScriptFunctionContainer>::Create(ctx, value);
    auto fn = [ctx, fnPtr, &bindings] (T1 a) {
      JSValue args[] = {
        Converter<T1>::toScript(ctx, a),
      };
      auto ret = fnPtr->call(ctx, 1, args);
      return Converter<R1>::toCpp(ctx, ret, bindings);
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
          
        auto fnPtr = Converter<ContainerFnType>::toCpp(ctx, func_data[1], fnPrivateData->bindings);
        auto ret = fnPtr->fn(
          Converter<T1>::toCpp(ctx, argv[0], bindings),
          Converter<T2>::toCpp(ctx, argv[1], bindings)
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
  static std::function<R1(T1, T2)> toCpp(JSContext * ctx, const JSValue& value, Bindings * bindings) {
    rehaxUtils::ObjectPointer<ScriptFunctionContainer> fnPtr = rehaxUtils::Object<ScriptFunctionContainer>::Create(ctx, value);
    auto fn = [ctx, fnPtr, &bindings] (T1 a, T2 b) {
      JSValue args[] = {
        Converter<T1>::toScript(ctx, a),
        Converter<T2>::toScript(ctx, b),
      };
      auto ret = fnPtr->call(ctx, 2, args);
      return Converter<R1>::toCpp(ctx, ret, bindings);
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
          
        auto fnPtr = Converter<ContainerFnType>::toCpp(ctx, func_data[1], fnPrivateData->bindings);
        auto ret = fnPtr->fn(
          Converter<T1>::toCpp(ctx, argv[0], bindings),
          Converter<T2>::toCpp(ctx, argv[1], bindings),
          Converter<T3>::toCpp(ctx, argv[2], bindings)
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
  static std::function<R1(T1, T2, T3)> toCpp(JSContext * ctx, const JSValue& value, Bindings * bindings) {
    rehaxUtils::ObjectPointer<ScriptFunctionContainer> fnPtr = rehaxUtils::Object<ScriptFunctionContainer>::Create(ctx, value);
    auto fn = [ctx, fnPtr, &bindings] (T1 a, T2 b, T3 c) {
      JSValue args[] = {
        Converter<T1>::toScript(ctx, a),
        Converter<T2>::toScript(ctx, b),
        Converter<T3>::toScript(ctx, c),
      };
      auto ret = fnPtr->call(ctx, 3, args);
      return Converter<R1>::toCpp(ctx, ret, bindings);
    };
    return fn;
  }
};

#include "../common/converters.h"
