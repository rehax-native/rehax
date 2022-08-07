
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
