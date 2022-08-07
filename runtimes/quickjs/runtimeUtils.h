#include <iostream>
#include <quickjs-src/quickjs.h>

namespace rehax {
namespace quickjs {
namespace runtime {

typedef ::JSContext * Context;
typedef ::JSValue Value;

Value MakeObject(Context ctx);
Value MakeArray(Context ctx);
void SetObjectProperty(Context ctx, Value object, std::string property, Value value);
Value GetObjectProperty(Context ctx, Value object, std::string property);
bool HasObjectProperty(Context ctx, Value object, std::string property);
void SetArrayValue(Context ctx, Value object, int index, Value value);
Value GetArrayValue(Context ctx, Value object, int index);
bool IsValueUndefined(Context ctx, Value object);
bool IsValueNull(Context ctx, Value object);
Value MakeNull(Context ctx);

}
}
}
