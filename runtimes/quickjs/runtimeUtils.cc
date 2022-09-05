#include "./runtimeUtils.h"

using namespace rehax::quickjs::runtime;

Value rehax::quickjs::runtime::MakeObject(Context ctx) {
  auto object = JS_NewObject(ctx);
  return object;
}

Value rehax::quickjs::runtime::GetGlobalObject(Context ctx) {
  auto globalObject = JS_GetGlobalObject(ctx);
  return globalObject;
}

Value rehax::quickjs::runtime::GetRehaxObject(Context ctx) {
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

Value rehax::quickjs::runtime::MakeArray(Context ctx) {
  auto object = JS_NewArray(ctx);
  return object;
}

void rehax::quickjs::runtime::SetObjectProperty(Context ctx, Value object, std::string property, Value value) {
  JS_SetPropertyStr(ctx, object, property.c_str(), value);
}

Value rehax::quickjs::runtime::GetObjectProperty(Context ctx, Value object, std::string property) {
  return JS_GetPropertyStr(ctx, object, property.c_str());
}

bool rehax::quickjs::runtime::HasObjectProperty(Context ctx, Value object, std::string property) {
  return JS_HasProperty(ctx, object, JS_NewAtom(ctx, property.c_str()));
}

std::vector<std::string> rehax::quickjs::runtime::GetObjectProperties(Context ctx, Value object) {
  std::vector<std::string> properties;
  auto jsProps = JS_Invoke(ctx, object, JS_NewAtom(ctx, "Object.keys(this)"), 0, nullptr);
  auto jsLength = JS_GetPropertyStr(ctx, jsProps, "length");
  int length;
  JS_ToInt32(ctx, &length, jsLength);
  for (int i = 0; i < length; i++) {
    auto jsKey = GetArrayValue(ctx, jsProps, i);
    auto key = JS_ToCString(ctx, jsKey);
    properties.push_back(std::string(key));
  }
  return properties;
}

void rehax::quickjs::runtime::SetArrayValue(Context ctx, Value object, int index, Value value) {
  JS_SetPropertyInt64(ctx, object, index, value);
}

Value rehax::quickjs::runtime::GetArrayValue(Context ctx, Value object, int index) {
  return JS_GetPropertyUint32(ctx, object, index);
}

Value rehax::quickjs::runtime::MakeNull(Context ctx) {
  return JS_NULL;
}

bool rehax::quickjs::runtime::IsValueUndefined(Context ctx, Value object) {
  return JS_IsUndefined(object);
}

bool rehax::quickjs::runtime::IsValueNull(Context ctx, Value object) {
  return JS_IsNull(object);
}

bool rehax::quickjs::runtime::IsValueString(Context ctx, Value object) {
  return JS_IsString(object);
}
