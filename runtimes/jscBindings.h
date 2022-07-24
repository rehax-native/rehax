#pragma once

#include <JavaScriptCore/JavaScriptCore.h>
#include "../native-abstraction/rehax.h"
#include <unordered_map>

namespace rehax {
namespace jsc {

class Bindings
{
public:
    struct RegisteredClass {
        std::string name;
        JSClassRef classDefine;
        JSObjectRef prototype;
    };
    
    static std::string JSStringToStdString(JSContextRef ctx, JSStringRef str);

    Bindings();
    void setContext(JSContextRef ctx);
    void bindAppkitToJsc();
    void bindFluxeToJsc();
    JSObjectRef cppToJs(void * obj, std::string className);

private:
    JSContextRef ctx;

    std::unordered_map<std::string, RegisteredClass> classRegistry;
    
    template <typename View>
    void defineViewClass(JSContextRef ctx, std::string name, JSObjectRef parentPrototype);

};

}
}
