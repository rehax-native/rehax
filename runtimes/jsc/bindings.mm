#include "./bindings.h"

#define RHX_GEN_DOCS 1

#if RHX_GEN_DOCS
#include "../docs.h"
rehax::docs::Docs<rehax::ui::appkit::View> jscDocs("JavascriptCore");
#endif

namespace rehax {
namespace jsc {

template <typename T>
struct Converter {
  static JSValueRef toScript(JSContextRef ctx, T& value);
  static T toCpp(JSContextRef ctx, const JSValueRef& value, Bindings * bindings, std::vector<JSValueRef>& retainedValues);
};

template <>
struct Converter<std::string> {
  static JSValueRef toScript(JSContextRef ctx, std::string& value) {
    JSStringRef jsText = JSStringCreateWithUTF8CString(value.c_str());
    return (JSValueRef) jsText;
  }
  static std::string toCpp(JSContextRef ctx, const JSValueRef str, Bindings * bindings, std::vector<JSValueRef>& retainedValues) {
    size_t maxBufferSize = JSStringGetMaximumUTF8CStringSize((JSStringRef) str);
    char* utf8Buffer = new char[maxBufferSize];
    size_t bytesWritten = JSStringGetUTF8CString((JSStringRef) str, utf8Buffer, maxBufferSize);
    utf8Buffer[bytesWritten] = '\0';
    std::string ret = std::string(utf8Buffer);
    delete [] utf8Buffer;
    return ret;
  }
};

//template <typename T>
//struct Converter<std::vector<T>> {
//  static JSValueRef toScript(JSContextRef ctx, std::vector<T>& value) {
//    return JSValueMakeBoolean(ctx, value);
//  }
//  static std::vector<T> toCpp(JSContextRef ctx, const JSValueRef& value, Bindings * bindings, std::vector<JSValueRef>& retainedValues) {
//    std::vector<T> arr;
//    return arr;
//  }
//};

template <>
struct Converter<bool> {
  static JSValueRef toScript(JSContextRef ctx, bool& value) {
    return JSValueMakeBoolean(ctx, value);
  }
  static bool toCpp(JSContextRef ctx, const JSValueRef& value, Bindings * bindings, std::vector<JSValueRef>& retainedValues) {
    return (bool) JSValueToBoolean(ctx, value);
  }
};

template <>
struct Converter<int> {
  static JSValueRef toScript(JSContextRef ctx, int& value) {
      return JSValueMakeNumber(ctx, (double) value);
  }
  static int toCpp(JSContextRef ctx, const JSValueRef& value, Bindings * bindings, std::vector<JSValueRef>& retainedValues) {
    return (int) JSValueToNumber(ctx, value, nullptr);
  }
};

template <>
struct Converter<float> {
  static JSValueRef toScript(JSContextRef ctx, float& value) {
      return JSValueMakeNumber(ctx, (double) value);
  }
  static float toCpp(JSContextRef ctx, const JSValueRef& value, Bindings * bindings, std::vector<JSValueRef>& retainedValues) {
    return (float) JSValueToNumber(ctx, value, nullptr);
  }
};

template <>
struct Converter<double> {
  static JSValueRef toScript(JSContextRef ctx, double& value) {
      return JSValueMakeNumber(ctx, (double) value);
  }
  static double toCpp(JSContextRef ctx, const JSValueRef& value, Bindings * bindings, std::vector<JSValueRef>& retainedValues) {
    return (double) JSValueToNumber(ctx, value, nullptr);
  }
};

template <>
struct Converter<rehax::ui::Color> {
  static JSValueRef toScript(JSContextRef ctx, rehax::ui::Color& value) {
    JSObjectRef object = JSObjectMake(ctx, nullptr, nullptr);
    auto propName = JSStringCreateWithUTF8CString("red");
    JSObjectSetProperty(ctx, object, propName, JSValueMakeNumber(ctx, value.r * 255.0), kJSPropertyAttributeNone, nullptr);
    propName = JSStringCreateWithUTF8CString("green");
    JSObjectSetProperty(ctx, object, propName, JSValueMakeNumber(ctx, value.g * 255.0), kJSPropertyAttributeNone, nullptr);
    propName = JSStringCreateWithUTF8CString("blue");
    JSObjectSetProperty(ctx, object, propName, JSValueMakeNumber(ctx, value.b * 255.0), kJSPropertyAttributeNone, nullptr);
    propName = JSStringCreateWithUTF8CString("alpha");
    JSObjectSetProperty(ctx, object, propName, JSValueMakeNumber(ctx, value.a), kJSPropertyAttributeNone, nullptr);
    return (JSValueRef) object;
  }
  static rehax::ui::Color toCpp(JSContextRef ctx, const JSValueRef& colorValue, Bindings * bindings, std::vector<JSValueRef>& retainedValues) {
    auto propName = JSStringCreateWithUTF8CString("red");
    auto r = JSValueToNumber(ctx, JSObjectGetProperty(ctx, (JSObjectRef) colorValue, propName, NULL), NULL);
    propName = JSStringCreateWithUTF8CString("green");
    auto g = JSValueToNumber(ctx, JSObjectGetProperty(ctx, (JSObjectRef) colorValue, propName, NULL), NULL);
    propName = JSStringCreateWithUTF8CString("blue");
    auto b = JSValueToNumber(ctx, JSObjectGetProperty(ctx, (JSObjectRef) colorValue, propName, NULL), NULL);
    propName = JSStringCreateWithUTF8CString("alpha");
    auto a = JSValueToNumber(ctx, JSObjectGetProperty(ctx, (JSObjectRef) colorValue, propName, NULL), NULL);
    return ui::Color::RGBA(r/255.0, g/255.0, b/255.0, a);
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

template <>
struct Converter<rehax::ui::appkit::StackLayoutDirection> {
  static JSValueRef toScript(JSContextRef ctx, rehax::ui::appkit::StackLayoutDirection& value) {
    if (value == ui::appkit::StackLayoutDirection::Vertical) {
      return JSValueMakeString(ctx, JSStringCreateWithUTF8CString("Vertical"));
    }
    if (value == ui::appkit::StackLayoutDirection::Horizontal) {
      return JSValueMakeString(ctx, JSStringCreateWithUTF8CString("Horizontal"));
    }
  }
  static rehax::ui::appkit::StackLayoutDirection toCpp(JSContextRef ctx, const JSValueRef& value, Bindings * bindings, std::vector<JSValueRef>& retainedValues) {
    if (JSStringIsEqual(JSStringCreateWithUTF8CString("Horizontal"), (JSStringRef) value)) {
      return ui::appkit::StackLayoutDirection::Horizontal;
    }
    return ui::appkit::StackLayoutDirection::Vertical;
  }
};

template <>
struct Converter<rehax::ui::appkit::StackLayoutOptions> {
  static JSValueRef toScript(JSContextRef ctx, rehax::ui::appkit::StackLayoutOptions& value) {
    auto obj = JSObjectMake(ctx, nullptr, nullptr);
    JSObjectSetProperty(ctx, obj, JSStringCreateWithUTF8CString("spacing"), Converter<float>::toScript(ctx, value.spacing), kJSPropertyAttributeNone, nullptr);
    JSObjectSetProperty(ctx, obj, JSStringCreateWithUTF8CString("direction"), Converter<rehax::ui::appkit::StackLayoutDirection>::toScript(ctx, value.direction), kJSPropertyAttributeNone, nullptr);
    return obj;
  }
  static rehax::ui::appkit::StackLayoutOptions toCpp(JSContextRef ctx, const JSValueRef& value, Bindings * bindings, std::vector<JSValueRef>& retainedValues) {
    rehax::ui::appkit::StackLayoutOptions options;
    if (JSObjectHasProperty(ctx, (JSObjectRef) value, JSStringCreateWithUTF8CString("spacing"))) {
      options.spacing = Converter<float>::toCpp(ctx, JSObjectGetProperty(ctx, (JSObjectRef) value, JSStringCreateWithUTF8CString("spacing"), nullptr), bindings, retainedValues);
    }
    if (JSObjectHasProperty(ctx, (JSObjectRef) value, JSStringCreateWithUTF8CString("direction"))) {
      options.direction = Converter<rehax::ui::appkit::StackLayoutDirection>::toCpp(ctx, JSObjectGetProperty(ctx, (JSObjectRef) value, JSStringCreateWithUTF8CString("direction"), nullptr), bindings, retainedValues);
    }
    return options;
  }
};

template <>
struct Converter<rehax::ui::appkit::FlexLayoutDirection> {
  static JSValueRef toScript(JSContextRef ctx, rehax::ui::appkit::FlexLayoutDirection& value) {
    if (value == ui::appkit::FlexLayoutDirection::Column) {
      return JSValueMakeString(ctx, JSStringCreateWithUTF8CString("Column"));
    }
    if (value == ui::appkit::FlexLayoutDirection::ColumnReverse) {
      return JSValueMakeString(ctx, JSStringCreateWithUTF8CString("ColumnReverse"));
    }
    if (value == ui::appkit::FlexLayoutDirection::Row) {
      return JSValueMakeString(ctx, JSStringCreateWithUTF8CString("Row"));
    }
    if (value == ui::appkit::FlexLayoutDirection::RowReverse) {
      return JSValueMakeString(ctx, JSStringCreateWithUTF8CString("RowReverse"));
    }
  }
  static rehax::ui::appkit::FlexLayoutDirection toCpp(JSContextRef ctx, const JSValueRef& value, Bindings * bindings, std::vector<JSValueRef>& retainedValues) {
    if (JSStringIsEqual(JSStringCreateWithUTF8CString("Column"), (JSStringRef) value)) {
      return ui::appkit::FlexLayoutDirection::Column;
    }
    if (JSStringIsEqual(JSStringCreateWithUTF8CString("ColumnReverse"), (JSStringRef) value)) {
      return ui::appkit::FlexLayoutDirection::ColumnReverse;
    }
    if (JSStringIsEqual(JSStringCreateWithUTF8CString("RowReverse"), (JSStringRef) value)) {
      return ui::appkit::FlexLayoutDirection::RowReverse;
    }
    return ui::appkit::FlexLayoutDirection::Row;
  }
};

template <>
struct Converter<rehax::ui::appkit::FlexJustifyContent> {
  static JSValueRef toScript(JSContextRef ctx, rehax::ui::appkit::FlexJustifyContent& value) {
    if (value == ui::appkit::FlexJustifyContent::FlexStart) {
      return JSValueMakeString(ctx, JSStringCreateWithUTF8CString("FlexStart"));
    }
    if (value == ui::appkit::FlexJustifyContent::FlexEnd) {
      return JSValueMakeString(ctx, JSStringCreateWithUTF8CString("FlexEnd"));
    }
    if (value == ui::appkit::FlexJustifyContent::Center) {
      return JSValueMakeString(ctx, JSStringCreateWithUTF8CString("Center"));
    }
  }
  static rehax::ui::appkit::FlexJustifyContent toCpp(JSContextRef ctx, const JSValueRef& value, Bindings * bindings, std::vector<JSValueRef>& retainedValues) {
    if (JSStringIsEqual(JSStringCreateWithUTF8CString("FlexEnd"), (JSStringRef) value)) {
      return ui::appkit::FlexJustifyContent::FlexEnd;
    }
    if (JSStringIsEqual(JSStringCreateWithUTF8CString("Center"), (JSStringRef) value)) {
      return ui::appkit::FlexJustifyContent::Center;
    }
    return ui::appkit::FlexJustifyContent::FlexStart;
  }
};

template <>
struct Converter<rehax::ui::appkit::FlexAlignItems> {
  static JSValueRef toScript(JSContextRef ctx, rehax::ui::appkit::FlexAlignItems& value) {
    if (value == ui::appkit::FlexAlignItems::FlexStart) {
      return JSValueMakeString(ctx, JSStringCreateWithUTF8CString("FlexStart"));
    }
    if (value == ui::appkit::FlexAlignItems::FlexEnd) {
      return JSValueMakeString(ctx, JSStringCreateWithUTF8CString("FlexEnd"));
    }
    if (value == ui::appkit::FlexAlignItems::Center) {
      return JSValueMakeString(ctx, JSStringCreateWithUTF8CString("Center"));
    }
  }
  static rehax::ui::appkit::FlexAlignItems toCpp(JSContextRef ctx, const JSValueRef& value, Bindings * bindings, std::vector<JSValueRef>& retainedValues) {
    if (JSStringIsEqual(JSStringCreateWithUTF8CString("FlexEnd"), (JSStringRef) value)) {
      return ui::appkit::FlexAlignItems::FlexEnd;
    }
    if (JSStringIsEqual(JSStringCreateWithUTF8CString("Center"), (JSStringRef) value)) {
      return ui::appkit::FlexAlignItems::Center;
    }
    return ui::appkit::FlexAlignItems::FlexStart;
  }
};

template <>
struct Converter<rehax::ui::appkit::impl::FlexItem> {
  static JSValueRef toScript(JSContextRef ctx, rehax::ui::appkit::impl::FlexItem& value) {
    auto obj = JSObjectMake(ctx, nullptr, nullptr);
    JSObjectSetProperty(ctx, obj, JSStringCreateWithUTF8CString("flexGrow"), Converter<float>::toScript(ctx, value.flexGrow), kJSPropertyAttributeNone, nullptr);
    JSObjectSetProperty(ctx, obj, JSStringCreateWithUTF8CString("hasFlexGrow"), Converter<bool>::toScript(ctx, value.hasFlexGrow), kJSPropertyAttributeNone, nullptr);
    JSObjectSetProperty(ctx, obj, JSStringCreateWithUTF8CString("order"), Converter<int>::toScript(ctx, value.order), kJSPropertyAttributeNone, nullptr);
    JSObjectSetProperty(ctx, obj, JSStringCreateWithUTF8CString("alignSelf"), Converter<rehax::ui::appkit::FlexAlignItems>::toScript(ctx, value.alignSelf), kJSPropertyAttributeNone, nullptr);
    return obj;
  }
  static rehax::ui::appkit::impl::FlexItem toCpp(JSContextRef ctx, const JSValueRef& value, Bindings * bindings, std::vector<JSValueRef>& retainedValues) {
    rehax::ui::appkit::impl::FlexItem flexItem;
    if (JSObjectHasProperty(ctx, (JSObjectRef) value, JSStringCreateWithUTF8CString("flexGrow"))) {
      flexItem.flexGrow = Converter<float>::toCpp(ctx, JSObjectGetProperty(ctx, (JSObjectRef) value, JSStringCreateWithUTF8CString("flexGrow"), nullptr), bindings, retainedValues);
    }
    if (JSObjectHasProperty(ctx, (JSObjectRef) value, JSStringCreateWithUTF8CString("hasFlexGrow"))) {
      flexItem.hasFlexGrow = Converter<bool>::toCpp(ctx, JSObjectGetProperty(ctx, (JSObjectRef) value, JSStringCreateWithUTF8CString("hasFlexGrow"), nullptr), bindings, retainedValues);
    }
    if (JSObjectHasProperty(ctx, (JSObjectRef) value, JSStringCreateWithUTF8CString("order"))) {
      flexItem.hasFlexGrow = Converter<int>::toCpp(ctx, JSObjectGetProperty(ctx, (JSObjectRef) value, JSStringCreateWithUTF8CString("order"), nullptr), bindings, retainedValues);
    }
    if (JSObjectHasProperty(ctx, (JSObjectRef) value, JSStringCreateWithUTF8CString("alignSelf"))) {
      flexItem.alignSelf = Converter<rehax::ui::appkit::FlexAlignItems>::toCpp(ctx, JSObjectGetProperty(ctx, (JSObjectRef) value, JSStringCreateWithUTF8CString("alignSelf"), nullptr), bindings, retainedValues);
    }
    return flexItem;
  }
};

template <>
struct Converter<rehax::ui::appkit::FlexLayoutOptions> {
  static JSValueRef toScript(JSContextRef ctx, rehax::ui::appkit::FlexLayoutOptions& value) {
    auto obj = JSObjectMake(ctx, nullptr, nullptr);
    JSObjectSetProperty(ctx, obj, JSStringCreateWithUTF8CString("direction"), Converter<rehax::ui::appkit::FlexLayoutDirection>::toScript(ctx, value.direction), kJSPropertyAttributeNone, nullptr);
    JSObjectSetProperty(ctx, obj, JSStringCreateWithUTF8CString("justifyContent"), Converter<rehax::ui::appkit::FlexJustifyContent>::toScript(ctx, value.justifyContent), kJSPropertyAttributeNone, nullptr);
    JSObjectSetProperty(ctx, obj, JSStringCreateWithUTF8CString("alignItems"), Converter<rehax::ui::appkit::FlexAlignItems>::toScript(ctx, value.alignItems), kJSPropertyAttributeNone, nullptr);
    auto arr = JSObjectMakeArray(ctx, 0, {}, NULL);
    for (int i = 0; i < value.items.size(); i++) {
      auto js = Converter<rehax::ui::appkit::impl::FlexItem>::toScript(ctx, value.items[i]);
      JSObjectSetPropertyAtIndex(ctx, arr, i, js, nullptr);
    }
    JSObjectSetProperty(ctx, obj, JSStringCreateWithUTF8CString("items"), arr, kJSPropertyAttributeNone, nullptr);
    return obj;
  }
  static rehax::ui::appkit::FlexLayoutOptions toCpp(JSContextRef ctx, const JSValueRef& value, Bindings * bindings, std::vector<JSValueRef>& retainedValues) {
    rehax::ui::appkit::FlexLayoutOptions options;
    if (JSObjectHasProperty(ctx, (JSObjectRef) value, JSStringCreateWithUTF8CString("direction"))) {
      options.direction = Converter<rehax::ui::appkit::FlexLayoutDirection>::toCpp(ctx, JSObjectGetProperty(ctx, (JSObjectRef) value, JSStringCreateWithUTF8CString("direction"), nullptr), bindings, retainedValues);
    }
    if (JSObjectHasProperty(ctx, (JSObjectRef) value, JSStringCreateWithUTF8CString("justifyContent"))) {
      options.justifyContent = Converter<rehax::ui::appkit::FlexJustifyContent>::toCpp(ctx, JSObjectGetProperty(ctx, (JSObjectRef) value, JSStringCreateWithUTF8CString("justifyContent"), nullptr), bindings, retainedValues);
    }
    if (JSObjectHasProperty(ctx, (JSObjectRef) value, JSStringCreateWithUTF8CString("alignItems"))) {
      options.alignItems = Converter<rehax::ui::appkit::FlexAlignItems>::toCpp(ctx, JSObjectGetProperty(ctx, (JSObjectRef) value, JSStringCreateWithUTF8CString("alignItems"), nullptr), bindings, retainedValues);
    }
    if (JSObjectHasProperty(ctx, (JSObjectRef) value, JSStringCreateWithUTF8CString("items"))) {
      JSValueRef items = JSObjectGetProperty(ctx, (JSObjectRef) value, JSStringCreateWithUTF8CString("items"), nullptr);
      int length = Converter<int>::toCpp(ctx, JSObjectGetProperty(ctx, (JSObjectRef) value, JSStringCreateWithUTF8CString("length"), nullptr), bindings, retainedValues);
      for (int i = 0; i < length; i++) {
        auto item = JSObjectGetPropertyAtIndex(ctx, (JSObjectRef) items, i, nullptr);
        options.items.push_back(Converter<rehax::ui::appkit::impl::FlexItem>::toCpp(ctx, item, bindings, retainedValues));
      }
    }
    return options;
  }
};

template <>
struct Converter<rehax::ui::appkit::GestureState> {
  static JSValueRef toScript(JSContextRef ctx, rehax::ui::appkit::GestureState& value) {
    if (value == ui::appkit::GestureState::Possible) {
      return JSValueMakeString(ctx, JSStringCreateWithUTF8CString("Possible"));
    }
    if (value == ui::appkit::GestureState::Recognized) {
      return JSValueMakeString(ctx, JSStringCreateWithUTF8CString("Recognized"));
    }
    if (value == ui::appkit::GestureState::Began) {
      return JSValueMakeString(ctx, JSStringCreateWithUTF8CString("Began"));
    }
    if (value == ui::appkit::GestureState::Changed) {
      return JSValueMakeString(ctx, JSStringCreateWithUTF8CString("Changed"));
    }
    if (value == ui::appkit::GestureState::Canceled) {
      return JSValueMakeString(ctx, JSStringCreateWithUTF8CString("Canceled"));
    }
    if (value == ui::appkit::GestureState::Ended) {
      return JSValueMakeString(ctx, JSStringCreateWithUTF8CString("Ended"));
    }
  }
  static rehax::ui::appkit::GestureState toCpp(JSContextRef ctx, const JSValueRef& value, Bindings * bindings, std::vector<JSValueRef>& retainedValues) {
    if (JSStringIsEqual(JSStringCreateWithUTF8CString("Recognized"), (JSStringRef) value)) {
      return ui::appkit::GestureState::Recognized;
    }
    if (JSStringIsEqual(JSStringCreateWithUTF8CString("Began"), (JSStringRef) value)) {
      return ui::appkit::GestureState::Began;
    }
    if (JSStringIsEqual(JSStringCreateWithUTF8CString("Changed"), (JSStringRef) value)) {
      return ui::appkit::GestureState::Changed;
    }
    if (JSStringIsEqual(JSStringCreateWithUTF8CString("Canceled"), (JSStringRef) value)) {
      return ui::appkit::GestureState::Canceled;
    }
    if (JSStringIsEqual(JSStringCreateWithUTF8CString("Ended"), (JSStringRef) value)) {
      return ui::appkit::GestureState::Ended;
    }
    return ui::appkit::GestureState::Possible;
  }
};

template <>
struct Converter<rehax::ui::appkit::VectorLineCap> {
  static JSValueRef toScript(JSContextRef ctx, rehax::ui::appkit::VectorLineCap& value) {
    if (value == ui::appkit::VectorLineCap::Butt) {
      return JSValueMakeString(ctx, JSStringCreateWithUTF8CString("Butt"));
    }
    if (value == ui::appkit::VectorLineCap::Square) {
      return JSValueMakeString(ctx, JSStringCreateWithUTF8CString("Square"));
    }
    if (value == ui::appkit::VectorLineCap::Round) {
      return JSValueMakeString(ctx, JSStringCreateWithUTF8CString("Round"));
    }
  }
  static rehax::ui::appkit::VectorLineCap toCpp(JSContextRef ctx, const JSValueRef& value, Bindings * bindings, std::vector<JSValueRef>& retainedValues) {
    if (JSStringIsEqual(JSStringCreateWithUTF8CString("Square"), (JSStringRef) value)) {
      return ui::appkit::VectorLineCap::Square;
    }
    if (JSStringIsEqual(JSStringCreateWithUTF8CString("Round"), (JSStringRef) value)) {
      return ui::appkit::VectorLineCap::Round;
    }
    return ui::appkit::VectorLineCap::Butt;
  }
};

template <>
struct Converter<rehax::ui::appkit::VectorLineJoin> {
  static JSValueRef toScript(JSContextRef ctx, rehax::ui::appkit::VectorLineJoin& value) {
    if (value == ui::appkit::VectorLineJoin::Miter) {
      return JSValueMakeString(ctx, JSStringCreateWithUTF8CString("Miter"));
    }
    if (value == ui::appkit::VectorLineJoin::Round) {
      return JSValueMakeString(ctx, JSStringCreateWithUTF8CString("Round"));
    }
    if (value == ui::appkit::VectorLineJoin::Bevel) {
      return JSValueMakeString(ctx, JSStringCreateWithUTF8CString("Bevel"));
    }
  }
  static rehax::ui::appkit::VectorLineJoin toCpp(JSContextRef ctx, const JSValueRef& value, Bindings * bindings, std::vector<JSValueRef>& retainedValues) {
    if (JSStringIsEqual(JSStringCreateWithUTF8CString("Round"), (JSStringRef) value)) {
      return ui::appkit::VectorLineJoin::Round;
    }
    if (JSStringIsEqual(JSStringCreateWithUTF8CString("Bevel"), (JSStringRef) value)) {
      return ui::appkit::VectorLineJoin::Bevel;
    }
    return ui::appkit::VectorLineJoin::Miter;
  }
};

template <>
struct Converter<rehax::ui::appkit::GradientStop> {
  static JSValueRef toScript(JSContextRef ctx, rehax::ui::appkit::GradientStop& value) {
    auto obj = JSObjectMake(ctx, nullptr, nullptr);
    JSObjectSetProperty(ctx, obj, JSStringCreateWithUTF8CString("color"), Converter<rehax::ui::Color>::toScript(ctx, value.color), kJSPropertyAttributeNone, nullptr);
    JSObjectSetProperty(ctx, obj, JSStringCreateWithUTF8CString("offset"), Converter<float>::toScript(ctx, value.offset), kJSPropertyAttributeNone, nullptr);
    return obj;
  }
  static rehax::ui::appkit::GradientStop toCpp(JSContextRef ctx, const JSValueRef& value, Bindings * bindings, std::vector<JSValueRef>& retainedValues) {
    rehax::ui::appkit::impl::GradientStop stop;
    if (JSObjectHasProperty(ctx, (JSObjectRef) value, JSStringCreateWithUTF8CString("color"))) {
      stop.color = Converter<rehax::ui::Color>::toCpp(ctx, JSObjectGetProperty(ctx, (JSObjectRef) value, JSStringCreateWithUTF8CString("color"), nullptr), bindings, retainedValues);
    }
    if (JSObjectHasProperty(ctx, (JSObjectRef) value, JSStringCreateWithUTF8CString("offset"))) {
      stop.offset = Converter<float>::toCpp(ctx, JSObjectGetProperty(ctx, (JSObjectRef) value, JSStringCreateWithUTF8CString("offset"), nullptr), bindings, retainedValues);
    }
    return stop;
  }
};

template <>
struct Converter<rehax::ui::appkit::Gradient> {
  static JSValueRef toScript(JSContextRef ctx, rehax::ui::appkit::Gradient& value) {
    auto obj = JSObjectMake(ctx, nullptr, nullptr);
    auto arr = JSObjectMakeArray(ctx, 0, {}, NULL);
    for (int i = 0; i < value.stops.size(); i++) {
      auto js = Converter<rehax::ui::appkit::GradientStop>::toScript(ctx, value.stops[i]);
      JSObjectSetPropertyAtIndex(ctx, arr, i, js, nullptr);
    }
    JSObjectSetProperty(ctx, obj, JSStringCreateWithUTF8CString("stops"), arr, kJSPropertyAttributeNone, nullptr);
    return obj;
  }
  static rehax::ui::appkit::Gradient toCpp(JSContextRef ctx, const JSValueRef& value, Bindings * bindings, std::vector<JSValueRef>& retainedValues) {
    rehax::ui::appkit::Gradient gradient;
    if (JSObjectHasProperty(ctx, (JSObjectRef) value, JSStringCreateWithUTF8CString("stops"))) {
      JSValueRef items = JSObjectGetProperty(ctx, (JSObjectRef) value, JSStringCreateWithUTF8CString("stops"), nullptr);
      int length = Converter<int>::toCpp(ctx, JSObjectGetProperty(ctx, (JSObjectRef) value, JSStringCreateWithUTF8CString("length"), nullptr), bindings, retainedValues);
      for (int i = 0; i < length; i++) {
        auto item = JSObjectGetPropertyAtIndex(ctx, (JSObjectRef) items, i, nullptr);
        gradient.stops.push_back(Converter<rehax::ui::appkit::GradientStop>::toCpp(ctx, item, bindings, retainedValues));
      }
    }
    return gradient;
  }
};

template <>
struct Converter<rehax::ui::appkit::FilterDef> {
  static JSValueRef toScript(JSContextRef ctx, rehax::ui::appkit::FilterDef& value) {
    auto obj = JSObjectMake(ctx, nullptr, nullptr);
    JSObjectSetProperty(ctx, obj, JSStringCreateWithUTF8CString("type"), Converter<int>::toScript(ctx, value.type), kJSPropertyAttributeNone, nullptr);
    JSObjectSetProperty(ctx, obj, JSStringCreateWithUTF8CString("blurRadius"), Converter<float>::toScript(ctx, value.blurRadius), kJSPropertyAttributeNone, nullptr);
    return obj;
  }
  static rehax::ui::appkit::FilterDef toCpp(JSContextRef ctx, const JSValueRef& value, Bindings * bindings, std::vector<JSValueRef>& retainedValues) {
    rehax::ui::appkit::impl::FilterDef def;
    if (JSObjectHasProperty(ctx, (JSObjectRef) value, JSStringCreateWithUTF8CString("type"))) {
      def.type = Converter<int>::toCpp(ctx, JSObjectGetProperty(ctx, (JSObjectRef) value, JSStringCreateWithUTF8CString("type"), nullptr), bindings, retainedValues);
    }
    if (JSObjectHasProperty(ctx, (JSObjectRef) value, JSStringCreateWithUTF8CString("blurRadius"))) {
      def.blurRadius = Converter<float>::toCpp(ctx, JSObjectGetProperty(ctx, (JSObjectRef) value, JSStringCreateWithUTF8CString("blurRadius"), nullptr), bindings, retainedValues);
    }
    return def;
  }
};

template <>
struct Converter<rehax::ui::appkit::Filters> {
  static JSValueRef toScript(JSContextRef ctx, rehax::ui::appkit::Filters& value) {
    auto obj = JSObjectMake(ctx, nullptr, nullptr);
    auto arr = JSObjectMakeArray(ctx, 0, {}, NULL);
    for (int i = 0; i < value.defs.size(); i++) {
      auto js = Converter<rehax::ui::appkit::FilterDef>::toScript(ctx, value.defs[i]);
      JSObjectSetPropertyAtIndex(ctx, arr, i, js, nullptr);
    }
    JSObjectSetProperty(ctx, obj, JSStringCreateWithUTF8CString("defs"), arr, kJSPropertyAttributeNone, nullptr);
    return obj;
  }
  static rehax::ui::appkit::Filters toCpp(JSContextRef ctx, const JSValueRef& value, Bindings * bindings, std::vector<JSValueRef>& retainedValues) {
    rehax::ui::appkit::Filters filters;
    if (JSObjectHasProperty(ctx, (JSObjectRef) value, JSStringCreateWithUTF8CString("defs"))) {
      JSValueRef items = JSObjectGetProperty(ctx, (JSObjectRef) value, JSStringCreateWithUTF8CString("defs"), nullptr);
      int length = Converter<int>::toCpp(ctx, JSObjectGetProperty(ctx, (JSObjectRef) value, JSStringCreateWithUTF8CString("length"), nullptr), bindings, retainedValues);
      for (int i = 0; i < length; i++) {
        auto item = JSObjectGetPropertyAtIndex(ctx, (JSObjectRef) items, i, nullptr);
        filters.defs.push_back(Converter<rehax::ui::appkit::FilterDef>::toCpp(ctx, item, bindings, retainedValues));
      }
    }
    return filters;
  }
};



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

    for (auto value : privateData->retainedValues) {
      JSValueUnprotect(ctx, value);
    }

    privateData->view->decreaseReferenceCount();
    delete privateData;
  };
  
  JSObjectRef prototypeObject = JSObjectMake(ctx, nullptr, nullptr);
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


template <typename View, typename Layout>
void bindViewClassMethods(JSContextRef ctx, JSObjectRef prototype) {
  bindMethod<View, std::string, &View::description>("toString", ctx, prototype);
  bindMethod<View, &View::removeFromParent>("removeFromParent", ctx, prototype);
  bindMethod<View, float, &View::setWidthFixed>("setWidthFixed", ctx, prototype);
  bindMethod<View, float, &View::setHeightFixed>("setHeightFixed", ctx, prototype);
    
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
      auto it = children.find(view);
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
  bindMethod<View, rehax::ui::appkit::VectorLineJoin, &View::setLineJoin>("setLineJoin", ctx, prototype);
  bindMethod<View, rehax::ui::appkit::VectorLineCap, &View::setLineCap>("setLineCap", ctx, prototype);
  bindMethod<View, rehax::ui::Color, &View::setFillColor>("setFillColor", ctx, prototype);
  bindMethod<View, rehax::ui::Color, &View::setStrokeColor>("setStrokeColor", ctx, prototype);
  bindMethod<View, rehax::ui::appkit::Gradient, &View::setFillGradient>("setFillGradient", ctx, prototype);
  bindMethod<View, rehax::ui::appkit::Gradient, &View::setStrokeGradient>("setStrokeGradient", ctx, prototype);
  bindMethod<View, rehax::ui::appkit::Filters, &View::setFilters>("setFilters", ctx, prototype);
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

template <typename Layout>
void bindStackLayoutClassMethods(JSContextRef ctx, JSObjectRef prototype) {
  bindMethod<Layout, rehax::ui::appkit::StackLayoutOptions, &Layout::setOptions>("setOptions", ctx, prototype);
}

template <typename Layout>
void bindFlexLayoutClassMethods(JSContextRef ctx, JSObjectRef prototype) {
  bindMethod<Layout, rehax::ui::appkit::FlexLayoutOptions, &Layout::setOptions>("setOptions", ctx, prototype);
}

template <typename Gesture>
void bindGestureClassMethods(JSContextRef ctx, JSObjectRef prototype) {
  bindMethod<Gesture, std::function<void(void)>, std::function<void(float, float)>, std::function<void(float, float)>, std::function<void(float, float)>, &Gesture::setup>("setup", ctx, prototype);
  bindMethod<Gesture, rehax::ui::appkit::GestureState, &Gesture::setState>("setState", ctx, prototype);
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
    .type = rehax::docs::get_type_name<rehax::ui::appkit::StackLayoutOptions>(),
    .note = "Converts from/to an object with shape `{ spacing: float, direction: 'Horizontal' | 'Vertical' }`.",
  });
#endif
#if RHX_GEN_DOCS
  jscDocs.collectType("FlexLayoutOptions", rehax::docs::TypeDocs {
    .type = rehax::docs::get_type_name<rehax::ui::appkit::FlexLayoutOptions>(),
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

  bindViewClassMethods<rehax::ui::appkit::View, rehax::ui::appkit::impl::ILayout>(ctx, classRegistry["View"].prototype);
  bindButtonClassMethods<rehax::ui::appkit::Button>(ctx, classRegistry["Button"].prototype);
  bindTextClassMethods<rehax::ui::appkit::Text>(ctx, classRegistry["Text"].prototype);
  bindTextInputClassMethods<rehax::ui::appkit::TextInput>(ctx, classRegistry["TextInput"].prototype);
  bindVectorElementClassMethods<rehax::ui::appkit::VectorElement>(ctx, classRegistry["VectorElement"].prototype);
  bindVectorPathClassMethods<rehax::ui::appkit::VectorPath>(ctx, classRegistry["VectorPath"].prototype);

  bindStackLayoutClassMethods<rehax::ui::appkit::StackLayout>(ctx, classRegistry["StackLayout"].prototype);
  bindFlexLayoutClassMethods<rehax::ui::appkit::FlexLayout>(ctx, classRegistry["FlexLayout"].prototype);

  defineViewClass<rehax::ui::appkit::Gesture>(ctx, "Gesture", nullptr);
  bindGestureClassMethods<rehax::ui::appkit::Gesture>(ctx, classRegistry["Gesture"].prototype);

  jscDocs.printJson();
  jscDocs.printMarkdown();
}
#endif

#ifdef REHAX_WITH_FLUXE
void Bindings::bindFluxeToJsc() {
  defineViewClass<rehax::ui::fluxe::impl::View<rehax::ui::RefCountedPointer>>(ctx, "View", nullptr);
  defineViewClass<rehax::ui::fluxe::impl::Button<rehax::ui::RefCountedPointer>>(ctx, "Button", classRegistry["View"].prototype);
  defineViewClass<rehax::ui::fluxe::impl::Text<rehax::ui::RefCountedPointer>>(ctx, "Text", classRegistry["View"].prototype);
  defineViewClass<rehax::ui::fluxe::impl::TextInput<rehax::ui::RefCountedPointer>>(ctx, "TextInput", classRegistry["View"].prototype);

  bindViewClassMethods<rehax::ui::fluxe::impl::View<rehax::ui::RefCountedPointer>>(ctx, classRegistry["View"].prototype);
  bindButtonClassMethods<rehax::ui::fluxe::impl::Button<rehax::ui::RefCountedPointer>>(ctx, classRegistry["Button"].prototype);
  bindTextClassMethods<rehax::ui::fluxe::impl::Text<rehax::ui::RefCountedPointer>>(ctx, classRegistry["Text"].prototype);
  bindTextInputClassMethods<rehax::ui::fluxe::impl::TextInput<rehax::ui::RefCountedPointer>>(ctx, classRegistry["TextInput"].prototype);
}
#endif

}
}
