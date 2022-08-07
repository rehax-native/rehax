
template <typename Object, bool instantiable>
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
      if constexpr (instantiable) {
        auto obj = Object::Create();
        return Converter<Object>::toScript(ctx, obj.get(), bindings);
      }
      return JS_NULL;
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

template <typename Object, bool instantiable>
void Bindings::defineViewClass(JSContext * ctx, std::string name, void * null) {
  auto prototypeObject = JS_NewObjectClass(ctx, kPrototypeClassId);

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
      if constexpr (instantiable) {
        auto obj = Object::Create();
        return Converter<Object>::toScript(ctx, obj.get(), bindings);
      }
      return JS_NULL;
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
void Bindings::bindMethod(std::string name, JSContext * ctx, JSValue prototype) {
  auto funData = JS_NewObjectClass(ctx, kPointerClassId);
  JS_SetOpaque(funData, this);
  std::array<JSValue, 1> funDataArray {
    funData
  };
  auto call = [] (JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic, JSValue* func_data) {
    auto bindings = (Bindings *) JS_GetOpaque(func_data[0], kPointerClassId);
    auto privateData = static_cast<ViewPrivateData<View> *>(JS_GetOpaque(this_val, bindings->instanceClassId));
    View * view = privateData->view;
    auto ret = (view->*Method)();
    return Converter<RET>::toScript(ctx, ret, bindings);
  };

  auto functionObject = JS_NewCFunctionData(ctx, call, 0, 0, funDataArray.size(), funDataArray.data());
  JS_SetPropertyStr(ctx, prototype, name.c_str(), functionObject);
  for (auto v : funDataArray) {
    JS_FreeValue(ctx, v);
  }
}

template <typename View, void (View::*Method)(void)>
void Bindings::bindMethod(std::string name, JSContext * ctx, JSValue prototype) {
  auto funData = JS_NewObjectClass(ctx, kPointerClassId);
  JS_SetOpaque(funData, this);
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
void Bindings::bindMethod(std::string name, JSContext * ctx, JSValue prototype) {
  auto funData = JS_NewObjectClass(ctx, kPointerClassId);
  JS_SetOpaque(funData, this);
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

template <typename View, typename T1, typename D1, void (View::*Method)(T1), void (View::*MethodDefault)(D1)>
void Bindings::bindMethod(std::string name, JSContext * ctx, JSValue prototype) {
  auto funData = JS_NewObjectClass(ctx, kPointerClassId);
  JS_SetOpaque(funData, this);
  std::array<JSValue, 1> funDataArray {
    funData
  };
  auto call = [] (JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic, JSValue* func_data) {
    auto bindings = (Bindings *) JS_GetOpaque(func_data[0], kPointerClassId);
    auto privateData = static_cast<ViewPrivateData<View> *>(JS_GetOpaque(this_val, bindings->instanceClassId));
    View * view = privateData->view;

    if (JS_IsUndefined(argv[0]) || JS_IsNull(argv[0])) {
      (view->*MethodDefault)(::rehax::ui::DefaultValue{});
    } else {
      (view->*Method)(
        Converter<T1>::toCpp(ctx, argv[0], bindings, privateData->retainedValues)
    );
    }

    return JS_UNDEFINED;
  };

  auto functionObject = JS_NewCFunctionData(ctx, call, 0, 0, funDataArray.size(), funDataArray.data());
  JS_SetPropertyStr(ctx, prototype, name.c_str(), functionObject);
  for (auto v : funDataArray) {
    JS_FreeValue(ctx, v);
  }
}

template <typename View, typename T1, typename T2, void (View::*Method)(T1, T2)>
void Bindings::bindMethod(std::string name, JSContext * ctx, JSValue prototype) {
  auto funData = JS_NewObjectClass(ctx, kPointerClassId);
  JS_SetOpaque(funData, this);
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
void Bindings::bindMethod(std::string name, JSContext * ctx, JSValue prototype) {
  auto funData = JS_NewObjectClass(ctx, kPointerClassId);
  JS_SetOpaque(funData, this);
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
void Bindings::bindMethod(std::string name, JSContext * ctx, JSValue prototype) {
  auto funData = JS_NewObjectClass(ctx, kPointerClassId);
  JS_SetOpaque(funData, this);
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
void Bindings::bindMethod(std::string name, JSContext * ctx, JSValue prototype) {
  auto funData = JS_NewObjectClass(ctx, kPointerClassId);
  JS_SetOpaque(funData, this);
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
void Bindings::bindMethod(std::string name, JSContext * ctx, JSValue prototype) {
  auto funData = JS_NewObjectClass(ctx, kPointerClassId);
  JS_SetOpaque(funData, this);
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
void Bindings::bindMethod(std::string name, JSContext * ctx, JSValue prototype) {
  auto funData = JS_NewObjectClass(ctx, kPointerClassId);
  JS_SetOpaque(funData, this);
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
