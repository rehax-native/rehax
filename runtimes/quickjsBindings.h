#pragma once

#include "../native-abstraction/rehax.h"
#include <unordered_map>
#include <quickjs-src/quickjs.h>

namespace rehax {
namespace quickjs {

constexpr JSClassID kPointerClassId = 0;
constexpr JSClassID kClassClassId = 1;
constexpr JSClassID kPrototypeClassId = 2;
constexpr JSClassID kInstanceClassId = 3;


struct QuickJsRegisteredClass {
  std::string name;
  JSValue prototype;
};

struct QuickJsContainerData {
    JSContext * ctx;
    QuickJsRegisteredClass * registeredClass;
    std::vector<JSValue> retainedValues;
    ~QuickJsContainerData();
};

class Bindings
{
public:
    
    Bindings();
    void setContext(JSContext * ctx, JSRuntime * runtime);
    #ifdef REHAX_WITH_APPKIT
    void bindAppkitToQuickJs();
    #endif
    #ifdef REHAX_WITH_FLUXE
    void bindFluxeToQuickJs();
    #endif
    
    template <typename View>
    JSValue cppToJs(View * obj, std::string className)
    {
        obj->containerAdditionalData = {
            .ctx = ctx,
            .registeredClass = &classRegistry[className]
        };
        auto object = JS_NewObjectClass(ctx, kInstanceClassId);
        JS_SetOpaque(object, obj);
        JS_SetPrototype(ctx, object, classRegistry[className].prototype);
        JS_SetPropertyStr(ctx, object, "__className", JS_NewAtomString(ctx, classRegistry[className].name.c_str()));
        return object;
    }

private:
    JSContext * ctx;
    JSRuntime * rt;

    std::unordered_map<std::string, QuickJsRegisteredClass> classRegistry;
    
    template <typename View>
    void defineViewClass(JSContext * ctx, std::string name, JSValue parentPrototype);

};

}
}
