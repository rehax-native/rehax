#include "./runtimeUtils.h"

using namespace rehax::jsc::runtime;

Value rehax::jsc::runtime::MakeObject(Context ctx) {
  JSObjectRef object = JSObjectMake(ctx, nullptr, nullptr);
  return object;
}

Value rehax::jsc::runtime::GetGlobalObject(Context ctx) {
  auto globalObject = JSContextGetGlobalObject(ctx);
  return globalObject;
}

Value rehax::jsc::runtime::GetRehaxObject(Context ctx) {
  auto globalObject = GetGlobalObject(ctx);

  runtime::Value rehax;
  if (!runtime::HasObjectProperty(ctx, globalObject, "rehax")) {
    rehax = runtime::MakeObject(ctx);
    runtime::SetObjectProperty(ctx, globalObject, "rehax", rehax);
  } else {
    rehax = runtime::GetObjectProperty(ctx, globalObject, "rehax");
  }

  return rehax;
}

Value rehax::jsc::runtime::MakeArray(Context ctx) {
  auto object = JSObjectMakeArray(ctx, 0, {}, NULL);
  return object;
}

void rehax::jsc::runtime::SetObjectProperty(Context ctx, Value object, std::string property, Value value) {
  auto propName = JSStringCreateWithUTF8CString(property.c_str());
  JSObjectSetProperty(ctx, (JSObjectRef) object, propName, value, kJSPropertyAttributeNone, nullptr);
}

Value rehax::jsc::runtime::GetObjectProperty(Context ctx, Value object, std::string property) {
  auto propName = JSStringCreateWithUTF8CString(property.c_str());
  return JSObjectGetProperty(ctx, (JSObjectRef) object, propName, NULL);
}

bool rehax::jsc::runtime::HasObjectProperty(Context ctx, Value object, std::string property) {
  return JSObjectHasProperty(ctx, (JSObjectRef) object, JSStringCreateWithUTF8CString(property.c_str()));
}

void rehax::jsc::runtime::SetArrayValue(Context ctx, Value object, int index, Value value) {
  JSObjectSetPropertyAtIndex(ctx, (JSObjectRef) object, index, value, nullptr);
}

Value rehax::jsc::runtime::GetArrayValue(Context ctx, Value object, int index) {
  return JSObjectGetPropertyAtIndex(ctx, (JSObjectRef) object, index, nullptr);
}

Value rehax::jsc::runtime::MakeNull(Context ctx) {
  return JSValueMakeNull(ctx);
}

bool rehax::jsc::runtime::IsValueUndefined(Context ctx, Value object) {
  return JSValueIsUndefined(ctx, object);
}

bool rehax::jsc::runtime::IsValueNull(Context ctx, Value object) {
  return JSValueIsNull(ctx, object);
}
