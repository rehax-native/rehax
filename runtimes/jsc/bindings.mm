#include "./bindings.h"

#define RHX_GEN_DOCS 1

#if RHX_GEN_DOCS
#include "../docs.h"
rehax::docs::Docs<rehax::ui::appkit::View> jscDocs("JavascriptCore");
#endif

namespace rehax {
namespace jsc {


namespace runtime {

typedef ::JSContextRef Context;
typedef ::JSValueRef Value;

Value MakeObject(Context ctx) {
  JSObjectRef object = JSObjectMake(ctx, nullptr, nullptr);
  return object;
}

Value MakeArray(Context ctx) {
  auto object = JSObjectMakeArray(ctx, 0, {}, NULL);
  return object;
}

void SetObjectProperty(Context ctx, Value object, std::string property, Value value) {
  auto propName = JSStringCreateWithUTF8CString(property.c_str());
  JSObjectSetProperty(ctx, (JSObjectRef) object, propName, value, kJSPropertyAttributeNone, nullptr);
}

Value GetObjectProperty(Context ctx, Value object, std::string property) {
  auto propName = JSStringCreateWithUTF8CString(property.c_str());
  return JSObjectGetProperty(ctx, (JSObjectRef) object, propName, NULL);
}

bool HasObjectProperty(Context ctx, Value object, std::string property) {
  return JSObjectHasProperty(ctx, (JSObjectRef) object, JSStringCreateWithUTF8CString(property.c_str()));
}

void SetArrayValue(Context ctx, Value object, int index, Value value) {
  JSObjectSetPropertyAtIndex(ctx, (JSObjectRef) object, index, value, nullptr);
}

Value GetArrayValue(Context ctx, Value object, int index) {
  return JSObjectGetPropertyAtIndex(ctx, (JSObjectRef) object, index, nullptr);
}

}


template <typename T>
struct Converter {
  static JSValueRef toScript(JSContextRef ctx, T& value);
  static T toCpp(JSContextRef ctx, const JSValueRef& value, Bindings * bindings, std::vector<JSValueRef>& retainedValues);
};

template <>
struct Converter<std::string> {
  static JSValueRef toScript(JSContextRef ctx, std::string value) {
    JSStringRef jsText = JSStringCreateWithUTF8CString(value.c_str());
    return (JSValueRef) jsText;
  }
  static std::string toCpp(JSContextRef ctx, const JSValueRef str, Bindings * bindings, std::vector<JSValueRef>& retainedValues) {
    if (JSValueIsString(ctx, str)) {
      if (JSStringGetLength((JSStringRef) str) == 0) {
        return "";
      }
      size_t maxBufferSize = JSStringGetMaximumUTF8CStringSize((JSStringRef) str);
      char* utf8Buffer = new char[maxBufferSize];
      size_t bytesWritten = JSStringGetUTF8CString((JSStringRef) str, utf8Buffer, maxBufferSize);
      utf8Buffer[bytesWritten] = '\0';
      std::string ret = std::string(utf8Buffer);
      delete [] utf8Buffer;
      return ret;
    }
    return "";
  }
};

template <>
struct Converter<bool> {
  static JSValueRef toScript(JSContextRef ctx, bool value) {
    return JSValueMakeBoolean(ctx, value);
  }
  static bool toCpp(JSContextRef ctx, const JSValueRef& value, Bindings * bindings, std::vector<JSValueRef>& retainedValues) {
    return (bool) JSValueToBoolean(ctx, value);
  }
};

template <>
struct Converter<int> {
  static JSValueRef toScript(JSContextRef ctx, int value) {
      return JSValueMakeNumber(ctx, (double) value);
  }
  static int toCpp(JSContextRef ctx, const JSValueRef& value, Bindings * bindings, std::vector<JSValueRef>& retainedValues) {
    return (int) JSValueToNumber(ctx, value, nullptr);
  }
};

template <>
struct Converter<float> {
  static JSValueRef toScript(JSContextRef ctx, float value) {
      return JSValueMakeNumber(ctx, (double) value);
  }
  static float toCpp(JSContextRef ctx, const JSValueRef& value, Bindings * bindings, std::vector<JSValueRef>& retainedValues) {
    return (float) JSValueToNumber(ctx, value, nullptr);
  }
};

template <>
struct Converter<double> {
  static JSValueRef toScript(JSContextRef ctx, double value) {
      return JSValueMakeNumber(ctx, (double) value);
  }
  static double toCpp(JSContextRef ctx, const JSValueRef& value, Bindings * bindings, std::vector<JSValueRef>& retainedValues) {
    return (double) JSValueToNumber(ctx, value, nullptr);
  }
};

template <>
struct Converter<std::function<void(void)>> {
  static JSValueRef toScript(JSContextRef ctx, std::function<void(void)>&& value) {
      // TODO
      return JSValueMakeUndefined(ctx);
  }
  static std::function<void(void)> toCpp(JSContextRef ctx, const JSValueRef& value, Bindings * bindings, std::vector<JSValueRef>& retainedValues) {
    JSObjectRef callback = (JSObjectRef) value;
      
    JSValueProtect(ctx, callback);
    retainedValues.push_back(callback);
    auto fn = [ctx, callback] () {
      //                auto exception = JSObjectMake(ctx, nullptr, nullptr);
      JSValueRef exception = nullptr;
      JSObjectCallAsFunction(ctx, callback, NULL, 0, NULL, &exception);
      // if (exception != nullptr) {
      //     auto exMessage = JSObjectGetProperty(ctx, (JSObjectRef) exception, JSStringCreateWithUTF8CString("message"), nullptr);
      //     auto message = Bindings::JSStringToStdString(ctx, (JSStringRef) exMessage);
      //     std::cout << message << std::endl;
      // }
    };
    return fn;
  }
};

template <>
struct Converter<std::function<void(float, float)>> {
  static JSValueRef toScript(JSContextRef ctx, std::function<void(float, float)>&& value) {
      // TODO
      return JSValueMakeUndefined(ctx);
  }
  static std::function<void(float, float)> toCpp(JSContextRef ctx, const JSValueRef& value, Bindings * bindings, std::vector<JSValueRef>& retainedValues) {
    JSObjectRef callback = (JSObjectRef) value;
    JSValueProtect(ctx, callback);
    retainedValues.push_back(callback);
    auto fn = [ctx, callback] (float a, float b) {
      //                auto exception = JSObjectMake(ctx, nullptr, nullptr);
      JSValueRef exception = nullptr;
      JSValueRef arguments[] = {
        JSValueMakeNumber(ctx, a),
        JSValueMakeNumber(ctx, b),
      };
      JSObjectCallAsFunction(ctx, callback, NULL, 2, arguments, &exception);
      // if (exception != nullptr) {
      //     auto exMessage = JSObjectGetProperty(ctx, (JSObjectRef) exception, JSStringCreateWithUTF8CString("message"), nullptr);
      //     auto message = Bindings::JSStringToStdString(ctx, (JSStringRef) exMessage);
      //     std::cout << message << std::endl;
      // }
    };
    return fn;
  }
};


#include "../common/converters.h"


Bindings::Bindings() {}

void Bindings::setContext(JSContextRef ctx) {
  this->ctx = ctx;
}

RegisteredClass Bindings::getRegisteredClass(std::string name) {
  return classRegistry[name];
}

template <typename View>
JSObjectRef cppToJs(JSContextRef ctx, Bindings * bindings, View * obj) {
  auto privateData = new ViewPrivateData<View>();
  privateData->view = obj;
  privateData->bindings = bindings;
  privateData->ctx = ctx;

  auto className = obj->instanceClassName();
  obj->increaseReferenceCount(); // decreased in finalizer
    
  auto registeredClass = bindings->getRegisteredClass(className);

  JSObjectRef object = JSObjectMake(ctx, registeredClass.classDefine, privateData);
  JSObjectSetPrototype(ctx, object, registeredClass.prototype);
  auto __className = JSStringCreateWithUTF8CString(className.c_str());
  JSObjectSetProperty(ctx, object, JSStringCreateWithUTF8CString("__className"), (JSValueRef) JSValueMakeString(ctx, __className), kJSPropertyAttributeReadOnly, NULL);
  return object;
}

template <typename View>
void Bindings::defineViewClass(JSContextRef ctx, std::string name, JSObjectRef parentPrototype) {
    
  #if RHX_GEN_DOCS
  jscDocs.collectView<View>(rehax::docs::ViewDocs {
    .name = name,
  });
  #endif
  
  JSClassDefinition instanceDefine = kJSClassDefinitionEmpty;
  instanceDefine.attributes = kJSClassAttributeNone;
  instanceDefine.className = name.c_str();
  instanceDefine.finalize = [] (JSObjectRef thiz) {
    auto privateData = static_cast<ViewPrivateData<View> *>(JSObjectGetPrivate(thiz));
    auto ctx = privateData->ctx;
      
      std::cout << "GC " << privateData->view->instanceClassName() << " " << privateData->view->getReferenceCount() << std::endl;

    // The value cannot be unprotected here, as GCing views doesn't mean the're actually destroyed.
    // Therefore the retainted values can still be used in callbacks etc.
    for (auto value : privateData->retainedValues) {
//      JSValueUnprotect(ctx, value);
    }

    privateData->view->decreaseReferenceCount();
    delete privateData;
  };
  
  JSObjectRef prototypeObject = JSObjectMake(ctx, nullptr, nullptr);
  JSValueProtect(ctx, prototypeObject);
  if (parentPrototype != nullptr) {
    JSObjectSetPrototype(ctx, prototypeObject, parentPrototype);
  }
  
  instanceDefine.callAsConstructor = [] (JSContextRef ctx, JSObjectRef constructor, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception) {
    auto bindings = static_cast<Bindings *>(JSObjectGetPrivate(constructor));
    auto view = View::Create();
    return ::rehax::jsc::cppToJs(ctx, bindings, view.get());
  };
  
  auto clazz = JSClassCreate(&instanceDefine);
  classRegistry[View::ClassName()] = {
    .name = name,
    .classDefine = clazz,
    .prototype = prototypeObject,
  };
  auto jsClassObject = JSObjectMake(ctx, clazz, this);
  auto className = JSStringCreateWithUTF8CString(name.c_str());

  auto globalContext = JSContextGetGlobalObject(ctx);
  JSObjectSetProperty(ctx, globalContext, className, jsClassObject, kJSPropertyAttributeReadOnly, NULL);
  
  return clazz;
}

template <typename View, typename RET, RET (View::*Method)(void)>
void bindMethod(std::string name, JSContextRef ctx, JSObjectRef prototype) {
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
    return Converter<RET>::toScript(ctx, ret);
  });
  JSObjectSetProperty(ctx, prototype, methodName, functionObject, kJSPropertyAttributeReadOnly, NULL);
}

template <typename View, void (View::*Method)(void)>
void bindMethod(std::string name, JSContextRef ctx, JSObjectRef prototype) {
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
  JSObjectSetProperty(ctx, prototype, methodName, functionObject, kJSPropertyAttributeReadOnly, NULL);
}

template <typename View, typename T1, void (View::*Method)(T1)>
void bindMethod(std::string name, JSContextRef ctx, JSObjectRef prototype) {
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
      Converter<T1>::toCpp(ctx, arguments[0], privateData->bindings, privateData->retainedValues)
    );
    return JSValueMakeUndefined(ctx);
  });
  JSObjectSetProperty(ctx, prototype, methodName, functionObject, kJSPropertyAttributeReadOnly, NULL);
}

template <typename View, typename T1, typename T2, void (View::*Method)(T1, T2)>
void bindMethod(std::string name, JSContextRef ctx, JSObjectRef prototype) {
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
      Converter<T1>::toCpp(ctx, arguments[0], privateData->bindings, privateData->retainedValues),
      Converter<T2>::toCpp(ctx, arguments[1], privateData->bindings, privateData->retainedValues)
    );
    return JSValueMakeUndefined(ctx);
  });
  JSObjectSetProperty(ctx, prototype, methodName, functionObject, kJSPropertyAttributeReadOnly, NULL);
}

template <typename View, typename T1, typename T2, typename T3, void (View::*Method)(T1, T2)>
void bindMethod(std::string name, JSContextRef ctx, JSObjectRef prototype) {
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
      Converter<T1>::toCpp(ctx, arguments[0], privateData->bindings, privateData->retainedValues),
      Converter<T2>::toCpp(ctx, arguments[1], privateData->bindings, privateData->retainedValues),
      Converter<T3>::toCpp(ctx, arguments[2], privateData->bindings, privateData->retainedValues)
    );
    return JSValueMakeUndefined(ctx);
  });
  JSObjectSetProperty(ctx, prototype, methodName, functionObject, kJSPropertyAttributeReadOnly, NULL);
}

template <typename View, typename T1, typename T2, typename T3, typename T4, void (View::*Method)(T1, T2, T3, T4)>
void bindMethod(std::string name, JSContextRef ctx, JSObjectRef prototype) {
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
      Converter<T1>::toCpp(ctx, arguments[0], privateData->bindings, privateData->retainedValues),
      Converter<T2>::toCpp(ctx, arguments[1], privateData->bindings, privateData->retainedValues),
      Converter<T3>::toCpp(ctx, arguments[2], privateData->bindings, privateData->retainedValues),
      Converter<T4>::toCpp(ctx, arguments[3], privateData->bindings, privateData->retainedValues)
    );
    return JSValueMakeUndefined(ctx);
  });
  JSObjectSetProperty(ctx, prototype, methodName, functionObject, kJSPropertyAttributeReadOnly, NULL);
}

template <typename View, typename T1, typename T2, typename T3, typename T4, typename T5, void (View::*Method)(T1, T2, T3, T4, T5)>
void bindMethod(std::string name, JSContextRef ctx, JSObjectRef prototype) {
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
      Converter<T1>::toCpp(ctx, arguments[0], privateData->bindings, privateData->retainedValues),
      Converter<T2>::toCpp(ctx, arguments[1], privateData->bindings, privateData->retainedValues),
      Converter<T3>::toCpp(ctx, arguments[2], privateData->bindings, privateData->retainedValues),
      Converter<T4>::toCpp(ctx, arguments[3], privateData->bindings, privateData->retainedValues),
      Converter<T5>::toCpp(ctx, arguments[4], privateData->bindings, privateData->retainedValues)
    );
    return JSValueMakeUndefined(ctx);
  });
  JSObjectSetProperty(ctx, prototype, methodName, functionObject, kJSPropertyAttributeReadOnly, NULL);
}

template <typename View, typename T1, typename T2, typename T3, typename T4, typename T5, typename T6, void (View::*Method)(T1, T2, T3, T4, T5, T6)>
void bindMethod(std::string name, JSContextRef ctx, JSObjectRef prototype) {
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
      Converter<T1>::toCpp(ctx, arguments[0], privateData->bindings, privateData->retainedValues),
      Converter<T2>::toCpp(ctx, arguments[1], privateData->bindings, privateData->retainedValues),
      Converter<T3>::toCpp(ctx, arguments[2], privateData->bindings, privateData->retainedValues),
      Converter<T4>::toCpp(ctx, arguments[3], privateData->bindings, privateData->retainedValues),
      Converter<T5>::toCpp(ctx, arguments[4], privateData->bindings, privateData->retainedValues),
      Converter<T6>::toCpp(ctx, arguments[5], privateData->bindings, privateData->retainedValues)
    );
    return JSValueMakeUndefined(ctx);
  });
  JSObjectSetProperty(ctx, prototype, methodName, functionObject, kJSPropertyAttributeReadOnly, NULL);
}

template <typename View, typename T1, typename T2, typename T3, typename T4, typename T5, typename T6, typename T7, void (View::*Method)(T1, T2, T3, T4, T5, T6, T7)>
void bindMethod(std::string name, JSContextRef ctx, JSObjectRef prototype) {
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
      Converter<T1>::toCpp(ctx, arguments[0], privateData->bindings, privateData->retainedValues),
      Converter<T2>::toCpp(ctx, arguments[1], privateData->bindings, privateData->retainedValues),
      Converter<T3>::toCpp(ctx, arguments[2], privateData->bindings, privateData->retainedValues),
      Converter<T4>::toCpp(ctx, arguments[3], privateData->bindings, privateData->retainedValues),
      Converter<T5>::toCpp(ctx, arguments[4], privateData->bindings, privateData->retainedValues),
      Converter<T6>::toCpp(ctx, arguments[5], privateData->bindings, privateData->retainedValues),
      Converter<T7>::toCpp(ctx, arguments[6], privateData->bindings, privateData->retainedValues)
    );
    return JSValueMakeUndefined(ctx);
  });
  JSObjectSetProperty(ctx, prototype, methodName, functionObject, kJSPropertyAttributeReadOnly, NULL);
}


template <typename View, typename Layout, typename Gesture>
void bindViewClassMethods(JSContextRef ctx, JSObjectRef prototype) {
  bindMethod<View, std::string, &View::description>("toString", ctx, prototype);
  bindMethod<View, &View::removeFromParent>("removeFromParent", ctx, prototype);
  bindMethod<View, float, &View::setWidthFixed>("setWidthFixed", ctx, prototype);
  bindMethod<View, float, &View::setHeightFixed>("setHeightFixed", ctx, prototype);
  bindMethod<View, float, &View::setWidthPercentage>("setWidthPercentage", ctx, prototype);
  bindMethod<View, float, &View::setWidthPercentage>("setWidthPercentage", ctx, prototype);
  bindMethod<View, &View::layout>("layout", ctx, prototype);
    
  {
    JSStringRef methodName = JSStringCreateWithUTF8CString("addView");
    auto functionObject = JSObjectMakeFunctionWithCallback(ctx, methodName, [] (JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception) {
      auto privateData = static_cast<ViewPrivateData<View> *>(JSObjectGetPrivate(thisObject));
      auto view = privateData->view;

      auto childPrivateData = static_cast<ViewPrivateData<View> *>(JSObjectGetPrivate((JSObjectRef) arguments[0]));
      auto childView = childPrivateData->view;

      if (argumentCount <= 1 || JSValueIsNull(ctx, arguments[1]) || JSValueIsUndefined(ctx, arguments[1])) {
        view->addView(childView);
      } else {
        auto beforeView = static_cast<ViewPrivateData<View> *>(JSObjectGetPrivate((JSObjectRef) arguments[1]));
        view->addView(childView, beforeView->view);
      }
      return JSValueMakeUndefined(ctx);
    });
    JSObjectSetProperty(ctx, prototype, methodName, functionObject, kJSPropertyAttributeReadOnly, NULL);
      
    #if RHX_GEN_DOCS
    jscDocs.collectMethod<View>({
      .name = std::string("addView"),
      .arguments = std::vector<rehax::docs::ArgumentDocs> {
        rehax::docs::ArgumentDocs { .type = std::string_view("View"), },
      }
    });
    #endif
  }
  {
    JSStringRef methodName = JSStringCreateWithUTF8CString("removeView");
    auto functionObject = JSObjectMakeFunctionWithCallback(ctx, methodName, [] (JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception) {
      auto privateData = static_cast<ViewPrivateData<View> *>(JSObjectGetPrivate(thisObject));
      auto view = privateData->view;

      auto childPrivateData = static_cast<ViewPrivateData<View> *>(JSObjectGetPrivate((JSObjectRef) arguments[0]));
      auto childView = childPrivateData->view;

      view->removeView(childView);
      return JSValueMakeUndefined(ctx);
    });
    JSObjectSetProperty(ctx, prototype, methodName, functionObject, kJSPropertyAttributeReadOnly, NULL);
    #if RHX_GEN_DOCS
    jscDocs.collectMethod<View>({
      .name = std::string("removeView"),
      .arguments = std::vector<rehax::docs::ArgumentDocs> {
        rehax::docs::ArgumentDocs { .type = std::string_view("View"), },
      }
    });
    #endif
  }
  {
    JSStringRef methodName = JSStringCreateWithUTF8CString("getParent");
    auto functionObject = JSObjectMakeFunctionWithCallback(ctx, methodName, [] (JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception) {
      auto privateData = static_cast<ViewPrivateData<View> *>(JSObjectGetPrivate(thisObject));
      auto view = privateData->view;

      auto parent = view->getParent();
        
      if (!parent.isValid()) {
        return JSValueMakeNull(ctx);
      }
                
      View * parentView = dynamic_cast<View *>(parent.get());
      auto jsParent = ::rehax::jsc::cppToJs(ctx, privateData->bindings, parentView);
      return (JSValueRef) jsParent;
    });
    JSObjectSetProperty(ctx, prototype, methodName, functionObject, kJSPropertyAttributeReadOnly, NULL);
    #if RHX_GEN_DOCS
    jscDocs.collectMethod<View>({
      .name = std::string("getParent"),
      .returnType = std::string_view("View"),
      .arguments = std::vector<rehax::docs::ArgumentDocs> {
        rehax::docs::ArgumentDocs {},
      }
    });
    #endif
  }
  {
    JSStringRef methodName = JSStringCreateWithUTF8CString("getFirstChild");
    auto functionObject = JSObjectMakeFunctionWithCallback(ctx, methodName, [] (JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception) {
      auto privateData = static_cast<ViewPrivateData<View> *>(JSObjectGetPrivate(thisObject));
      auto view = privateData->view;

      auto children = view->getChildren();
      if (children.size() == 0) {
        return JSValueMakeNull(ctx);
      }
      auto firstChild = children.begin();
      return (JSValueRef) ::rehax::jsc::cppToJs(ctx, privateData->bindings, (View *) *firstChild);
    });
    JSObjectSetProperty(ctx, prototype, methodName, functionObject, kJSPropertyAttributeReadOnly, NULL);
    #if RHX_GEN_DOCS
    jscDocs.collectMethod<View>({
      .name = std::string("getFirstChild"),
      .returnType = std::string_view("View"),
      .arguments = std::vector<rehax::docs::ArgumentDocs> {
        rehax::docs::ArgumentDocs {},
      }
    });
    #endif
  }
  {
    JSStringRef methodName = JSStringCreateWithUTF8CString("getNextSibling");
    auto functionObject = JSObjectMakeFunctionWithCallback(ctx, methodName, [] (JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception) {
      auto privateData = static_cast<ViewPrivateData<View> *>(JSObjectGetPrivate(thisObject));
      auto view = privateData->view;

      // TODO this should probably be moved to the core
      auto parent = view->getParent();
      if (!parent.isValid()) {
        return JSValueMakeNull(ctx);
      }
      auto children = parent->getChildren();
      auto it = std::find(children.end(), children.begin(), view);
      it++;
      if (it == children.end()) {
        return JSValueMakeNull(ctx);
      }
      auto nextSibling = * it;
      View * siblingView = dynamic_cast<View *>(nextSibling);
      return (JSValueRef) ::rehax::jsc::cppToJs(ctx, privateData->bindings, siblingView);
    });
    JSObjectSetProperty(ctx, prototype, methodName, functionObject, kJSPropertyAttributeReadOnly, NULL);
    #if RHX_GEN_DOCS
    jscDocs.collectMethod<View>({
      .name = std::string("getNextSibling"),
      .returnType = std::string_view("View"),
      .arguments = std::vector<rehax::docs::ArgumentDocs> {
        rehax::docs::ArgumentDocs {},
      }
    });
    #endif
  }
  {
    JSStringRef methodName = JSStringCreateWithUTF8CString("setLayout");
    auto functionObject = JSObjectMakeFunctionWithCallback(ctx, methodName, [] (JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception) {
      auto privateData = static_cast<ViewPrivateData<View> *>(JSObjectGetPrivate(thisObject));
      auto view = privateData->view;

      auto layoutPrivateData = static_cast<ViewPrivateData<Layout> *>(JSObjectGetPrivate((JSObjectRef) arguments[0]));
      auto layout = layoutPrivateData->view;
      view->setLayout(layout->getThisPointer());
      return JSValueMakeUndefined(ctx);
    });
    JSObjectSetProperty(ctx, prototype, methodName, functionObject, kJSPropertyAttributeReadOnly, NULL);
    #if RHX_GEN_DOCS
    jscDocs.collectMethod<View>({
      .name = std::string("setLayout"),
      .arguments = std::vector<rehax::docs::ArgumentDocs> {
        rehax::docs::ArgumentDocs { .type = std::string_view("Layout"), },
      }
    });
    #endif
  }
  {
    JSStringRef methodName = JSStringCreateWithUTF8CString("addGesture");
    auto functionObject = JSObjectMakeFunctionWithCallback(ctx, methodName, [] (JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception) {
      auto privateData = static_cast<ViewPrivateData<View> *>(JSObjectGetPrivate(thisObject));
      auto view = privateData->view;

      auto gesturePrivateData = static_cast<ViewPrivateData<Gesture> *>(JSObjectGetPrivate((JSObjectRef) arguments[0]));
      auto gesture = gesturePrivateData->view;

      view->addGesture(gesture);
      return JSValueMakeUndefined(ctx);
    });
    JSObjectSetProperty(ctx, prototype, methodName, functionObject, kJSPropertyAttributeReadOnly, NULL);
      
    #if RHX_GEN_DOCS
    jscDocs.collectMethod<View>({
      .name = std::string("addGesture"),
      .arguments = std::vector<rehax::docs::ArgumentDocs> {
        rehax::docs::ArgumentDocs { .type = std::string_view("Gesture"), },
      }
    });
    #endif
  }

}

template <typename View>
void bindButtonClassMethods(JSContextRef ctx, JSObjectRef prototype) {
  bindMethod<View, std::string, &View::setTitle>("setTitle", ctx, prototype);
  bindMethod<View, std::string, &View::getTitle>("getTitle", ctx, prototype);
  bindMethod<View, std::function<void(void)>, &View::setOnPress>("setOnPress", ctx, prototype);
}

template <typename View>
void bindTextClassMethods(JSContextRef ctx, JSObjectRef prototype) {
  bindMethod<View, std::string, &View::setText>("setText", ctx, prototype);
  bindMethod<View, std::string, &View::getText>("getText", ctx, prototype);
  bindMethod<View, rehax::ui::Color, &View::setTextColor>("setTextColor", ctx, prototype);
  bindMethod<View, float, &View::setFontSize>("setFontSize", ctx, prototype);
}

template <typename View>
void bindTextInputClassMethods(JSContextRef ctx, JSObjectRef prototype) {
  bindMethod<View, std::string, &View::setValue>("setValue", ctx, prototype);
  bindMethod<View, std::string, &View::getValue>("getValue", ctx, prototype);
}

template <typename View>
void bindVectorElementClassMethods(JSContextRef ctx, JSObjectRef prototype) {
  bindMethod<View, float, &View::setLineWidth>("setLineWidth", ctx, prototype);
  bindMethod<View, rehax::ui::VectorLineJoin, &View::setLineJoin>("setLineJoin", ctx, prototype);
  bindMethod<View, rehax::ui::VectorLineCap, &View::setLineCap>("setLineCap", ctx, prototype);
  bindMethod<View, rehax::ui::Color, &View::setFillColor>("setFillColor", ctx, prototype);
  bindMethod<View, rehax::ui::Color, &View::setStrokeColor>("setStrokeColor", ctx, prototype);
  bindMethod<View, rehax::ui::Gradient, &View::setFillGradient>("setFillGradient", ctx, prototype);
  bindMethod<View, rehax::ui::Gradient, &View::setStrokeGradient>("setStrokeGradient", ctx, prototype);
  bindMethod<View, rehax::ui::Filters, &View::setFilters>("setFilters", ctx, prototype);
}

template <typename View>
void bindVectorPathClassMethods(JSContextRef ctx, JSObjectRef prototype) {
  bindMethod<View, &View::beginPath>("beginPath", ctx, prototype);
  bindMethod<View, float, &View::pathHorizontalTo>("pathHorizontalTo", ctx, prototype);
  bindMethod<View, float, &View::pathVerticalTo>("pathVerticalTo", ctx, prototype);
  bindMethod<View, float, float, &View::pathMoveTo>("pathMoveTo", ctx, prototype);
  bindMethod<View, float, float, &View::pathMoveBy>("pathMoveBy", ctx, prototype);
  bindMethod<View, float, float, &View::pathLineTo>("pathLineTo", ctx, prototype);
  bindMethod<View, float, float, float, float, &View::pathQuadraticBezier>("pathQuadraticBezier", ctx, prototype);
  bindMethod<View, float, float, float, int, int, float, float, &View::pathArc>("pathArc", ctx, prototype);
  bindMethod<View, float, float, float, float, float, float, &View::pathCubicBezier>("pathCubicBezier", ctx, prototype);
  bindMethod<View, &View::pathClose>("pathClose", ctx, prototype);
  bindMethod<View, &View::endPath>("endPath", ctx, prototype);
}

template <typename Layout, typename View>
void bindStackLayoutClassMethods(JSContextRef ctx, JSObjectRef prototype) {
  bindMethod<Layout, rehax::ui::StackLayoutOptions, &Layout::setOptions>("setOptions", ctx, prototype);
}

template <typename Layout, typename View>
void bindFlexLayoutClassMethods(JSContextRef ctx, JSObjectRef prototype) {
  bindMethod<Layout, rehax::ui::FlexLayoutOptions, &Layout::setOptions>("setOptions", ctx, prototype);
}

template <typename Gesture>
void bindGestureClassMethods(JSContextRef ctx, JSObjectRef prototype) {
  bindMethod<Gesture, std::function<void(void)>, std::function<void(float, float)>, std::function<void(float, float)>, std::function<void(float, float)>, &Gesture::setup>("setup", ctx, prototype);
  bindMethod<Gesture, rehax::ui::GestureState, &Gesture::setState>("setState", ctx, prototype);
}


#ifdef REHAX_WITH_APPKIT
void Bindings::bindAppkitToJsc() {
#if RHX_GEN_DOCS
  jscDocs.collectType("Color", rehax::docs::TypeDocs {
    .type = rehax::docs::get_type_name<rehax::ui::Color>(),
    .note = "Converts from/to an object with shape `{ red: number, green: number, blue: number, alpha: number }`. The range for `alpha` is 0.0 - 1.0, and the ranges for the others is 0.0 - 255.0.",
  });
#endif
#if RHX_GEN_DOCS
  jscDocs.collectType("StackLayoutOptions", rehax::docs::TypeDocs {
    .type = rehax::docs::get_type_name<rehax::ui::StackLayoutOptions>(),
    .note = "Converts from/to an object with shape `{ spacing: float, direction: 'Horizontal' | 'Vertical' }`.",
  });
#endif
#if RHX_GEN_DOCS
  jscDocs.collectType("FlexLayoutOptions", rehax::docs::TypeDocs {
    .type = rehax::docs::get_type_name<rehax::ui::FlexLayoutOptions>(),
    .note = "Converts from/to an object with shape `{ direction: 'Column' | 'ColumnReverse' | 'Row' | 'RowReverse', TODO }`.",
  });
#endif
    
  defineViewClass<rehax::ui::appkit::StackLayout>(ctx, "StackLayout", nullptr);
  defineViewClass<rehax::ui::appkit::FlexLayout>(ctx, "FlexLayout", nullptr);

  defineViewClass<rehax::ui::appkit::View>(ctx, "View", nullptr);
  defineViewClass<rehax::ui::appkit::Button>(ctx, "Button", classRegistry["View"].prototype);
  defineViewClass<rehax::ui::appkit::Text>(ctx, "Text", classRegistry["View"].prototype);
  defineViewClass<rehax::ui::appkit::TextInput>(ctx, "TextInput", classRegistry["View"].prototype);
  defineViewClass<rehax::ui::appkit::VectorContainer>(ctx, "VectorContainer", classRegistry["View"].prototype);
  defineViewClass<rehax::ui::appkit::VectorElement>(ctx, "VectorElement", classRegistry["View"].prototype);
  defineViewClass<rehax::ui::appkit::VectorPath>(ctx, "VectorPath", classRegistry["VectorElement"].prototype);

  bindViewClassMethods<rehax::ui::appkit::View, rehax::ui::appkit::impl::ILayout, rehax::ui::appkit::Gesture>(ctx, classRegistry["View"].prototype);
  bindButtonClassMethods<rehax::ui::appkit::Button>(ctx, classRegistry["Button"].prototype);
  bindTextClassMethods<rehax::ui::appkit::Text>(ctx, classRegistry["Text"].prototype);
  bindTextInputClassMethods<rehax::ui::appkit::TextInput>(ctx, classRegistry["TextInput"].prototype);
  bindVectorElementClassMethods<rehax::ui::appkit::VectorElement>(ctx, classRegistry["VectorElement"].prototype);
  bindVectorPathClassMethods<rehax::ui::appkit::VectorPath>(ctx, classRegistry["VectorPath"].prototype);

  bindStackLayoutClassMethods<rehax::ui::appkit::StackLayout, rehax::ui::appkit::View>(ctx, classRegistry["StackLayout"].prototype);
  bindFlexLayoutClassMethods<rehax::ui::appkit::FlexLayout, rehax::ui::appkit::View>(ctx, classRegistry["FlexLayout"].prototype);

  defineViewClass<rehax::ui::appkit::Gesture>(ctx, "Gesture", nullptr);
  bindGestureClassMethods<rehax::ui::appkit::Gesture>(ctx, classRegistry["Gesture"].prototype);

  jscDocs.printJson();
  jscDocs.printMarkdown();
}
#endif

#ifdef REHAX_WITH_FLUXE
void Bindings::bindFluxeToJsc() {
#if RHX_GEN_DOCS
  jscDocs.collectType("Color", rehax::docs::TypeDocs {
    .type = rehax::docs::get_type_name<rehax::ui::Color>(),
    .note = "Converts from/to an object with shape `{ red: number, green: number, blue: number, alpha: number }`. The range for `alpha` is 0.0 - 1.0, and the ranges for the others is 0.0 - 255.0.",
  });
#endif
#if RHX_GEN_DOCS
  jscDocs.collectType("StackLayoutOptions", rehax::docs::TypeDocs {
    .type = rehax::docs::get_type_name<rehax::ui::StackLayoutOptions>(),
    .note = "Converts from/to an object with shape `{ spacing: float, direction: 'Horizontal' | 'Vertical' }`.",
  });
#endif
#if RHX_GEN_DOCS
  jscDocs.collectType("FlexLayoutOptions", rehax::docs::TypeDocs {
    .type = rehax::docs::get_type_name<rehax::ui::FlexLayoutOptions>(),
    .note = "Converts from/to an object with shape `{ direction: 'Column' | 'ColumnReverse' | 'Row' | 'RowReverse', TODO }`.",
  });
#endif
    
  defineViewClass<rehax::ui::fluxe::StackLayout>(ctx, "StackLayout", nullptr);
  defineViewClass<rehax::ui::fluxe::FlexLayout>(ctx, "FlexLayout", nullptr);

  defineViewClass<rehax::ui::fluxe::View>(ctx, "View", nullptr);
  defineViewClass<rehax::ui::fluxe::Button>(ctx, "Button", classRegistry["View"].prototype);
  defineViewClass<rehax::ui::fluxe::Text>(ctx, "Text", classRegistry["View"].prototype);
  defineViewClass<rehax::ui::fluxe::TextInput>(ctx, "TextInput", classRegistry["View"].prototype);
  defineViewClass<rehax::ui::fluxe::VectorContainer>(ctx, "VectorContainer", classRegistry["View"].prototype);
  defineViewClass<rehax::ui::fluxe::VectorElement>(ctx, "VectorElement", classRegistry["View"].prototype);
  defineViewClass<rehax::ui::fluxe::VectorPath>(ctx, "VectorPath", classRegistry["VectorElement"].prototype);

  bindViewClassMethods<rehax::ui::fluxe::View, rehax::ui::fluxe::impl::ILayout, rehax::ui::fluxe::Gesture>(ctx, classRegistry["View"].prototype);
  bindButtonClassMethods<rehax::ui::fluxe::Button>(ctx, classRegistry["Button"].prototype);
  bindTextClassMethods<rehax::ui::fluxe::Text>(ctx, classRegistry["Text"].prototype);
  bindTextInputClassMethods<rehax::ui::fluxe::TextInput>(ctx, classRegistry["TextInput"].prototype);
  bindVectorElementClassMethods<rehax::ui::fluxe::VectorElement>(ctx, classRegistry["VectorElement"].prototype);
  bindVectorPathClassMethods<rehax::ui::fluxe::VectorPath>(ctx, classRegistry["VectorPath"].prototype);

  bindStackLayoutClassMethods<rehax::ui::fluxe::StackLayout, rehax::ui::fluxe::View>(ctx, classRegistry["StackLayout"].prototype);
  bindFlexLayoutClassMethods<rehax::ui::fluxe::FlexLayout, rehax::ui::fluxe::View>(ctx, classRegistry["FlexLayout"].prototype);

  defineViewClass<rehax::ui::fluxe::Gesture>(ctx, "Gesture", nullptr);
  bindGestureClassMethods<rehax::ui::fluxe::Gesture>(ctx, classRegistry["Gesture"].prototype);

  jscDocs.printJson();
  jscDocs.printMarkdown();
}
#endif

}
}
