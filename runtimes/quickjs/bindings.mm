#include "./bindings.h"
#include <array>

namespace rehax {
namespace quickjs {


namespace runtime {

typedef ::JSContext * Context;
typedef ::JSValue Value;

Value MakeObject(Context ctx) {
  auto object = JS_NewObject(ctx);
  return object;
}

Value MakeArray(Context ctx) {
  auto object = JS_NewArray(ctx);
  return object;
}

void SetObjectProperty(Context ctx, Value object, std::string property, Value value) {
  JS_SetPropertyStr(ctx, object, property.c_str(), value);
}

Value GetObjectProperty(Context ctx, Value object, std::string property) {
  return JS_GetPropertyStr(ctx, object, property.c_str());
}

bool HasObjectProperty(Context ctx, Value object, std::string property) {
  return JS_HasProperty(ctx, object, JS_NewAtom(ctx, property.c_str()));
}

void SetArrayValue(Context ctx, Value object, int index, Value value) {
  JS_SetPropertyInt64(ctx, object, index, value);
}

Value GetArrayValue(Context ctx, Value object, int index) {
  return JS_GetPropertyUint32(ctx, object, index);
}

}


template <typename T>
struct Converter {
  static JSValue toScript(JSContext * ctx, T& value);
  static T toCpp(JSContext * ctx, const JSValue& value, Bindings * bindings, std::vector<JSValue>& retainedValues);
};

template <>
struct Converter<std::string> {
  static JSValue toScript(JSContext * ctx, std::string value) {
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
  static JSValue toScript(JSContext * ctx, bool& value) {
    return JS_NewBool(ctx, value);
  }
  static bool toCpp(JSContext * ctx, const JSValue& value, Bindings * bindings, std::vector<JSValue>& retainedValues) {
    return JS_ToBool(ctx, value);
  }
};

template <>
struct Converter<int> {
  static JSValue toScript(JSContext * ctx, int& value) {
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
  static JSValue toScript(JSContext * ctx, float value) {
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
  static JSValue toScript(JSContext * ctx, double value) {
    return JS_NewFloat64(ctx, value);
  }
  static double toCpp(JSContext * ctx, const JSValue& value, Bindings * bindings, std::vector<JSValue>& retainedValues) {
    double v;
    JS_ToFloat64(ctx, &v, value);
    return v;
  }
};

template <>
struct Converter<std::function<void(void)>> {
  static JSValue toScript(JSContext * ctx, std::function<void(void)>&& value) {
      // TODO
      return JS_UNDEFINED;
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

template <>
struct Converter<std::function<void(float, float)>> {
  static JSValue toScript(JSContext * ctx, std::function<void(float, float)>&& value) {
      // TODO
      return JS_UNDEFINED;
  }
  static std::function<void(float, float)> toCpp(JSContext * ctx, const JSValue& value, Bindings * bindings, std::vector<JSValue>& retainedValues) {
    JSValue duped = JS_DupValue(ctx, value);
    retainedValues.push_back(duped);
    auto fn = [ctx, duped] (float x, float y) {
      JSValue args[] = {
        Converter<float>::toScript(ctx, x),
        Converter<float>::toScript(ctx, y),
      };
      JS_Call(ctx, duped, JS_NULL, 2, args);
    };
    return fn;
  }
};

#include "../common/converters.h"

Bindings::Bindings() {}

void finalizeViewInstance(JSRuntime *rt, JSValue val) {
  auto bindings = static_cast<Bindings*>(JS_GetRuntimeOpaque(rt));
  auto privateData = static_cast<ViewPrivateData<rehax::ui::fluxe::impl::View> *>(JS_GetOpaque(val, bindings->instanceClassId));
  auto ctx = privateData->context;
  for (auto value : privateData->retainedValues) {
    JS_FreeValue(ctx, value);
  }
   std::cout << "GC" << std::endl;
  auto view = privateData->view;
  view->decreaseReferenceCount();
  delete privateData;
}

void Bindings::setContext(JSContext * ctx, JSRuntime * runtime) {
  this->ctx = ctx;
  this->rt = runtime;
  JS_SetRuntimeOpaque(rt, this);
    
  JS_NewClassID(&instanceClassId);
  JSClassDef classDef;
  classDef.class_name = "ViewInstance";
  classDef.finalizer = finalizeViewInstance;
  auto classId = JS_NewClass(runtime, instanceClassId, &classDef);
  instanceClassId = classId;
}

RegisteredClass Bindings::getRegisteredClass(std::string name) {
  return classRegistry[name];
}


template <typename View>
JSValue cppToJs(JSContext * ctx, Bindings * bindings, View * obj) {
  auto privateData = new ViewPrivateData<View>();
  privateData->view = obj;
  privateData->bindings = bindings;
  privateData->context = ctx;

  auto className = obj->instanceClassName();
  auto classDefine = bindings->getRegisteredClass(className);

  obj->increaseReferenceCount(); // decreased in finalizer

  auto object = JS_NewObjectClass(ctx, bindings->instanceClassId);
  JS_SetOpaque(object, privateData);
  JS_SetPrototype(ctx, object, classDefine.prototype);
  JS_SetPropertyStr(ctx, object, "__className", JS_NewAtomString(ctx, className.c_str()));
  return object;
}

template <typename View>
void Bindings::defineViewClass(JSContext * ctx, std::string name, JSValue parentPrototype) {
  auto prototypeObject = JS_NewObjectClass(ctx, kPrototypeClassId);
  if (!JS_IsNull(parentPrototype)) {
    JS_SetPrototype(ctx, prototypeObject, parentPrototype);
  }

  classRegistry[name] = RegisteredClass {};
  classRegistry[name].name = name;
  classRegistry[name].prototype = prototypeObject;
  
  auto funData = JS_NewObjectClass(ctx, kPointerClassId);
  JS_SetOpaque(funData, this);
  
  std::array<JSValue, 1> funDataArray {
    funData
  };

  auto classObject = JS_NewCFunctionData(
    ctx,
    [] (JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic, JSValue* func_data) {
      auto bindings = (Bindings *) JS_GetOpaque(func_data[0], kPointerClassId);
      auto view = View::Create();
      return ::rehax::quickjs::cppToJs(ctx, bindings, view.get());
    },
    0, 0, funDataArray.size(), funDataArray.data()
  );

  for (auto v : funDataArray) {
    JS_FreeValue(ctx, v);
  }
  
  JS_SetConstructorBit(ctx, classObject, true);
  auto globalContext = JS_GetGlobalObject(ctx);
  JS_SetPropertyStr(ctx, globalContext, name.c_str(), classObject);
}

template <typename View, typename RET, RET (View::*Method)(void)>
void bindMethod(std::string name, JSContext * ctx, Bindings *bindings, JSValue prototype) {
  auto funData = JS_NewObjectClass(ctx, kPointerClassId);
  JS_SetOpaque(funData, bindings);
  std::array<JSValue, 1> funDataArray {
    funData
  };
  auto call = [] (JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic, JSValue* func_data) {
    auto bindings = (Bindings *) JS_GetOpaque(func_data[0], kPointerClassId);
    auto privateData = static_cast<ViewPrivateData<View> *>(JS_GetOpaque(this_val, bindings->instanceClassId));
    View * view = privateData->view;
    auto ret = (view->*Method)();
    return Converter<RET>::toScript(ctx, ret);
  };

  auto functionObject = JS_NewCFunctionData(ctx, call, 0, 0, funDataArray.size(), funDataArray.data());
  JS_SetPropertyStr(ctx, prototype, name.c_str(), functionObject);
  for (auto v : funDataArray) {
    JS_FreeValue(ctx, v);
  }
}

template <typename View, void (View::*Method)(void)>
void bindMethod(std::string name, JSContext * ctx, Bindings *bindings, JSValue prototype) {
  auto funData = JS_NewObjectClass(ctx, kPointerClassId);
  JS_SetOpaque(funData, bindings);
  std::array<JSValue, 1> funDataArray {
    funData
  };
  auto call = [] (JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic, JSValue* func_data) {
    auto bindings = (Bindings *) JS_GetOpaque(func_data[0], kPointerClassId);
    auto privateData = static_cast<ViewPrivateData<View> *>(JS_GetOpaque(this_val, bindings->instanceClassId));
    View * view = privateData->view;
    (view->*Method)();
    return JS_UNDEFINED;
  };

  auto functionObject = JS_NewCFunctionData(ctx, call, 0, 0, funDataArray.size(), funDataArray.data());
  JS_SetPropertyStr(ctx, prototype, name.c_str(), functionObject);
  for (auto v : funDataArray) {
    JS_FreeValue(ctx, v);
  }
}

template <typename View, typename T1, void (View::*Method)(T1)>
void bindMethod(std::string name, JSContext * ctx, Bindings *bindings, JSValue prototype) {
  auto funData = JS_NewObjectClass(ctx, kPointerClassId);
  JS_SetOpaque(funData, bindings);
  std::array<JSValue, 1> funDataArray {
    funData
  };
  auto call = [] (JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic, JSValue* func_data) {
    auto bindings = (Bindings *) JS_GetOpaque(func_data[0], kPointerClassId);
    auto privateData = static_cast<ViewPrivateData<View> *>(JS_GetOpaque(this_val, bindings->instanceClassId));
    View * view = privateData->view;
    (view->*Method)(
      Converter<T1>::toCpp(ctx, argv[0], bindings, privateData->retainedValues)
    );
    return JS_UNDEFINED;
  };

  auto functionObject = JS_NewCFunctionData(ctx, call, 0, 0, funDataArray.size(), funDataArray.data());
  JS_SetPropertyStr(ctx, prototype, name.c_str(), functionObject);
  for (auto v : funDataArray) {
    JS_FreeValue(ctx, v);
  }
}

template <typename View, typename T1, typename T2, void (View::*Method)(T1, T2)>
void bindMethod(std::string name, JSContext * ctx, Bindings *bindings, JSValue prototype) {
  auto funData = JS_NewObjectClass(ctx, kPointerClassId);
  JS_SetOpaque(funData, bindings);
  std::array<JSValue, 1> funDataArray {
    funData
  };
  auto call = [] (JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic, JSValue* func_data) {
    auto bindings = (Bindings *) JS_GetOpaque(func_data[0], kPointerClassId);
    auto privateData = static_cast<ViewPrivateData<View> *>(JS_GetOpaque(this_val, bindings->instanceClassId));
    View * view = privateData->view;
    (view->*Method)(
      Converter<T1>::toCpp(ctx, argv[0], bindings, privateData->retainedValues),
      Converter<T2>::toCpp(ctx, argv[1], bindings, privateData->retainedValues)
    );
    return JS_UNDEFINED;
  };

  auto functionObject = JS_NewCFunctionData(ctx, call, 0, 0, funDataArray.size(), funDataArray.data());
  JS_SetPropertyStr(ctx, prototype, name.c_str(), functionObject);
  for (auto v : funDataArray) {
    JS_FreeValue(ctx, v);
  }
}

template <typename View, typename T1, typename T2, typename T3, void (View::*Method)(T1, T2, T3)>
void bindMethod(std::string name, JSContext * ctx, Bindings *bindings, JSValue prototype) {
  auto funData = JS_NewObjectClass(ctx, kPointerClassId);
  JS_SetOpaque(funData, bindings);
  std::array<JSValue, 1> funDataArray {
    funData
  };
  auto call = [] (JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic, JSValue* func_data) {
    auto bindings = (Bindings *) JS_GetOpaque(func_data[0], kPointerClassId);
    auto privateData = static_cast<ViewPrivateData<View> *>(JS_GetOpaque(this_val, bindings->instanceClassId));
    View * view = privateData->view;
    (view->*Method)(
      Converter<T1>::toCpp(ctx, argv[0], bindings, privateData->retainedValues),
      Converter<T2>::toCpp(ctx, argv[1], bindings, privateData->retainedValues),
      Converter<T3>::toCpp(ctx, argv[2], bindings, privateData->retainedValues)
    );
    return JS_UNDEFINED;
  };

  auto functionObject = JS_NewCFunctionData(ctx, call, 0, 0, funDataArray.size(), funDataArray.data());
  JS_SetPropertyStr(ctx, prototype, name.c_str(), functionObject);
  for (auto v : funDataArray) {
    JS_FreeValue(ctx, v);
  }
}

template <typename View, typename T1, typename T2, typename T3, typename T4, void (View::*Method)(T1, T2, T3, T4)>
void bindMethod(std::string name, JSContext * ctx, Bindings *bindings, JSValue prototype) {
  auto funData = JS_NewObjectClass(ctx, kPointerClassId);
  JS_SetOpaque(funData, bindings);
  std::array<JSValue, 1> funDataArray {
    funData
  };
  auto call = [] (JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic, JSValue* func_data) {
    auto bindings = (Bindings *) JS_GetOpaque(func_data[0], kPointerClassId);
    auto privateData = static_cast<ViewPrivateData<View> *>(JS_GetOpaque(this_val, bindings->instanceClassId));
    View * view = privateData->view;
    (view->*Method)(
      Converter<T1>::toCpp(ctx, argv[0], bindings, privateData->retainedValues),
      Converter<T2>::toCpp(ctx, argv[1], bindings, privateData->retainedValues),
      Converter<T3>::toCpp(ctx, argv[2], bindings, privateData->retainedValues),
      Converter<T4>::toCpp(ctx, argv[3], bindings, privateData->retainedValues)
    );
    return JS_UNDEFINED;
  };

  auto functionObject = JS_NewCFunctionData(ctx, call, 0, 0, funDataArray.size(), funDataArray.data());
  JS_SetPropertyStr(ctx, prototype, name.c_str(), functionObject);
  for (auto v : funDataArray) {
    JS_FreeValue(ctx, v);
  }
}

template <typename View, typename T1, typename T2, typename T3, typename T4, typename T5, void (View::*Method)(T1, T2, T3, T4, T5)>
void bindMethod(std::string name, JSContext * ctx, Bindings *bindings, JSValue prototype) {
  auto funData = JS_NewObjectClass(ctx, kPointerClassId);
  JS_SetOpaque(funData, bindings);
  std::array<JSValue, 1> funDataArray {
    funData
  };
  auto call = [] (JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic, JSValue* func_data) {
    auto bindings = (Bindings *) JS_GetOpaque(func_data[0], kPointerClassId);
    auto privateData = static_cast<ViewPrivateData<View> *>(JS_GetOpaque(this_val, bindings->instanceClassId));
    View * view = privateData->view;
    (view->*Method)(
      Converter<T1>::toCpp(ctx, argv[0], bindings, privateData->retainedValues),
      Converter<T2>::toCpp(ctx, argv[1], bindings, privateData->retainedValues),
      Converter<T3>::toCpp(ctx, argv[2], bindings, privateData->retainedValues),
      Converter<T4>::toCpp(ctx, argv[3], bindings, privateData->retainedValues),
      Converter<T5>::toCpp(ctx, argv[4], bindings, privateData->retainedValues)
    );
    return JS_UNDEFINED;
  };

  auto functionObject = JS_NewCFunctionData(ctx, call, 0, 0, funDataArray.size(), funDataArray.data());
  JS_SetPropertyStr(ctx, prototype, name.c_str(), functionObject);
  for (auto v : funDataArray) {
    JS_FreeValue(ctx, v);
  }
}

template <typename View, typename T1, typename T2, typename T3, typename T4, typename T5, typename T6, void (View::*Method)(T1, T2, T3, T4, T5, T6)>
void bindMethod(std::string name, JSContext * ctx, Bindings *bindings, JSValue prototype) {
  auto funData = JS_NewObjectClass(ctx, kPointerClassId);
  JS_SetOpaque(funData, bindings);
  std::array<JSValue, 1> funDataArray {
    funData
  };
  auto call = [] (JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic, JSValue* func_data) {
    auto bindings = (Bindings *) JS_GetOpaque(func_data[0], kPointerClassId);
    auto privateData = static_cast<ViewPrivateData<View> *>(JS_GetOpaque(this_val, bindings->instanceClassId));
    View * view = privateData->view;
    (view->*Method)(
      Converter<T1>::toCpp(ctx, argv[0], bindings, privateData->retainedValues),
      Converter<T2>::toCpp(ctx, argv[1], bindings, privateData->retainedValues),
      Converter<T3>::toCpp(ctx, argv[2], bindings, privateData->retainedValues),
      Converter<T4>::toCpp(ctx, argv[3], bindings, privateData->retainedValues),
      Converter<T5>::toCpp(ctx, argv[4], bindings, privateData->retainedValues),
      Converter<T6>::toCpp(ctx, argv[5], bindings, privateData->retainedValues)
    );
    return JS_UNDEFINED;
  };

  auto functionObject = JS_NewCFunctionData(ctx, call, 0, 0, funDataArray.size(), funDataArray.data());
  JS_SetPropertyStr(ctx, prototype, name.c_str(), functionObject);
  for (auto v : funDataArray) {
    JS_FreeValue(ctx, v);
  }
}

template <typename View, typename T1, typename T2, typename T3, typename T4, typename T5, typename T6, typename T7, void (View::*Method)(T1, T2, T3, T4, T5, T6, T7)>
void bindMethod(std::string name, JSContext * ctx, Bindings *bindings, JSValue prototype) {
  auto funData = JS_NewObjectClass(ctx, kPointerClassId);
  JS_SetOpaque(funData, bindings);
  std::array<JSValue, 1> funDataArray {
    funData
  };
  auto call = [] (JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic, JSValue* func_data) {
    auto bindings = (Bindings *) JS_GetOpaque(func_data[0], kPointerClassId);
    auto privateData = static_cast<ViewPrivateData<View> *>(JS_GetOpaque(this_val, bindings->instanceClassId));
    View * view = privateData->view;
    (view->*Method)(
      Converter<T1>::toCpp(ctx, argv[0], bindings, privateData->retainedValues),
      Converter<T2>::toCpp(ctx, argv[1], bindings, privateData->retainedValues),
      Converter<T3>::toCpp(ctx, argv[2], bindings, privateData->retainedValues),
      Converter<T4>::toCpp(ctx, argv[3], bindings, privateData->retainedValues),
      Converter<T5>::toCpp(ctx, argv[4], bindings, privateData->retainedValues),
      Converter<T6>::toCpp(ctx, argv[5], bindings, privateData->retainedValues),
      Converter<T7>::toCpp(ctx, argv[6], bindings, privateData->retainedValues)
    );
    return JS_UNDEFINED;
  };

  auto functionObject = JS_NewCFunctionData(ctx, call, 0, 0, funDataArray.size(), funDataArray.data());
  JS_SetPropertyStr(ctx, prototype, name.c_str(), functionObject);
  for (auto v : funDataArray) {
    JS_FreeValue(ctx, v);
  }
}

template <typename View, typename Layout, typename Gesture>
void bindViewClassMethods(JSContext * ctx, Bindings *bindings, JSValue prototype) {
  bindMethod<View, std::string, &View::description>("toString", ctx, bindings, prototype);
  bindMethod<View, &View::removeFromParent>("removeFromParent", ctx, bindings, prototype);
  bindMethod<View, float, &View::setWidthFixed>("setWidthFixed", ctx, bindings, prototype);
  bindMethod<View, float, &View::setHeightFixed>("setHeightFixed", ctx, bindings, prototype);
  bindMethod<View, float, &View::setWidthPercentage>("setWidthPercentage", ctx, bindings, prototype);
  bindMethod<View, float, &View::setWidthPercentage>("setWidthPercentage", ctx, bindings, prototype);
  bindMethod<View, &View::layout>("layout", ctx, bindings, prototype);
    
  {
    auto funData = JS_NewObjectClass(ctx, kPointerClassId);
    JS_SetOpaque(funData, bindings);
    std::array<JSValue, 1> funDataArray {
      funData
    };
    auto call = [] (JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic, JSValue* func_data) {
      auto bindings = (Bindings *) JS_GetOpaque(func_data[0], kPointerClassId);
      auto privateData = static_cast<ViewPrivateData<View> *>(JS_GetOpaque(this_val, bindings->instanceClassId));
      View * view = privateData->view;

      auto childPrivateData = static_cast<ViewPrivateData<View> *>(JS_GetOpaque(argv[0], bindings->instanceClassId));
      View * childView = childPrivateData->view;
      
      if (argc <= 1 || JS_IsNull(argv[1]) || JS_IsUndefined(argv[1])) {
        view->addView(childView);
      } else {
        auto beforeViewPrivateData = static_cast<ViewPrivateData<View> *>(JS_GetOpaque(argv[1], bindings->instanceClassId));
        View * beforeView = beforeViewPrivateData->view;
        view->addView(childView, beforeView);
      }
      return JS_UNDEFINED;
    };

    auto functionObject = JS_NewCFunctionData(ctx, call, 0, 0, funDataArray.size(), funDataArray.data());
    JS_SetPropertyStr(ctx, prototype, "addView", functionObject);
    for (auto v : funDataArray) {
      JS_FreeValue(ctx, v);
    }
  }
  {
    auto funData = JS_NewObjectClass(ctx, kPointerClassId);
    JS_SetOpaque(funData, bindings);
    std::array<JSValue, 1> funDataArray {
      funData
    };
    auto call = [] (JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic, JSValue* func_data) {
      auto bindings = (Bindings *) JS_GetOpaque(func_data[0], kPointerClassId);
      auto privateData = static_cast<ViewPrivateData<View> *>(JS_GetOpaque(this_val, bindings->instanceClassId));
      View * view = privateData->view;

      auto childPrivateData = static_cast<ViewPrivateData<View> *>(JS_GetOpaque(argv[0], bindings->instanceClassId));
      View * childView = childPrivateData->view;
      view->removeView(childView);
      return JS_UNDEFINED;
    };

    auto functionObject = JS_NewCFunctionData(ctx, call, 0, 0, funDataArray.size(), funDataArray.data());
    JS_SetPropertyStr(ctx, prototype, "removeView", functionObject);
    for (auto v : funDataArray) {
      JS_FreeValue(ctx, v);
    }
  }
  {
    auto funData = JS_NewObjectClass(ctx, kPointerClassId);
    JS_SetOpaque(funData, bindings);
    std::array<JSValue, 1> funDataArray {
      funData
    };
    auto call = [] (JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic, JSValue* func_data) {
      auto bindings = (Bindings *) JS_GetOpaque(func_data[0], kPointerClassId);
      auto privateData = static_cast<ViewPrivateData<View> *>(JS_GetOpaque(this_val, bindings->instanceClassId));
      View * view = privateData->view;

      auto parent = view->getParent();
      if (!parent.isValid()) {
        return JS_NULL;
      }
        
      View * parentView = dynamic_cast<View *>(parent.get());
      auto jsParent = ::rehax::quickjs::cppToJs(ctx, privateData->bindings, parentView);
      return jsParent;
    };

    auto functionObject = JS_NewCFunctionData(ctx, call, 0, 0, funDataArray.size(), funDataArray.data());
    JS_SetPropertyStr(ctx, prototype, "getParent", functionObject);
    for (auto v : funDataArray) {
      JS_FreeValue(ctx, v);
    }
  }
  {
    auto funData = JS_NewObjectClass(ctx, kPointerClassId);
    JS_SetOpaque(funData, bindings);
    std::array<JSValue, 1> funDataArray {
      funData
    };
    auto call = [] (JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic, JSValue* func_data) {
      auto bindings = (Bindings *) JS_GetOpaque(func_data[0], kPointerClassId);
      auto privateData = static_cast<ViewPrivateData<View> *>(JS_GetOpaque(this_val, bindings->instanceClassId));
      View * view = privateData->view;
      auto children = view->getChildren();
      auto firstChild = * children.begin();
      View * firstChildView = dynamic_cast<View *>(firstChild);
      return ::rehax::quickjs::cppToJs(ctx, privateData->bindings, firstChildView);
    };

    auto functionObject = JS_NewCFunctionData(ctx, call, 0, 0, funDataArray.size(), funDataArray.data());
    JS_SetPropertyStr(ctx, prototype, "getFirstChild", functionObject);
    for (auto v : funDataArray) {
      JS_FreeValue(ctx, v);
    }
  }
  {
    auto funData = JS_NewObjectClass(ctx, kPointerClassId);
    JS_SetOpaque(funData, bindings);
    std::array<JSValue, 1> funDataArray {
      funData
    };
    auto call = [] (JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic, JSValue* func_data) {
      auto bindings = (Bindings *) JS_GetOpaque(func_data[0], kPointerClassId);
      auto privateData = static_cast<ViewPrivateData<View> *>(JS_GetOpaque(this_val, bindings->instanceClassId));
      View * view = privateData->view;
    // TODO this should probably be moved to the core
      auto parent = view->getParent();
      if (!parent.isValid()) {
        return JS_NULL;
      }
      auto children = parent->getChildren();
      auto it = std::find(children.end(), children.begin(), view);
      it++;
      if (it == children.end()) {
        return JS_NULL;
      }
      auto nextSibling = * it;
      View * siblingView = dynamic_cast<View *>(nextSibling);
      return ::rehax::quickjs::cppToJs(ctx, privateData->bindings, siblingView);
    };

    auto functionObject = JS_NewCFunctionData(ctx, call, 0, 0, funDataArray.size(), funDataArray.data());
    JS_SetPropertyStr(ctx, prototype, "getNextSibling", functionObject);
    for (auto v : funDataArray) {
      JS_FreeValue(ctx, v);
    }
  }
  {
    auto funData = JS_NewObjectClass(ctx, kPointerClassId);
    JS_SetOpaque(funData, bindings);
    std::array<JSValue, 1> funDataArray {
      funData
    };
    auto call = [] (JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic, JSValue* func_data) {
      auto bindings = (Bindings *) JS_GetOpaque(func_data[0], kPointerClassId);
      auto privateData = static_cast<ViewPrivateData<View> *>(JS_GetOpaque(this_val, bindings->instanceClassId));
      View * view = privateData->view;

      auto layoutPrivateData = static_cast<ViewPrivateData<Layout> *>(JS_GetOpaque(argv[0], bindings->instanceClassId));
      auto layout = layoutPrivateData->view;
      
      view->setLayout(layout->getThisPointer());
      return JS_UNDEFINED;
    };

    auto functionObject = JS_NewCFunctionData(ctx, call, 0, 0, funDataArray.size(), funDataArray.data());
    JS_SetPropertyStr(ctx, prototype, "setLayout", functionObject);
    for (auto v : funDataArray) {
      JS_FreeValue(ctx, v);
    }
  }
  {
    auto funData = JS_NewObjectClass(ctx, kPointerClassId);
    JS_SetOpaque(funData, bindings);
    std::array<JSValue, 1> funDataArray {
      funData
    };
    auto call = [] (JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic, JSValue* func_data) {
      auto bindings = (Bindings *) JS_GetOpaque(func_data[0], kPointerClassId);
      auto privateData = static_cast<ViewPrivateData<View> *>(JS_GetOpaque(this_val, bindings->instanceClassId));
      View * view = privateData->view;

      auto gesturePrivateData = static_cast<ViewPrivateData<Gesture> *>(JS_GetOpaque(argv[0], bindings->instanceClassId));
      auto gesture = gesturePrivateData->view;
      
      view->addGesture(gesture);
      return JS_UNDEFINED;
    };

    auto functionObject = JS_NewCFunctionData(ctx, call, 0, 0, funDataArray.size(), funDataArray.data());
    JS_SetPropertyStr(ctx, prototype, "addGesture", functionObject);
    for (auto v : funDataArray) {
      JS_FreeValue(ctx, v);
    }
  }
}

template <typename View>
void bindButtonClassMethods(JSContext * ctx, Bindings *bindings, JSValue prototype) {
  bindMethod<View, std::string, &View::setTitle>("setTitle", ctx, bindings, prototype);
  bindMethod<View, std::string, &View::getTitle>("getTitle", ctx, bindings, prototype);
  bindMethod<View, std::function<void(void)>, &View::setOnPress>("setOnPress", ctx, bindings, prototype);
}

template <typename View>
void bindTextClassMethods(JSContext * ctx, Bindings *bindings, JSValue prototype) {
  bindMethod<View, std::string, &View::setText>("setText", ctx, bindings, prototype);
  bindMethod<View, std::string, &View::getText>("getText", ctx, bindings, prototype);
  bindMethod<View, rehax::ui::Color, &View::setTextColor>("setTextColor", ctx, bindings, prototype);
  bindMethod<View, float, &View::setFontSize>("setFontSize", ctx, bindings, prototype);
}


template <typename View>
void bindTextInputClassMethods(JSContext * ctx, Bindings *bindings, JSValue prototype) {
  bindMethod<View, std::string, &View::setValue>("setValue", ctx, bindings, prototype);
  bindMethod<View, std::string, &View::getValue>("getValue", ctx, bindings, prototype);
}

template <typename View>
void bindVectorElementClassMethods(JSContext * ctx, Bindings *bindings, JSValue prototype) {
  bindMethod<View, float, &View::setLineWidth>("setLineWidth", ctx, bindings, prototype);
  bindMethod<View, rehax::ui::VectorLineJoin, &View::setLineJoin>("setLineJoin", ctx, bindings, prototype);
  bindMethod<View, rehax::ui::VectorLineCap, &View::setLineCap>("setLineCap", ctx, bindings, prototype);
  bindMethod<View, rehax::ui::Color, &View::setFillColor>("setFillColor", ctx, bindings, prototype);
  bindMethod<View, rehax::ui::Color, &View::setStrokeColor>("setStrokeColor", ctx, bindings, prototype);
  bindMethod<View, rehax::ui::Gradient, &View::setFillGradient>("setFillGradient", ctx, bindings, prototype);
  bindMethod<View, rehax::ui::Gradient, &View::setStrokeGradient>("setStrokeGradient", ctx, bindings, prototype);
  bindMethod<View, rehax::ui::Filters, &View::setFilters>("setFilters", ctx, bindings, prototype);
}

template <typename View>
void bindVectorPathClassMethods(JSContext * ctx, Bindings *bindings, JSValue prototype) {
  bindMethod<View, &View::beginPath>("beginPath", ctx, bindings, prototype);
  bindMethod<View, float, &View::pathHorizontalTo>("pathHorizontalTo", ctx, bindings, prototype);
  bindMethod<View, float, &View::pathVerticalTo>("pathVerticalTo", ctx, bindings, prototype);
  bindMethod<View, float, float, &View::pathMoveTo>("pathMoveTo", ctx, bindings, prototype);
  bindMethod<View, float, float, &View::pathMoveBy>("pathMoveBy", ctx, bindings, prototype);
  bindMethod<View, float, float, &View::pathLineTo>("pathLineTo", ctx, bindings, prototype);
  bindMethod<View, float, float, float, float, &View::pathQuadraticBezier>("pathQuadraticBezier", ctx, bindings, prototype);
  bindMethod<View, float, float, float, int, int, float, float, &View::pathArc>("pathArc", ctx, bindings, prototype);
  bindMethod<View, float, float, float, float, float, float, &View::pathCubicBezier>("pathCubicBezier", ctx, bindings, prototype);
  bindMethod<View, &View::pathClose>("pathClose", ctx, bindings, prototype);
  bindMethod<View, &View::endPath>("endPath", ctx, bindings, prototype);
}

template <typename Layout, typename View>
void bindStackLayoutClassMethods(JSContext * ctx, Bindings *bindings, JSValue prototype) {
  bindMethod<Layout, rehax::ui::StackLayoutOptions, &Layout::setOptions>("setOptions", ctx, bindings, prototype);
}

template <typename Layout, typename View>
void bindFlexLayoutClassMethods(JSContext * ctx, Bindings *bindings, JSValue prototype) {
  bindMethod<Layout, rehax::ui::FlexLayoutOptions, &Layout::setOptions>("setOptions", ctx, bindings, prototype);
}

template <typename Gesture>
void bindGestureClassMethods(JSContext * ctx, Bindings *bindings, JSValue prototype) {
  bindMethod<Gesture, std::function<void(void)>, std::function<void(float, float)>, std::function<void(float, float)>, std::function<void(float, float)>, &Gesture::setup>("setup", ctx, bindings, prototype);
  bindMethod<Gesture, rehax::ui::GestureState, &Gesture::setState>("setState", ctx, bindings, prototype);
}

template <
  typename StackLayout,
  typename FlexLayout,
  typename View,
  typename Button,
  typename Text,
  typename TextInput,
  typename VectorContainer,
  typename VectorElement,
  typename VectorPath,
  typename ILayout,
  typename Gesture
>
void Bindings::bindToQuickJs() {
  defineViewClass<StackLayout>(ctx, "StackLayout", JS_NULL);
  defineViewClass<FlexLayout>(ctx, "FlexLayout", JS_NULL);

  defineViewClass<View>(ctx, "View", JS_NULL);
  defineViewClass<Button>(ctx, "Button", classRegistry["View"].prototype);
  defineViewClass<Text>(ctx, "Text", classRegistry["View"].prototype);
  defineViewClass<TextInput>(ctx, "TextInput", classRegistry["View"].prototype);
  defineViewClass<VectorContainer>(ctx, "VectorContainer", classRegistry["View"].prototype);
  defineViewClass<VectorElement>(ctx, "VectorElement", classRegistry["View"].prototype);
  defineViewClass<VectorPath>(ctx, "VectorPath", classRegistry["VectorElement"].prototype);

  bindViewClassMethods<View, ILayout, Gesture>(ctx, this, classRegistry["View"].prototype);
  bindButtonClassMethods<Button>(ctx, this, classRegistry["Button"].prototype);
  bindTextClassMethods<Text>(ctx, this, classRegistry["Text"].prototype);
  bindTextInputClassMethods<TextInput>(ctx, this, classRegistry["TextInput"].prototype);
  bindVectorElementClassMethods<VectorElement>(ctx, this, classRegistry["VectorElement"].prototype);
  bindVectorPathClassMethods<VectorPath>(ctx, this, classRegistry["VectorPath"].prototype);

  bindStackLayoutClassMethods<StackLayout, View>(ctx, this, classRegistry["StackLayout"].prototype);
  bindFlexLayoutClassMethods<FlexLayout, View>(ctx, this, classRegistry["FlexLayout"].prototype);

  defineViewClass<Gesture>(ctx, "Gesture", JS_NULL);
  bindGestureClassMethods<Gesture>(ctx, this, classRegistry["Gesture"].prototype);
}

#ifdef REHAX_WITH_APPKIT
void Bindings::bindAppkitToQuickJs() {
  bindToQuickJs<
    rehax::ui::appkit::StackLayout,
    rehax::ui::appkit::FlexLayout,
    rehax::ui::appkit::View,
    rehax::ui::appkit::Button,
    rehax::ui::appkit::Text,
    rehax::ui::appkit::TextInput,
    rehax::ui::appkit::VectorContainer,
    rehax::ui::appkit::VectorElement,
    rehax::ui::appkit::VectorPath,
    rehax::ui::appkit::impl::ILayout,
    rehax::ui::appkit::Gesture
  >();
}
#endif

#ifdef REHAX_WITH_FLUXE
void Bindings::bindFluxeToQuickJs() {
  bindToQuickJs<
    rehax::ui::fluxe::StackLayout,
    rehax::ui::fluxe::FlexLayout,
    rehax::ui::fluxe::View,
    rehax::ui::fluxe::Button,
    rehax::ui::fluxe::Text,
    rehax::ui::fluxe::TextInput,
    rehax::ui::fluxe::VectorContainer,
    rehax::ui::fluxe::VectorElement,
    rehax::ui::fluxe::VectorPath,
    rehax::ui::fluxe::impl::ILayout,
    rehax::ui::fluxe::Gesture
  >();
}
#endif

}
}
