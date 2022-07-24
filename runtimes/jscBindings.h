#pragma once

#include <JavaScriptCore/JavaScriptCore.h>
#include "../native-abstraction/rehax.h"
#include <unordered_map>

namespace rehax {
namespace jsc {

class Bindings
{
public:
    
    static std::string JSStringToStdString(JSContextRef ctx, JSStringRef str);

    Bindings();
    void setContext(JSContextRef ctx);
    #ifdef REHAX_WITH_APPKIT
    void bindAppkitToJsc();
    #endif
    #ifdef REHAX_WITH_FLUXE
    void bindFluxeToJsc();
    #endif
    
    template <typename View>
    JSObjectRef cppToJs(View * obj, std::string className)
    {
        obj->containerAdditionalData = classRegistry[className];
        JSObjectRef object = JSObjectMake(ctx, classRegistry[className].classDefine, obj);
        JSObjectSetPrototype(ctx, object, classRegistry[className].prototype);
        return object;
    }

private:
    JSContextRef ctx;

    std::unordered_map<std::string, ui::JscRegisteredClass> classRegistry;
    
    template <typename View>
    void defineViewClass(JSContextRef ctx, std::string name, JSObjectRef parentPrototype);

};

}
}
