#include "./bindings.h"

#define RHX_GEN_DOCS 0

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


//template <typename T>
//struct Converter {
//  static JSValueRef toScript(JSContextRef ctx, T& value);
//  static T toCpp(JSContextRef ctx, const JSValueRef& value, Bindings * bindings, std::vector<JSValueRef>& retainedValues);
//};

template <typename Object>
struct Converter {
  static JSValueRef toScript(JSContextRef ctx, Object * obj, Bindings * bindings) {
    auto privateData = new ViewPrivateData<Object>();
    privateData->view = obj;
    privateData->bindings = bindings;
    privateData->ctx = ctx;

    obj->increaseReferenceCount(); // decreased in finalizer

    auto className = obj->instanceClassName();
    auto registeredClass = bindings->getRegisteredClass(className);

    JSObjectRef object = JSObjectMake(ctx, registeredClass.classDefine, privateData);
    JSObjectSetPrototype(ctx, object, registeredClass.prototype);
    auto __className = JSStringCreateWithUTF8CString(className.c_str());
    JSObjectSetProperty(ctx, object, JSStringCreateWithUTF8CString("__className"), (JSValueRef) JSValueMakeString(ctx, __className), kJSPropertyAttributeReadOnly, NULL);

    return object;
  }
  static Object * toCpp(JSContextRef ctx, const JSValueRef& value, Bindings * bindings, std::vector<JSValueRef>& retainedValues) {
    auto privateData = static_cast<ViewPrivateData<Object> *>(JSObjectGetPrivate((JSObjectRef) value));
    auto obj = privateData->view;
    return obj;
  }
};

template <typename Object>
struct Converter<rehaxUtils::ObjectPointer<Object>> {
  static JSValueRef toScript(JSContextRef ctx, rehaxUtils::ObjectPointer<Object> obj, Bindings * bindings) {
    if (!obj.hasPointer()) {
      return JSValueMakeNull(ctx);
    }
    return Converter<Object>::toScript(ctx, obj.get(), bindings);
  }
  static rehaxUtils::ObjectPointer<Object> toCpp(JSContextRef ctx, const JSValueRef& value, Bindings * bindings, std::vector<JSValueRef>& retainedValues) {
    if (JSValueIsNull(ctx, value) || JSValueIsUndefined(ctx, value)) {
      return rehaxUtils::ObjectPointer<Object>(nullptr);
    }
    auto ptr = Converter<Object>::toCpp(ctx, value, bindings, retainedValues);
    return ptr->getThisPointer();
  }
};

template <typename Object>
struct Converter<rehaxUtils::WeakObjectPointer<Object>> {
  static JSValueRef toScript(JSContextRef ctx, rehaxUtils::WeakObjectPointer<Object> obj, Bindings * bindings) {
    if (!obj.isValid()) {
      return JSValueMakeNull(ctx);
    }
    return Converter<Object>::toScript(ctx, obj.get(), bindings);
  }
  static rehaxUtils::WeakObjectPointer<Object> toCpp(JSContextRef ctx, const JSValueRef& value, Bindings * bindings, std::vector<JSValueRef>& retainedValues) {
    if (JSValueIsNull(ctx, value) || JSValueIsUndefined(ctx, value)) {
      return WeakObjectPointer<Object>(nullptr);
    }
    auto ptr = Converter<Object>::toCpp(ctx, value, bindings, retainedValues);
    return ptr->getThisPointer();
  }
};

template <>
struct Converter<std::string> {
  static JSValueRef toScript(JSContextRef ctx, std::string value, Bindings * bindings = nullptr) {
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
  static JSValueRef toScript(JSContextRef ctx, bool value, Bindings * bindings = nullptr) {
    return JSValueMakeBoolean(ctx, value);
  }
  static bool toCpp(JSContextRef ctx, const JSValueRef& value, Bindings * bindings, std::vector<JSValueRef>& retainedValues) {
    return (bool) JSValueToBoolean(ctx, value);
  }
};

template <>
struct Converter<int> {
  static JSValueRef toScript(JSContextRef ctx, int value, Bindings * bindings = nullptr) {
      return JSValueMakeNumber(ctx, (double) value);
  }
  static int toCpp(JSContextRef ctx, const JSValueRef& value, Bindings * bindings, std::vector<JSValueRef>& retainedValues) {
    return (int) JSValueToNumber(ctx, value, nullptr);
  }
};

template <>
struct Converter<float> {
  static JSValueRef toScript(JSContextRef ctx, float value, Bindings * bindings = nullptr) {
      return JSValueMakeNumber(ctx, (double) value);
  }
  static float toCpp(JSContextRef ctx, const JSValueRef& value, Bindings * bindings, std::vector<JSValueRef>& retainedValues) {
    return (float) JSValueToNumber(ctx, value, nullptr);
  }
};

template <>
struct Converter<double> {
  static JSValueRef toScript(JSContextRef ctx, double value, Bindings * bindings = nullptr) {
      return JSValueMakeNumber(ctx, (double) value);
  }
  static double toCpp(JSContextRef ctx, const JSValueRef& value, Bindings * bindings, std::vector<JSValueRef>& retainedValues) {
    return (double) JSValueToNumber(ctx, value, nullptr);
  }
};

template <>
struct Converter<std::function<void(void)>> {
  static JSValueRef toScript(JSContextRef ctx, std::function<void(void)>&& value, Bindings * bindings = nullptr) {
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

template <typename T1>
struct Converter<std::function<void(T1)>> {
  static JSValueRef toScript(JSContextRef ctx, std::function<void(T1)>&& value, Bindings * bindings = nullptr) {
      // TODO
      return JSValueMakeUndefined(ctx);
  }
  static std::function<void(T1)> toCpp(JSContextRef ctx, const JSValueRef& value, Bindings * bindings, std::vector<JSValueRef>& retainedValues) {
    JSObjectRef callback = (JSObjectRef) value;
    JSValueProtect(ctx, callback);
    retainedValues.push_back(callback);
    auto fn = [ctx, callback] (T1 a) {
      //                auto exception = JSObjectMake(ctx, nullptr, nullptr);
      JSValueRef exception = nullptr;
      JSValueRef arguments[] = {
        Converter<T1>::toScript(ctx, a),
      };
      JSObjectCallAsFunction(ctx, callback, NULL, 1, arguments, &exception);
      // if (exception != nullptr) {
      //     auto exMessage = JSObjectGetProperty(ctx, (JSObjectRef) exception, JSStringCreateWithUTF8CString("message"), nullptr);
      //     auto message = Bindings::JSStringToStdString(ctx, (JSStringRef) exMessage);
      //     std::cout << message << std::endl;
      // }
    };
    return fn;
  }
};

template <typename T1, typename T2>
struct Converter<std::function<void(T1, T2)>> {
  static JSValueRef toScript(JSContextRef ctx, std::function<void(T1, T2)>&& value, Bindings * bindings = nullptr) {
      // TODO
      return JSValueMakeUndefined(ctx);
  }
  static std::function<void(T1, T2)> toCpp(JSContextRef ctx, const JSValueRef& value, Bindings * bindings, std::vector<JSValueRef>& retainedValues) {
    JSObjectRef callback = (JSObjectRef) value;
    JSValueProtect(ctx, callback);
    retainedValues.push_back(callback);
    auto fn = [ctx, callback] (T1 a, T2 b) {
      //                auto exception = JSObjectMake(ctx, nullptr, nullptr);
      JSValueRef exception = nullptr;
      JSValueRef arguments[] = {
        Converter<T1>::toScript(ctx, a),
        Converter<T2>::toScript(ctx, b),
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

template <typename T1, typename T2, typename T3>
struct Converter<std::function<void(T1, T2, T3)>> {
  static JSValueRef toScript(JSContextRef ctx, std::function<void(T1, T2)>&& value, Bindings * bindings = nullptr) {
      // TODO
      return JSValueMakeUndefined(ctx);
  }
  static std::function<void(T1, T2, T3)> toCpp(JSContextRef ctx, const JSValueRef& value, Bindings * bindings, std::vector<JSValueRef>& retainedValues) {
    JSObjectRef callback = (JSObjectRef) value;
    JSValueProtect(ctx, callback);
    retainedValues.push_back(callback);
    auto fn = [ctx, callback] (T1 a, T2 b, T3 c) {
      //                auto exception = JSObjectMake(ctx, nullptr, nullptr);
      JSValueRef exception = nullptr;
      JSValueRef arguments[] = {
        Converter<T1>::toScript(ctx, a),
        Converter<T2>::toScript(ctx, b),
        Converter<T3>::toScript(ctx, c),
      };
      JSObjectCallAsFunction(ctx, callback, NULL, 3, arguments, &exception);
      // if (exception != nullptr) {
      //     auto exMessage = JSObjectGetProperty(ctx, (JSObjectRef) exception, JSStringCreateWithUTF8CString("message"), nullptr);
      //     auto message = Bindings::JSStringToStdString(ctx, (JSStringRef) exMessage);
      //     std::cout << message << std::endl;
      // }
    };
    return fn;
  }
};

template <typename R1>
struct Converter<std::function<R1(void)>> {
  static JSValueRef toScript(JSContextRef ctx, std::function<R1(void)>&& value, Bindings * bindings = nullptr) {
      // TODO
      return JSValueMakeUndefined(ctx);
  }
  static std::function<R1(void)> toCpp(JSContextRef ctx, const JSValueRef& value, Bindings * bindings, std::vector<JSValueRef>& retainedValues) {
    JSObjectRef callback = (JSObjectRef) value;
      
    JSValueProtect(ctx, callback);
    retainedValues.push_back(callback);
    auto fn = [ctx, callback, bindings, &retainedValues] () {
      //                auto exception = JSObjectMake(ctx, nullptr, nullptr);
      JSValueRef exception = nullptr;
      auto ret = JSObjectCallAsFunction(ctx, callback, NULL, 0, NULL, &exception);
      return Converter<R1>::toCpp(ctx, ret, bindings, retainedValues);
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

template <typename Object, bool instantiable>
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
    auto privateData = static_cast<ViewPrivateData<Object> *>(JSObjectGetPrivate(thiz));
    auto ctx = privateData->ctx;
      
      // std::cout << "GC " << privateData->view->instanceClassName() << " " << privateData->view->getReferenceCount() << std::endl;

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
  
  if constexpr (instantiable) {
    instanceDefine.callAsConstructor = [] (JSContextRef ctx, JSObjectRef constructor, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception) {
      auto bindings = static_cast<Bindings *>(JSObjectGetPrivate(constructor));
      auto view = Object::Create();
      return (JSObjectRef) Converter<Object>::toScript(ctx, view.get(), bindings);
    };
  }
  
  auto clazz = JSClassCreate(&instanceDefine);
  classRegistry[Object::ClassName()] = {
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
    return Converter<RET>::toScript(ctx, ret, privateData->bindings);
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

template <typename View, typename T1, typename D1, void (View::*Method)(T1), void (View::*MethodDefault)(D1)>
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

    if (JSValueIsUndefined(ctx, arguments[0]) || JSValueIsNull(ctx, arguments[0])) {
      (view->*MethodDefault)(::rehax::ui::DefaultValue{});
    } else {
      (view->*Method)(
        Converter<T1>::toCpp(ctx, arguments[0], privateData->bindings, privateData->retainedValues)
      );
    }

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
  bindMethod<View, rehaxUtils::ObjectPointer<View>, rehaxUtils::ObjectPointer<View>, &View::addView>("addView", ctx, prototype);
  bindMethod<View, &View::removeFromParent>("removeFromParent", ctx, prototype);
  bindMethod<View, rehaxUtils::ObjectPointer<View>, &View::removeView>("removeView", ctx, prototype);
  bindMethod<View, rehaxUtils::WeakObjectPointer<View>, &View::getParent>("getParent", ctx, prototype);
  bindMethod<View, rehaxUtils::WeakObjectPointer<View>, &View::getFirstChild>("getFirstChild", ctx, prototype);
  bindMethod<View, rehaxUtils::WeakObjectPointer<View>, &View::getNextSibling>("getNextSibling", ctx, prototype);
  bindMethod<View, rehax::ui::Length, &View::setWidth>("setWidth", ctx, prototype);
  bindMethod<View, rehax::ui::Length, &View::setHeight>("setHeight", ctx, prototype);
  bindMethod<View, rehaxUtils::ObjectPointer<Layout>, &View::setLayout>("setLayout", ctx, prototype);
  bindMethod<View, &View::layout>("layout", ctx, prototype);
  bindMethod<View, rehaxUtils::ObjectPointer<Gesture>, &View::addGesture>("addGesture", ctx, prototype);
  bindMethod<View, rehax::ui::Color, ::rehax::ui::DefaultValue, &View::setBackgroundColor, &View::setBackgroundColor>("setBackgroundColor", ctx, prototype);
}

template <typename View>
void bindButtonClassMethods(JSContextRef ctx, JSObjectRef prototype) {
  bindMethod<View, std::string, &View::getTitle>("getTitle", ctx, prototype);
  bindMethod<View, std::string, rehax::ui::DefaultValue, &View::setTitle, &View::setTitle>("setTitle", ctx, prototype);
  bindMethod<View, std::function<void(void)>, rehax::ui::DefaultValue, &View::setOnPress, &View::setOnPress>("setOnPress", ctx, prototype);
}

template <typename View>
void bindTextClassMethods(JSContextRef ctx, JSObjectRef prototype) {
  bindMethod<View, std::string, &View::getText>("getText", ctx, prototype);
  bindMethod<View, std::string, rehax::ui::DefaultValue, &View::setText, &View::setText>("setText", ctx, prototype);
  bindMethod<View, rehax::ui::Color, rehax::ui::DefaultValue, &View::setTextColor, &View::setTextColor>("setTextColor", ctx, prototype);
  bindMethod<View, float, rehax::ui::DefaultValue, &View::setFontSize, &View::setFontSize>("setFontSize", ctx, prototype);
}

template <typename View>
void bindTextInputClassMethods(JSContextRef ctx, JSObjectRef prototype) {
  bindMethod<View, std::string, rehax::ui::DefaultValue, &View::setValue, &View::setValue>("setValue", ctx, prototype);
  bindMethod<View, std::string, &View::getValue>("getValue", ctx, prototype);
}

template <typename View>
void bindVectorElementClassMethods(JSContextRef ctx, JSObjectRef prototype) {
  bindMethod<View, float, rehax::ui::DefaultValue, &View::setLineWidth, &View::setLineWidth>("setLineWidth", ctx, prototype);
  bindMethod<View, rehax::ui::VectorLineJoin, rehax::ui::DefaultValue, &View::setLineJoin, &View::setLineJoin>("setLineJoin", ctx, prototype);
  bindMethod<View, rehax::ui::VectorLineCap, rehax::ui::DefaultValue, &View::setLineCap, &View::setLineCap>("setLineCap", ctx, prototype);
  bindMethod<View, rehax::ui::Color, rehax::ui::DefaultValue, &View::setFillColor, &View::setFillColor>("setFillColor", ctx, prototype);
  bindMethod<View, rehax::ui::Color, rehax::ui::DefaultValue, &View::setStrokeColor, &View::setStrokeColor>("setStrokeColor", ctx, prototype);
  bindMethod<View, rehax::ui::Gradient, rehax::ui::DefaultValue, &View::setFillGradient, &View::setFillGradient>("setFillGradient", ctx, prototype);
  bindMethod<View, rehax::ui::Gradient, rehax::ui::DefaultValue, &View::setStrokeGradient, &View::setStrokeGradient>("setStrokeGradient", ctx, prototype);
  bindMethod<View, rehax::ui::Filters, rehax::ui::DefaultValue, &View::setFilters, &View::setFilters>("setFilters", ctx, prototype);
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
void Bindings::bindToJsc() {
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
    
  defineViewClass<StackLayout>(ctx, "StackLayout", nullptr);
  defineViewClass<FlexLayout>(ctx, "FlexLayout", nullptr);

  defineViewClass<View>(ctx, "View", nullptr);
  defineViewClass<Button>(ctx, "Button", classRegistry["View"].prototype);
  defineViewClass<Text>(ctx, "Text", classRegistry["View"].prototype);
  defineViewClass<TextInput>(ctx, "TextInput", classRegistry["View"].prototype);
  defineViewClass<VectorContainer>(ctx, "VectorContainer", classRegistry["View"].prototype);
  defineViewClass<VectorElement, false>(ctx, "VectorElement", classRegistry["View"].prototype);
  defineViewClass<VectorPath>(ctx, "VectorPath", classRegistry["VectorElement"].prototype);

  bindViewClassMethods<View, ILayout, Gesture>(ctx, classRegistry["View"].prototype);
  bindButtonClassMethods<Button>(ctx, classRegistry["Button"].prototype);
  bindTextClassMethods<Text>(ctx, classRegistry["Text"].prototype);
  bindTextInputClassMethods<TextInput>(ctx, classRegistry["TextInput"].prototype);
  bindVectorElementClassMethods<VectorElement>(ctx, classRegistry["VectorElement"].prototype);
  bindVectorPathClassMethods<VectorPath>(ctx, classRegistry["VectorPath"].prototype);

  bindStackLayoutClassMethods<StackLayout, View>(ctx, classRegistry["StackLayout"].prototype);
  bindFlexLayoutClassMethods<FlexLayout, View>(ctx, classRegistry["FlexLayout"].prototype);

  defineViewClass<Gesture>(ctx, "Gesture", nullptr);
  bindGestureClassMethods<Gesture>(ctx, classRegistry["Gesture"].prototype);

#if RHX_GEN_DOCS
  jscDocs.printJson();
  jscDocs.printMarkdown();
#endif
}


#ifdef REHAX_WITH_APPKIT
void Bindings::bindAppkitToJsc() {
  bindToJsc<
    rehax::ui::appkit::StackLayout,
    rehax::ui::appkit::FlexLayout,
    rehax::ui::appkit::View,
    rehax::ui::appkit::Button,
    rehax::ui::appkit::Text,
    rehax::ui::appkit::TextInput,
    rehax::ui::appkit::VectorContainer,
    rehax::ui::appkit::VectorElement,
    rehax::ui::appkit::VectorPath,
    rehax::ui::appkit::ILayout,
    rehax::ui::appkit::Gesture
  >();

#if RHX_GEN_DOCS
  jscDocs.printJson();
  jscDocs.printMarkdown();
#endif
}
#endif

#ifdef REHAX_WITH_FLUXE
void Bindings::bindFluxeToJsc() {
  bindToJsc<
    rehax::ui::fluxe::StackLayout,
    rehax::ui::fluxe::FlexLayout,
    rehax::ui::fluxe::View,
    rehax::ui::fluxe::Button,
    rehax::ui::fluxe::Text,
    rehax::ui::fluxe::TextInput,
    rehax::ui::fluxe::VectorContainer,
    rehax::ui::fluxe::VectorElement,
    rehax::ui::fluxe::VectorPath,
    rehax::ui::fluxe::ILayout,
    rehax::ui::fluxe::Gesture
  >();

#if RHX_GEN_DOCS
  jscDocs.printJson();
  jscDocs.printMarkdown();
#endif
    
}
#endif

}
}
