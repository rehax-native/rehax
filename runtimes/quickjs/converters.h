
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

template <>
struct Converter<std::function<void(void)>> {
  static JSValue toScript(JSContext * ctx, std::function<void(void)>&& value, Bindings * bindings = nullptr) {
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

template <typename T1>
struct Converter<std::function<void(T1)>> {
  static JSValue toScript(JSContext * ctx, std::function<void(float, float)>&& value, Bindings * bindings = nullptr) {
      // TODO
      return JS_UNDEFINED;
  }
  static std::function<void(T1)> toCpp(JSContext * ctx, const JSValue& value, Bindings * bindings, std::vector<JSValue>& retainedValues) {
    JSValue duped = JS_DupValue(ctx, value);
    retainedValues.push_back(duped);
    auto fn = [ctx, duped] (T1 x) {
      JSValue args[] = {
        Converter<T1>::toScript(ctx, x),
      };
      JS_Call(ctx, duped, JS_NULL, 1, args);
    };
    return fn;
  }
};

template <typename T1, typename T2>
struct Converter<std::function<void(T1, T2)>> {
  static JSValue toScript(JSContext * ctx, std::function<void(T1, T2)>&& value, Bindings * bindings = nullptr) {
      // TODO
      return JS_UNDEFINED;
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
  static JSValue toScript(JSContext * ctx, std::function<void(T1, T2)>&& value, Bindings * bindings = nullptr) {
      // TODO
      return JS_UNDEFINED;
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
  static JSValue toScript(JSContext * ctx, std::function<R1(void)>&& value, Bindings * bindings = nullptr) {
      // TODO
      return JS_UNDEFINED;
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

#include "../common/converters.h"
