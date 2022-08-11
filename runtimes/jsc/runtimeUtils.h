#import <JavaScriptCore/JavaScriptCore.h>
#include <iostream>

namespace rehax {
namespace jsc {
namespace runtime {

typedef ::JSContextRef Context;
typedef ::JSValueRef Value;

Value MakeObject(Context ctx);
Value GetGlobalObject(Context ctx);
Value GetRehaxObject(Context ctx);
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
