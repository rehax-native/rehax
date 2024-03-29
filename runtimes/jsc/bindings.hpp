
template <typename Object, bool instantiable>
void Bindings::defineClass(std::string name, RegisteredClass * parentClass) {
    
  #if RHX_GEN_DOCS
  jscDocs.collectView<View>(rehax::docs::ViewDocs {
    .name = name,
  });
  #endif
  
  JSClassDefinition instanceDefine = kJSClassDefinitionEmpty;
  instanceDefine.attributes = kJSClassAttributeNone;
  instanceDefine.className = name.c_str();
  instanceDefine.finalize = [] (JSObjectRef thiz) {
    auto privateData = static_cast<ViewPrivateData<Object> *>(JSObjectGetPrivate(thiz));
    auto ctx = privateData->ctx;
//      std::cout << "GC " << privateData->view->instanceClassName() << " " << privateData->view->getReferenceCount() << std::endl;
    privateData->view->decreaseReferenceCount();
    delete privateData;
  };
  
  JSObjectRef prototypeObject = JSObjectMake(ctx, nullptr, nullptr);
  JSValueProtect(ctx, prototypeObject);
  if (parentClass != nullptr) {
    JSObjectSetPrototype(ctx, prototypeObject, parentClass->prototype);
  }
  
  if constexpr (instantiable) {
    instanceDefine.callAsConstructor = [] (JSContextRef ctx, JSObjectRef constructor, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception) {
      auto bindings = static_cast<Bindings *>(JSObjectGetPrivate(constructor));
      auto view = Object::Create();
      return (JSObjectRef) Converter<Object>::toScript(ctx, view.get(), bindings);
    };
  }
  
  auto clazz = JSClassCreate(&instanceDefine);
  auto jsClassObject = JSObjectMake(ctx, clazz, this);
  classRegistry[Object::ClassName()] = {
    .name = name,
    .classDefine = clazz,
    .prototype = prototypeObject,
    .classObject = jsClassObject,
  };
  auto className = JSStringCreateWithUTF8CString(name.c_str());

  auto globalObject = JSContextGetGlobalObject(ctx);
  runtime::Value rehax = runtime::GetRehaxObject(ctx);
  JSObjectSetProperty(ctx, (JSObjectRef) rehax, className, jsClassObject, kJSPropertyAttributeReadOnly, NULL);
  JSStringRelease(className);
  
  return clazz;
}

template <typename FN>
void Bindings::bindStaticMethod(std::string name, runtime::Value classObject, FN fn) {
  JSStringRef methodName = JSStringCreateWithUTF8CString(name.c_str());
  auto functionObject = Converter<FN>::toScript(ctx, fn, this);
  JSObjectSetProperty(ctx, (JSObjectRef) classObject, methodName, functionObject, kJSPropertyAttributeReadOnly, NULL);
  JSStringRelease(methodName);
}

template <typename View, typename RET, RET (View::*Method)(void)>
void Bindings::bindMethod(std::string name, JSValueRef prototype) {
  #if RHX_GEN_DOCS
  jscDocs.collectMethod<View>({
    .name = name,
    .returnType = rehax::docs::get_type_name<RET>(),
    .arguments = std::vector<rehax::docs::ArgumentDocs> {}
  });
  #endif
  JSStringRef methodName = JSStringCreateWithUTF8CString(name.c_str());
  auto functionObject = JSObjectMakeFunctionWithCallback(ctx, methodName, [] (JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception) {
    auto privateData = static_cast<ViewPrivateData<View> *>(JSObjectGetPrivate(thisObject));
    auto view = privateData->view;
    auto ret = (view->*Method)();
    return Converter<RET>::toScript(ctx, ret, privateData->bindings);
  });
  JSObjectSetProperty(ctx, (JSObjectRef) prototype, methodName, functionObject, kJSPropertyAttributeReadOnly, NULL);
  JSStringRelease(methodName);
}

template <typename View, void (View::*Method)(void)>
void Bindings::bindMethod(std::string name, JSValueRef prototype) {
  #if RHX_GEN_DOCS
  jscDocs.collectMethod<View>({
    .name = name,
    .arguments = std::vector<rehax::docs::ArgumentDocs> {}
  });
  #endif
  JSStringRef methodName = JSStringCreateWithUTF8CString(name.c_str());
  auto functionObject = JSObjectMakeFunctionWithCallback(ctx, methodName, [] (JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception) {
    auto privateData = static_cast<ViewPrivateData<View> *>(JSObjectGetPrivate(thisObject));
    auto view = privateData->view;
    (view->*Method)();
    return JSValueMakeUndefined(ctx);
  });
  JSObjectSetProperty(ctx, (JSObjectRef) prototype, methodName, functionObject, kJSPropertyAttributeReadOnly, NULL);
  JSStringRelease(methodName);
}

template <typename View, typename T1, void (View::*Method)(T1)>
void Bindings::bindMethod(std::string name, JSValueRef prototype) {
  #if RHX_GEN_DOCS
  jscDocs.collectMethod<View>({
    .name = name,
    .arguments = std::vector<rehax::docs::ArgumentDocs> {
      rehax::docs::ArgumentDocs { .type = rehax::docs::get_type_name<T1>(), },
    }
  });
  #endif

  JSStringRef methodName = JSStringCreateWithUTF8CString(name.c_str());
  auto functionObject = JSObjectMakeFunctionWithCallback(ctx, methodName, [] (JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception) {
    auto privateData = static_cast<ViewPrivateData<View> *>(JSObjectGetPrivate(thisObject));
    auto view = privateData->view;

    (view->*Method)(
      Converter<T1>::toCpp(ctx, arguments[0], privateData->bindings)
    );

    return JSValueMakeUndefined(ctx);
  });
  JSObjectSetProperty(ctx, (JSObjectRef) prototype, methodName, functionObject, kJSPropertyAttributeReadOnly, NULL);
  JSStringRelease(methodName);
}

template <typename View, typename R1, typename T1, R1 (View::*Method)(T1)>
void Bindings::bindMethod(std::string name, JSValueRef prototype) {
  #if RHX_GEN_DOCS
  jscDocs.collectMethod<View>({
    .name = name,
    .arguments = std::vector<rehax::docs::ArgumentDocs> {
      rehax::docs::ArgumentDocs { .type = rehax::docs::get_type_name<T1>(), },
    }
  });
  #endif

  JSStringRef methodName = JSStringCreateWithUTF8CString(name.c_str());
  auto functionObject = JSObjectMakeFunctionWithCallback(ctx, methodName, [] (JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception) {
    auto privateData = static_cast<ViewPrivateData<View> *>(JSObjectGetPrivate(thisObject));
    auto view = privateData->view;

    auto ret = (view->*Method)(
      Converter<T1>::toCpp(ctx, arguments[0], privateData->bindings)
    );

    return Converter<R1>::toScript(ctx, ret, privateData->bindings);
  });
  JSObjectSetProperty(ctx, (JSObjectRef) prototype, methodName, functionObject, kJSPropertyAttributeReadOnly, NULL);
  JSStringRelease(methodName);
}

template <typename View, typename T1, typename D1, void (View::*Method)(T1), void (View::*MethodDefault)(D1)>
void Bindings::bindMethod(std::string name,JSValueRef prototype) {
  #if RHX_GEN_DOCS
  jscDocs.collectMethod<View>({
    .name = name,
    .arguments = std::vector<rehax::docs::ArgumentDocs> {
      rehax::docs::ArgumentDocs { .type = rehax::docs::get_type_name<T1>(), },
    }
  });
  #endif

  JSStringRef methodName = JSStringCreateWithUTF8CString(name.c_str());
  auto functionObject = JSObjectMakeFunctionWithCallback(ctx, methodName, [] (JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception) {
    auto privateData = static_cast<ViewPrivateData<View> *>(JSObjectGetPrivate(thisObject));
    auto view = privateData->view;

    if (JSValueIsUndefined(ctx, arguments[0]) || JSValueIsNull(ctx, arguments[0])) {
      (view->*MethodDefault)(::rehax::ui::DefaultValue{});
    } else {
      (view->*Method)(
        Converter<T1>::toCpp(ctx, arguments[0], privateData->bindings)
      );
    }

    return JSValueMakeUndefined(ctx);
  });
  JSObjectSetProperty(ctx, (JSObjectRef) prototype, methodName, functionObject, kJSPropertyAttributeReadOnly, NULL);
  JSStringRelease(methodName);
}

template <typename View, typename T1, typename T2, void (View::*Method)(T1, T2)>
void Bindings::bindMethod(std::string name,JSValueRef prototype) {
  #if RHX_GEN_DOCS
  jscDocs.collectMethod<View>({
    .name = name,
    .arguments = std::vector<rehax::docs::ArgumentDocs> {
      rehax::docs::ArgumentDocs { .type = rehax::docs::get_type_name<T1>(), },
      rehax::docs::ArgumentDocs { .type = rehax::docs::get_type_name<T2>(), },
    }
  });
  #endif

  JSStringRef methodName = JSStringCreateWithUTF8CString(name.c_str());
  auto functionObject = JSObjectMakeFunctionWithCallback(ctx, methodName, [] (JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception) {
    auto privateData = static_cast<ViewPrivateData<View> *>(JSObjectGetPrivate(thisObject));
    auto view = privateData->view;

    (view->*Method)(
      Converter<T1>::toCpp(ctx, arguments[0], privateData->bindings),
      Converter<T2>::toCpp(ctx, arguments[1], privateData->bindings)
    );
    return JSValueMakeUndefined(ctx);
  });
  JSObjectSetProperty(ctx, (JSObjectRef) prototype, methodName, functionObject, kJSPropertyAttributeReadOnly, NULL);
  JSStringRelease(methodName);
}

template <typename View, typename T1, typename T2, typename T3, void (View::*Method)(T1, T2)>
void Bindings::bindMethod(std::string name,JSValueRef prototype) {
  #if RHX_GEN_DOCS
  jscDocs.collectMethod<View>({
    .name = name,
    .arguments = std::vector<rehax::docs::ArgumentDocs> {
      rehax::docs::ArgumentDocs { .type = rehax::docs::get_type_name<T1>(), },
      rehax::docs::ArgumentDocs { .type = rehax::docs::get_type_name<T2>(), },
      rehax::docs::ArgumentDocs { .type = rehax::docs::get_type_name<T3>(), },
    }
  });
  #endif

  JSStringRef methodName = JSStringCreateWithUTF8CString(name.c_str());
  auto functionObject = JSObjectMakeFunctionWithCallback(ctx, methodName, [] (JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception) {
    auto privateData = static_cast<ViewPrivateData<View> *>(JSObjectGetPrivate(thisObject));
    auto view = privateData->view;

    (view->*Method)(
      Converter<T1>::toCpp(ctx, arguments[0], privateData->bindings),
      Converter<T2>::toCpp(ctx, arguments[1], privateData->bindings),
      Converter<T3>::toCpp(ctx, arguments[2], privateData->bindings)
    );
    return JSValueMakeUndefined(ctx);
  });
  JSObjectSetProperty(ctx, (JSObjectRef) prototype, methodName, functionObject, kJSPropertyAttributeReadOnly, NULL);
  JSStringRelease(methodName);
}

template <typename View, typename T1, typename T2, typename T3, typename T4, void (View::*Method)(T1, T2, T3, T4)>
void Bindings::bindMethod(std::string name,JSValueRef prototype) {
  #if RHX_GEN_DOCS
  jscDocs.collectMethod<View>({
    .name = name,
    .arguments = std::vector<rehax::docs::ArgumentDocs> {
      rehax::docs::ArgumentDocs { .type = rehax::docs::get_type_name<T1>(), },
      rehax::docs::ArgumentDocs { .type = rehax::docs::get_type_name<T2>(), },
      rehax::docs::ArgumentDocs { .type = rehax::docs::get_type_name<T3>(), },
      rehax::docs::ArgumentDocs { .type = rehax::docs::get_type_name<T4>(), },
    }
  });
  #endif

  JSStringRef methodName = JSStringCreateWithUTF8CString(name.c_str());
  auto functionObject = JSObjectMakeFunctionWithCallback(ctx, methodName, [] (JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception) {
    auto privateData = static_cast<ViewPrivateData<View> *>(JSObjectGetPrivate(thisObject));
    auto view = privateData->view;

    (view->*Method)(
      Converter<T1>::toCpp(ctx, arguments[0], privateData->bindings),
      Converter<T2>::toCpp(ctx, arguments[1], privateData->bindings),
      Converter<T3>::toCpp(ctx, arguments[2], privateData->bindings),
      Converter<T4>::toCpp(ctx, arguments[3], privateData->bindings)
    );
    return JSValueMakeUndefined(ctx);
  });
  JSObjectSetProperty(ctx, (JSObjectRef) prototype, methodName, functionObject, kJSPropertyAttributeReadOnly, NULL);
  JSStringRelease(methodName);
}

template <typename View, typename T1, typename T2, typename T3, typename T4, typename T5, void (View::*Method)(T1, T2, T3, T4, T5)>
void Bindings::bindMethod(std::string name,JSValueRef prototype) {
  #if RHX_GEN_DOCS
  jscDocs.collectMethod<View>({
    .name = name,
    .arguments = std::vector<rehax::docs::ArgumentDocs> {
      rehax::docs::ArgumentDocs { .type = rehax::docs::get_type_name<T1>(), },
      rehax::docs::ArgumentDocs { .type = rehax::docs::get_type_name<T2>(), },
      rehax::docs::ArgumentDocs { .type = rehax::docs::get_type_name<T3>(), },
      rehax::docs::ArgumentDocs { .type = rehax::docs::get_type_name<T4>(), },
      rehax::docs::ArgumentDocs { .type = rehax::docs::get_type_name<T5>(), },
    }
  });
  #endif

  JSStringRef methodName = JSStringCreateWithUTF8CString(name.c_str());
  auto functionObject = JSObjectMakeFunctionWithCallback(ctx, methodName, [] (JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception) {
    auto privateData = static_cast<ViewPrivateData<View> *>(JSObjectGetPrivate(thisObject));
    auto view = privateData->view;

    (view->*Method)(
      Converter<T1>::toCpp(ctx, arguments[0], privateData->bindings),
      Converter<T2>::toCpp(ctx, arguments[1], privateData->bindings),
      Converter<T3>::toCpp(ctx, arguments[2], privateData->bindings),
      Converter<T4>::toCpp(ctx, arguments[3], privateData->bindings),
      Converter<T5>::toCpp(ctx, arguments[4], privateData->bindings)
    );
    return JSValueMakeUndefined(ctx);
  });
  JSObjectSetProperty(ctx, (JSObjectRef) prototype, methodName, functionObject, kJSPropertyAttributeReadOnly, NULL);
  JSStringRelease(methodName);
}

template <typename View, typename T1, typename T2, typename T3, typename T4, typename T5, typename T6, void (View::*Method)(T1, T2, T3, T4, T5, T6)>
void Bindings::bindMethod(std::string name,JSValueRef prototype) {
  #if RHX_GEN_DOCS
  jscDocs.collectMethod<View>({
    .name = name,
    .arguments = std::vector<rehax::docs::ArgumentDocs> {
      rehax::docs::ArgumentDocs { .type = rehax::docs::get_type_name<T1>(), },
      rehax::docs::ArgumentDocs { .type = rehax::docs::get_type_name<T2>(), },
      rehax::docs::ArgumentDocs { .type = rehax::docs::get_type_name<T3>(), },
      rehax::docs::ArgumentDocs { .type = rehax::docs::get_type_name<T4>(), },
      rehax::docs::ArgumentDocs { .type = rehax::docs::get_type_name<T5>(), },
      rehax::docs::ArgumentDocs { .type = rehax::docs::get_type_name<T6>(), },
    }
  });
  #endif

  JSStringRef methodName = JSStringCreateWithUTF8CString(name.c_str());
  auto functionObject = JSObjectMakeFunctionWithCallback(ctx, methodName, [] (JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception) {
    auto privateData = static_cast<ViewPrivateData<View> *>(JSObjectGetPrivate(thisObject));
    auto view = privateData->view;

    (view->*Method)(
      Converter<T1>::toCpp(ctx, arguments[0], privateData->bindings),
      Converter<T2>::toCpp(ctx, arguments[1], privateData->bindings),
      Converter<T3>::toCpp(ctx, arguments[2], privateData->bindings),
      Converter<T4>::toCpp(ctx, arguments[3], privateData->bindings),
      Converter<T5>::toCpp(ctx, arguments[4], privateData->bindings),
      Converter<T6>::toCpp(ctx, arguments[5], privateData->bindings)
    );
    return JSValueMakeUndefined(ctx);
  });
  JSObjectSetProperty(ctx, (JSObjectRef) prototype, methodName, functionObject, kJSPropertyAttributeReadOnly, NULL);
  JSStringRelease(methodName);
}

template <typename View, typename T1, typename T2, typename T3, typename T4, typename T5, typename T6, typename T7, void (View::*Method)(T1, T2, T3, T4, T5, T6, T7)>
void Bindings::bindMethod(std::string name,JSValueRef prototype) {
  #if RHX_GEN_DOCS
  jscDocs.collectMethod<View>({
    .name = name,
//    .nativeName = rehax::docs::get_type_name<Method>(),
    .arguments = std::vector<rehax::docs::ArgumentDocs> {
      rehax::docs::ArgumentDocs { .type = rehax::docs::get_type_name<T1>(), },
      rehax::docs::ArgumentDocs { .type = rehax::docs::get_type_name<T2>(), },
      rehax::docs::ArgumentDocs { .type = rehax::docs::get_type_name<T3>(), },
      rehax::docs::ArgumentDocs { .type = rehax::docs::get_type_name<T4>(), },
      rehax::docs::ArgumentDocs { .type = rehax::docs::get_type_name<T5>(), },
      rehax::docs::ArgumentDocs { .type = rehax::docs::get_type_name<T6>(), },
      rehax::docs::ArgumentDocs { .type = rehax::docs::get_type_name<T7>(), },
    }
  });
  #endif

  JSStringRef methodName = JSStringCreateWithUTF8CString(name.c_str());
  auto functionObject = JSObjectMakeFunctionWithCallback(ctx, methodName, [] (JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception) {
    auto privateData = static_cast<ViewPrivateData<View> *>(JSObjectGetPrivate(thisObject));
    auto view = privateData->view;

    (view->*Method)(
      Converter<T1>::toCpp(ctx, arguments[0], privateData->bindings),
      Converter<T2>::toCpp(ctx, arguments[1], privateData->bindings),
      Converter<T3>::toCpp(ctx, arguments[2], privateData->bindings),
      Converter<T4>::toCpp(ctx, arguments[3], privateData->bindings),
      Converter<T5>::toCpp(ctx, arguments[4], privateData->bindings),
      Converter<T6>::toCpp(ctx, arguments[5], privateData->bindings),
      Converter<T7>::toCpp(ctx, arguments[6], privateData->bindings)
    );
    return JSValueMakeUndefined(ctx);
  });
  JSObjectSetProperty(ctx, (JSObjectRef) prototype, methodName, functionObject, kJSPropertyAttributeReadOnly, NULL);
  JSStringRelease(methodName);
}
