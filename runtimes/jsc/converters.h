
//template <typename T>
//struct Converter {
//  static JSValueRef toScript(JSContextRef ctx, T& value);
//  static T toCpp(JSContextRef ctx, const JSValueRef& value, Bindings * bindings);
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
    JSStringRelease(__className);

    return object;
  }
  static Object * toCpp(JSContextRef ctx, const JSValueRef& value, Bindings * bindings) {
    auto privateData = static_cast<ViewPrivateData<Object> *>(JSObjectGetPrivate((JSObjectRef) value));
    auto obj = privateData->view;
    return obj;
  }
};

template <>
struct Converter<std::string> {
  static JSValueRef toScript(JSContextRef ctx, std::string value, Bindings * bindings = nullptr) {
    JSStringRef jsText = JSStringCreateWithUTF8CString(value.c_str());
    JSValueRef val = (JSValueRef) JSValueMakeString(ctx, jsText);
    JSStringRelease(jsText);
    return val;
  }
  static std::string toCpp(JSContextRef ctx, const JSValueRef str, Bindings * bindings) {
    if (JSValueIsString(ctx, str)) {
      if (JSStringGetLength((JSStringRef) str) == 0) {
        return "";
      }
      JSStringRef strRef = JSValueToStringCopy(ctx, str, nullptr);
      size_t maxBufferSize = JSStringGetMaximumUTF8CStringSize(strRef);
      char* utf8Buffer = new char[maxBufferSize];
      // size_t bytesWritten = JSStringGetUTF8CString((JSStringRef) str, utf8Buffer, maxBufferSize);
      size_t bytesWritten = JSStringGetUTF8CString(strRef, utf8Buffer, maxBufferSize);
      utf8Buffer[bytesWritten] = '\0';
      std::string ret = std::string(utf8Buffer);
      delete [] utf8Buffer;
      JSStringRelease(strRef);
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
  static bool toCpp(JSContextRef ctx, const JSValueRef& value, Bindings * bindings) {
    return (bool) JSValueToBoolean(ctx, value);
  }
};

template <>
struct Converter<int> {
  static JSValueRef toScript(JSContextRef ctx, int value, Bindings * bindings = nullptr) {
      return JSValueMakeNumber(ctx, (double) value);
  }
  static int toCpp(JSContextRef ctx, const JSValueRef& value, Bindings * bindings) {
    return (int) JSValueToNumber(ctx, value, nullptr);
  }
};

template <>
struct Converter<uint32_t> {
  static JSValueRef toScript(JSContextRef ctx, uint32_t value, Bindings * bindings = nullptr) {
      return JSValueMakeNumber(ctx, (double) value);
  }
  static uint32_t toCpp(JSContextRef ctx, const JSValueRef& value, Bindings * bindings) {
    return (uint32_t) JSValueToNumber(ctx, value, nullptr);
  }
};

template <>
struct Converter<size_t> {
  static JSValueRef toScript(JSContextRef ctx, size_t value, Bindings * bindings = nullptr) {
      return JSValueMakeNumber(ctx, (double) value);
  }
  static size_t toCpp(JSContextRef ctx, const JSValueRef& value, Bindings * bindings) {
    return (size_t) JSValueToNumber(ctx, value, nullptr);
  }
};

template <>
struct Converter<float> {
  static JSValueRef toScript(JSContextRef ctx, float value, Bindings * bindings = nullptr) {
      return JSValueMakeNumber(ctx, (double) value);
  }
  static float toCpp(JSContextRef ctx, const JSValueRef& value, Bindings * bindings) {
    return (float) JSValueToNumber(ctx, value, nullptr);
  }
};

template <>
struct Converter<double> {
  static JSValueRef toScript(JSContextRef ctx, double value, Bindings * bindings = nullptr) {
      return JSValueMakeNumber(ctx, (double) value);
  }
  static double toCpp(JSContextRef ctx, const JSValueRef& value, Bindings * bindings) {
    return (double) JSValueToNumber(ctx, value, nullptr);
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
  ScriptFunctionContainer(JSContextRef ctx, JSObjectRef fn)
  :ctx(ctx), fn(fn)
  {
    JSValueProtect(ctx, fn);
  }

  ~ScriptFunctionContainer() {
    JSValueUnprotect(ctx, fn);
  }
  JSValueRef call(JSContextRef ctx, size_t numArgs, JSValueRef * args) {
//                auto exception = JSObjectMake(ctx, nullptr, nullptr);
    JSValueRef exception = nullptr;
    auto ret = JSObjectCallAsFunction(ctx, fn, NULL, numArgs, args, &exception);
      // if (exception != nullptr) {
      //     auto exMessage = JSObjectGetProperty(ctx, (JSObjectRef) exception, JSStringCreateWithUTF8CString("message"), nullptr);
      //     auto message = Bindings::JSStringToStdString(ctx, (JSStringRef) exMessage);
      //     std::cout << message << std::endl;
      // }
    return ret;
  }
private:
  JSContextRef ctx;
  JSObjectRef fn;
};

template <>
struct Converter<std::function<void(void)>> {
  static JSValueRef toScript(JSContextRef ctx, std::function<void(void)>&& value, Bindings * bindings = nullptr) {
    using FnType = std::function<void(void)>;
    using ContainerFnType = FunctionContainer<FnType>;
    auto fnPtr = rehaxUtils::Object<ContainerFnType>::Create();
    fnPtr->fn = value;
    if (!bindings->hasRegisteredClass(ContainerFnType::ClassName())) {
      bindings->defineClass<ContainerFnType>(ContainerFnType::ClassName(), nullptr);
    }
    auto jsFnContainer = Converter<ContainerFnType>::toScript(ctx, fnPtr.get(), bindings);
    JSStringRef methodName = JSStringCreateWithUTF8CString("fn");

    auto functionObject = JSObjectMakeFunctionWithCallback(ctx, methodName, [] (JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception) {
      JSStringRef fnContainer = JSStringCreateWithUTF8CString("__fnContainer");
      auto jsFnContainer = JSObjectGetProperty(ctx, function, fnContainer, nullptr);
      JSStringRelease(fnContainer);
      auto privateData = static_cast<ViewPrivateData<ContainerFnType> *>(JSObjectGetPrivate((JSObjectRef) jsFnContainer));
      auto fnPtr = Converter<ContainerFnType>::toCpp(ctx, jsFnContainer, privateData->bindings);
      fnPtr->fn();
      return JSValueMakeUndefined(ctx);
    });
    JSStringRelease(methodName);
    JSStringRef fnContainer = JSStringCreateWithUTF8CString("__fnContainer");
    JSObjectSetProperty(ctx, functionObject, fnContainer, jsFnContainer, kJSPropertyAttributeReadOnly | kJSPropertyAttributeDontEnum, nullptr);
    JSStringRelease(fnContainer);
    return functionObject;
  }
  static std::function<void(void)> toCpp(JSContextRef ctx, const JSValueRef& value, Bindings * bindings) {
    JSObjectRef callback = (JSObjectRef) value;
    rehaxUtils::ObjectPointer<ScriptFunctionContainer> fnPtr = rehaxUtils::Object<ScriptFunctionContainer>::Create(ctx, callback);
    auto fn = [ctx, fnPtr] () {
      fnPtr->call(ctx, 0, nullptr);
    };
    return fn;
  }
};

template <typename T1>
struct Converter<std::function<void(T1&)>> {
  static JSValueRef toScript(JSContextRef ctx, std::function<void(T1&)>&& value, Bindings * bindings = nullptr) {
    using FnType = std::function<void(T1)>;
    using ContainerFnType = FunctionContainer<FnType>;
    auto fnPtr = rehaxUtils::Object<ContainerFnType>::Create();
    fnPtr->fn = value;
    if (!bindings->hasRegisteredClass(ContainerFnType::ClassName())) {
      bindings->defineClass<ContainerFnType>(ContainerFnType::ClassName(), nullptr);
    }
    auto jsFnContainer = Converter<ContainerFnType>::toScript(ctx, fnPtr.get(), bindings);
    JSStringRef methodName = JSStringCreateWithUTF8CString("fn");

    auto functionObject = JSObjectMakeFunctionWithCallback(ctx, methodName, [] (JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception) {
      JSStringRef fnContainer = JSStringCreateWithUTF8CString("__fnContainer");
      auto jsFnContainer = JSObjectGetProperty(ctx, function, fnContainer, nullptr);
      JSStringRelease(fnContainer);
      auto privateData = static_cast<ViewPrivateData<ContainerFnType> *>(JSObjectGetPrivate((JSObjectRef) jsFnContainer));
      auto fnPtr = Converter<ContainerFnType>::toCpp(ctx, jsFnContainer, privateData->bindings);
      fnPtr->fn(
        Converter<T1>::toCpp(ctx, arguments[0], privateData->bindings)
      );
      return JSValueMakeUndefined(ctx);
    });
    JSStringRelease(methodName);
    JSStringRef fnContainer = JSStringCreateWithUTF8CString("__fnContainer");
    JSObjectSetProperty(ctx, functionObject, fnContainer, jsFnContainer, kJSPropertyAttributeReadOnly | kJSPropertyAttributeDontEnum, nullptr);
    JSStringRelease(fnContainer);
    return functionObject;
  }
  static std::function<void(T1&)> toCpp(JSContextRef ctx, const JSValueRef& value, Bindings * bindings) {
    JSObjectRef callback = (JSObjectRef) value;
    rehaxUtils::ObjectPointer<ScriptFunctionContainer> fnPtr = rehaxUtils::Object<ScriptFunctionContainer>::Create(ctx, callback);
    auto fn = [ctx, fnPtr, bindings] (T1 & a) {
      JSValueRef arguments[] = {
        Converter<T1>::toScript(ctx, a, bindings),
      };
      fnPtr->call(ctx, 1, arguments);
      a = Converter<T1>::toCpp(ctx, arguments[0], bindings);
    };
    return fn;
  }
};

template <typename T1>
struct Converter<std::function<void(T1)>> {
  static JSValueRef toScript(JSContextRef ctx, std::function<void(T1)>&& value, Bindings * bindings = nullptr) {
    using FnType = std::function<void(T1)>;
    using ContainerFnType = FunctionContainer<FnType>;
    auto fnPtr = rehaxUtils::Object<ContainerFnType>::Create();
    fnPtr->fn = value;
    if (!bindings->hasRegisteredClass(ContainerFnType::ClassName())) {
      bindings->defineClass<ContainerFnType>(ContainerFnType::ClassName(), nullptr);
    }
    auto jsFnContainer = Converter<ContainerFnType>::toScript(ctx, fnPtr.get(), bindings);
    JSStringRef methodName = JSStringCreateWithUTF8CString("fn");

    auto functionObject = JSObjectMakeFunctionWithCallback(ctx, methodName, [] (JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception) {
      JSStringRef fnContainer = JSStringCreateWithUTF8CString("__fnContainer");
      auto jsFnContainer = JSObjectGetProperty(ctx, function, fnContainer, nullptr);
      JSStringRelease(fnContainer);
      auto privateData = static_cast<ViewPrivateData<ContainerFnType> *>(JSObjectGetPrivate((JSObjectRef) jsFnContainer));
      auto fnPtr = Converter<ContainerFnType>::toCpp(ctx, jsFnContainer, privateData->bindings);
      fnPtr->fn(
        Converter<T1>::toCpp(ctx, arguments[0], privateData->bindings)
      );
      return JSValueMakeUndefined(ctx);
    });
    JSStringRelease(methodName);
    JSStringRef fnContainer = JSStringCreateWithUTF8CString("__fnContainer");
    JSObjectSetProperty(ctx, functionObject, fnContainer, jsFnContainer, kJSPropertyAttributeReadOnly | kJSPropertyAttributeDontEnum, nullptr);
    JSStringRelease(fnContainer);
    return functionObject;
  }
  static std::function<void(T1)> toCpp(JSContextRef ctx, const JSValueRef& value, Bindings * bindings) {
    JSObjectRef callback = (JSObjectRef) value;
    rehaxUtils::ObjectPointer<ScriptFunctionContainer> fnPtr = rehaxUtils::Object<ScriptFunctionContainer>::Create(ctx, callback);
    auto fn = [ctx, fnPtr, bindings] (T1 a) {
      JSValueRef arguments[] = {
        Converter<T1>::toScript(ctx, a, bindings),
      };
      fnPtr->call(ctx, 1, arguments);
    };
    return fn;
  }
};

template <typename T1, typename T2>
struct Converter<std::function<void(T1, T2)>> {
  static JSValueRef toScript(JSContextRef ctx, std::function<void(T1, T2)> value, Bindings * bindings = nullptr) {
    using FnType = std::function<void(T1, T2)>;
    using ContainerFnType = FunctionContainer<FnType>;
    auto fnPtr = rehaxUtils::Object<ContainerFnType>::Create();
    fnPtr->fn = value;
    if (!bindings->hasRegisteredClass(ContainerFnType::ClassName())) {
      bindings->defineClass<ContainerFnType>(ContainerFnType::ClassName(), nullptr);
    }
    auto jsFnContainer = Converter<ContainerFnType>::toScript(ctx, fnPtr.get(), bindings);
    JSStringRef methodName = JSStringCreateWithUTF8CString("fn");

    auto functionObject = JSObjectMakeFunctionWithCallback(ctx, methodName, [] (JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception) {
      JSStringRef fnContainer = JSStringCreateWithUTF8CString("__fnContainer");
      auto jsFnContainer = JSObjectGetProperty(ctx, function, fnContainer, nullptr);
      JSStringRelease(fnContainer);
      auto privateData = static_cast<ViewPrivateData<ContainerFnType> *>(JSObjectGetPrivate((JSObjectRef) jsFnContainer));
      auto fnPtr = Converter<ContainerFnType>::toCpp(ctx, jsFnContainer, privateData->bindings);
      fnPtr->fn(
        Converter<T1>::toCpp(ctx, arguments[0], privateData->bindings),
        Converter<T2>::toCpp(ctx, arguments[1], privateData->bindings)
      );
      return JSValueMakeUndefined(ctx);
    });
    JSStringRelease(methodName);
    JSStringRef fnContainer = JSStringCreateWithUTF8CString("__fnContainer");
    JSObjectSetProperty(ctx, functionObject, fnContainer, jsFnContainer, kJSPropertyAttributeReadOnly | kJSPropertyAttributeDontEnum, nullptr);
    JSStringRelease(fnContainer);
    return functionObject;
  }
  static std::function<void(T1, T2)> toCpp(JSContextRef ctx, const JSValueRef& value, Bindings * bindings) {
    JSObjectRef callback = (JSObjectRef) value;
    rehaxUtils::ObjectPointer<ScriptFunctionContainer> fnPtr = rehaxUtils::Object<ScriptFunctionContainer>::Create(ctx, callback);
    auto fn = [ctx, bindings, fnPtr] (T1 a, T2 b) {
      JSValueRef arguments[] = {
        Converter<T1>::toScript(ctx, a, bindings),
        Converter<T2>::toScript(ctx, b, bindings),
      };
      fnPtr->call(ctx, 2, arguments);
    };
    return fn;
  }
};

template <typename T1, typename T2, typename T3>
struct Converter<std::function<void(T1, T2, T3)>> {
  static JSValueRef toScript(JSContextRef ctx, std::function<void(T1, T2, T3)>&& value, Bindings * bindings = nullptr) {
    using FnType = std::function<void(T1, T2, T3)>;
    using ContainerFnType = FunctionContainer<FnType>;
    auto fnPtr = rehaxUtils::Object<ContainerFnType>::Create();
    fnPtr->fn = value;
    if (!bindings->hasRegisteredClass(ContainerFnType::ClassName())) {
      bindings->defineClass<ContainerFnType>(ContainerFnType::ClassName(), nullptr);
    }
    auto jsFnContainer = Converter<ContainerFnType>::toScript(ctx, fnPtr.get(), bindings);
    JSStringRef methodName = JSStringCreateWithUTF8CString("fn");

    auto functionObject = JSObjectMakeFunctionWithCallback(ctx, methodName, [] (JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception) {
      JSStringRef fnContainer = JSStringCreateWithUTF8CString("__fnContainer");
      auto jsFnContainer = JSObjectGetProperty(ctx, function, fnContainer, nullptr);
      JSStringRelease(fnContainer);
      auto privateData = static_cast<ViewPrivateData<ContainerFnType> *>(JSObjectGetPrivate((JSObjectRef) jsFnContainer));
      auto fnPtr = Converter<ContainerFnType>::toCpp(ctx, jsFnContainer, privateData->bindings);
      fnPtr->fn(
        Converter<T1>::toCpp(ctx, arguments[0], privateData->bindings),
        Converter<T2>::toCpp(ctx, arguments[1], privateData->bindings),
        Converter<T3>::toCpp(ctx, arguments[2], privateData->bindings)
      );
      return JSValueMakeUndefined(ctx);
    });
    JSStringRelease(methodName);
    JSStringRef fnContainer = JSStringCreateWithUTF8CString("__fnContainer");
    JSObjectSetProperty(ctx, functionObject, fnContainer, jsFnContainer, kJSPropertyAttributeReadOnly | kJSPropertyAttributeDontEnum, nullptr);
    JSStringRelease(fnContainer);
    return functionObject;
  }
  static std::function<void(T1, T2, T3)> toCpp(JSContextRef ctx, const JSValueRef& value, Bindings * bindings) {
    JSObjectRef callback = (JSObjectRef) value;
    rehaxUtils::ObjectPointer<ScriptFunctionContainer> fnPtr = rehaxUtils::Object<ScriptFunctionContainer>::Create(ctx, callback);
    auto fn = [ctx, fnPtr] (T1 a, T2 b, T3 c) {
      JSValueRef arguments[] = {
        Converter<T1>::toScript(ctx, a),
        Converter<T2>::toScript(ctx, b),
        Converter<T3>::toScript(ctx, c),
      };
      fnPtr->call(ctx, 3, arguments);
    };
    return fn;
  }
};

template <typename R1>
struct Converter<std::function<R1(void)>> {
  static JSValueRef toScript(JSContextRef ctx, std::function<R1(void)> value, Bindings * bindings = nullptr) {
    using FnType = std::function<R1(void)>;
    using ContainerFnType = FunctionContainer<FnType>;
    auto fnPtr = rehaxUtils::Object<ContainerFnType>::Create();
    fnPtr->fn = value;
    if (!bindings->hasRegisteredClass(ContainerFnType::ClassName())) {
      bindings->defineClass<ContainerFnType>(ContainerFnType::ClassName(), nullptr);
    }
    auto jsFnContainer = Converter<ContainerFnType>::toScript(ctx, fnPtr.get(), bindings);
    JSStringRef methodName = JSStringCreateWithUTF8CString("fn");

    auto functionObject = JSObjectMakeFunctionWithCallback(ctx, methodName, [] (JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception) {
      JSStringRef fnContainer = JSStringCreateWithUTF8CString("__fnContainer");
      auto jsFnContainer = JSObjectGetProperty(ctx, function, fnContainer, nullptr);
      JSStringRelease(fnContainer);
      auto privateData = static_cast<ViewPrivateData<ContainerFnType> *>(JSObjectGetPrivate((JSObjectRef) jsFnContainer));
      auto fnPtr = Converter<ContainerFnType>::toCpp(ctx, jsFnContainer, privateData->bindings);
      auto ret = fnPtr->fn();
      return Converter<R1>::toScript(ctx, ret, privateData->bindings);
    });
    JSStringRelease(methodName);
    JSStringRef fnContainer = JSStringCreateWithUTF8CString("__fnContainer");
    JSObjectSetProperty(ctx, functionObject, fnContainer, jsFnContainer, kJSPropertyAttributeReadOnly | kJSPropertyAttributeDontEnum, nullptr);
    JSStringRelease(fnContainer);
    return functionObject;
  }
  static std::function<R1(void)> toCpp(JSContextRef ctx, const JSValueRef& value, Bindings * bindings) {
    JSObjectRef callback = (JSObjectRef) value;
    rehaxUtils::ObjectPointer<ScriptFunctionContainer> fnPtr = rehaxUtils::Object<ScriptFunctionContainer>::Create(ctx, callback);
    auto fn = [ctx, fnPtr, bindings] () {
      auto ret = fnPtr->call(ctx, 0, nullptr);
      return Converter<R1>::toCpp(ctx, ret, bindings);
    };
    return fn;
  }
};

template <typename R1, typename T1>
struct Converter<std::function<R1(T1)>> {
  static JSValueRef toScript(JSContextRef ctx, std::function<R1(T1)> value, Bindings * bindings = nullptr) {
    using FnType = std::function<R1(T1)>;
    using ContainerFnType = FunctionContainer<FnType>;
    auto fnPtr = rehaxUtils::Object<ContainerFnType>::Create();
    fnPtr->fn = value;
    if (!bindings->hasRegisteredClass(ContainerFnType::ClassName())) {
      bindings->defineClass<ContainerFnType>(ContainerFnType::ClassName(), nullptr);
    }
    auto jsFnContainer = Converter<ContainerFnType>::toScript(ctx, fnPtr.get(), bindings);
    JSStringRef methodName = JSStringCreateWithUTF8CString("fn");

    auto functionObject = JSObjectMakeFunctionWithCallback(ctx, methodName, [] (JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception) {
      JSStringRef fnContainer = JSStringCreateWithUTF8CString("__fnContainer");
      auto jsFnContainer = JSObjectGetProperty(ctx, function, fnContainer, nullptr);
      JSStringRelease(fnContainer);
      auto privateData = static_cast<ViewPrivateData<ContainerFnType> *>(JSObjectGetPrivate((JSObjectRef) jsFnContainer));
      auto fnPtr = Converter<ContainerFnType>::toCpp(ctx, jsFnContainer, privateData->bindings);
      auto ret = fnPtr->fn(
        Converter<T1>::toCpp(ctx, arguments[0], privateData->bindings)
      );
      return Converter<R1>::toScript(ctx, ret, privateData->bindings);
    });
    JSStringRelease(methodName);
    JSStringRef fnContainer = JSStringCreateWithUTF8CString("__fnContainer");
    JSObjectSetProperty(ctx, functionObject, fnContainer, jsFnContainer, kJSPropertyAttributeReadOnly | kJSPropertyAttributeDontEnum, nullptr);
    JSStringRelease(fnContainer);
    return functionObject;
  }
  static std::function<R1(T1)> toCpp(JSContextRef ctx, const JSValueRef& value, Bindings * bindings) {
    JSObjectRef callback = (JSObjectRef) value;
    rehaxUtils::ObjectPointer<ScriptFunctionContainer> fnPtr = rehaxUtils::Object<ScriptFunctionContainer>::Create(ctx, callback);
    auto fn = [ctx, fnPtr, bindings] (T1 a) {
      JSValueRef arguments[] = {
        Converter<T1>::toScript(ctx, a),
      };
      auto ret = fnPtr->call(ctx, 1, arguments);
      return Converter<R1>::toCpp(ctx, ret, bindings);
    };
    return fn;
  }
};

template <typename R1, typename T1, typename T2>
struct Converter<std::function<R1(T1, T2)>> {
  static JSValueRef toScript(JSContextRef ctx, std::function<R1(T1, T2)>&& value, Bindings * bindings = nullptr) {
    using FnType = std::function<R1(T1, T2)>;
    using ContainerFnType = FunctionContainer<FnType>;
    auto fnPtr = rehaxUtils::Object<ContainerFnType>::Create();
    fnPtr->fn = value;
    if (!bindings->hasRegisteredClass(ContainerFnType::ClassName())) {
      bindings->defineClass<ContainerFnType>(ContainerFnType::ClassName(), nullptr);
    }
    auto jsFnContainer = Converter<ContainerFnType>::toScript(ctx, fnPtr.get(), bindings);
    JSStringRef methodName = JSStringCreateWithUTF8CString("fn");

    auto functionObject = JSObjectMakeFunctionWithCallback(ctx, methodName, [] (JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception) {
      JSStringRef fnContainer = JSStringCreateWithUTF8CString("__fnContainer");
      auto jsFnContainer = JSObjectGetProperty(ctx, function, fnContainer, nullptr);
      JSStringRelease(fnContainer);
      auto privateData = static_cast<ViewPrivateData<ContainerFnType> *>(JSObjectGetPrivate((JSObjectRef) jsFnContainer));
      auto fnPtr = Converter<ContainerFnType>::toCpp(ctx, jsFnContainer, privateData->bindings);
      auto ret = fnPtr->fn(
        Converter<T1>::toCpp(ctx, arguments[0], privateData->bindings),
        Converter<T2>::toCpp(ctx, arguments[1], privateData->bindings)
      );
      return Converter<R1>::toScript(ctx, ret, privateData->bindings);
    });
    JSStringRelease(methodName);
    JSStringRef fnContainer = JSStringCreateWithUTF8CString("__fnContainer");
    JSObjectSetProperty(ctx, functionObject, fnContainer, jsFnContainer, kJSPropertyAttributeReadOnly | kJSPropertyAttributeDontEnum, nullptr);
    JSStringRelease(fnContainer);
    return functionObject;
  }
  static std::function<R1(T1, T2)> toCpp(JSContextRef ctx, const JSValueRef& value, Bindings * bindings) {
    JSObjectRef callback = (JSObjectRef) value;
    rehaxUtils::ObjectPointer<ScriptFunctionContainer> fnPtr = rehaxUtils::Object<ScriptFunctionContainer>::Create(ctx, callback);
    auto fn = [ctx, fnPtr, bindings] (T1 a, T2 b) {
      JSValueRef arguments[] = {
        Converter<T1>::toScript(ctx, a),
        Converter<T2>::toScript(ctx, b),
      };
      auto ret = fnPtr->call(ctx, 2, arguments);
      return Converter<R1>::toCpp(ctx, ret, bindings);
    };
    return fn;
  }
};

template <typename R1, typename T1, typename T2, typename T3>
struct Converter<std::function<R1(T1, T2, T3)>> {
  static JSValueRef toScript(JSContextRef ctx, std::function<R1(void)>&& value, Bindings * bindings = nullptr) {
    using FnType = std::function<R1(T1, T2, T3)>;
    using ContainerFnType = FunctionContainer<FnType>;
    auto fnPtr = rehaxUtils::Object<ContainerFnType>::Create();
    fnPtr->fn = value;
    if (!bindings->hasRegisteredClass(ContainerFnType::ClassName())) {
      bindings->defineClass<ContainerFnType>(ContainerFnType::ClassName(), nullptr);
    }
    auto jsFnContainer = Converter<ContainerFnType>::toScript(ctx, fnPtr.get(), bindings);
    JSStringRef methodName = JSStringCreateWithUTF8CString("fn");

    auto functionObject = JSObjectMakeFunctionWithCallback(ctx, methodName, [] (JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception) {
      JSStringRef fnContainer = JSStringCreateWithUTF8CString("__fnContainer");
      auto jsFnContainer = JSObjectGetProperty(ctx, function, fnContainer, nullptr);
      JSStringRelease(fnContainer);
      auto privateData = static_cast<ViewPrivateData<ContainerFnType> *>(JSObjectGetPrivate((JSObjectRef) jsFnContainer));
      auto fnPtr = Converter<ContainerFnType>::toCpp(ctx, jsFnContainer, privateData->bindings);
      auto ret = fnPtr->fn(
        Converter<T1>::toCpp(ctx, arguments[0], privateData->bindings),
        Converter<T2>::toCpp(ctx, arguments[1], privateData->bindings),
        Converter<T3>::toCpp(ctx, arguments[2], privateData->bindings)
      );
      return Converter<R1>::toScript(ctx, ret, privateData->bindings);
    });
    JSStringRelease(methodName);
    JSStringRef fnContainer = JSStringCreateWithUTF8CString("__fnContainer");
    JSObjectSetProperty(ctx, functionObject, fnContainer, jsFnContainer, kJSPropertyAttributeReadOnly | kJSPropertyAttributeDontEnum, nullptr);
    JSStringRelease(fnContainer);
    return functionObject;
  }
  static std::function<R1(T1, T2, T3)> toCpp(JSContextRef ctx, const JSValueRef& value, Bindings * bindings) {
    JSObjectRef callback = (JSObjectRef) value;
    rehaxUtils::ObjectPointer<ScriptFunctionContainer> fnPtr = rehaxUtils::Object<ScriptFunctionContainer>::Create(ctx, callback);
    auto fn = [ctx, fnPtr, bindings] (T1 a, T2 b, T3 c) {
      JSValueRef arguments[] = {
        Converter<T1>::toScript(ctx, a),
        Converter<T2>::toScript(ctx, b),
        Converter<T3>::toScript(ctx, c),
      };
      auto ret = fnPtr->call(ctx, 3, arguments);
      return Converter<R1>::toCpp(ctx, ret, bindings);
    };
    return fn;
  }
};

#include "../common/converters.h"
