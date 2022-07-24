#include "jscBindings.h"

namespace rehax {
namespace jsc {


std::string Bindings::JSStringToStdString(JSContextRef ctx, JSStringRef str) {
    size_t maxBufferSize = JSStringGetMaximumUTF8CStringSize(str);
    char* utf8Buffer = new char[maxBufferSize];
    size_t bytesWritten = JSStringGetUTF8CString(str, utf8Buffer, maxBufferSize);
    utf8Buffer[bytesWritten] = '\0';
    std::string ret = std::string(utf8Buffer);
    delete [] utf8Buffer;
    return ret;
}

Bindings::Bindings()
{}

void Bindings::setContext(JSContextRef ctx)
{
    JSObjectSetPrivate(JSContextGetGlobalObject(ctx), this);
    this->ctx = ctx;
}

JSObjectRef cppToJs(JSContextRef ctx, Bindings::RegisteredClass classDefine, void * obj)
{
    JSObjectRef object = JSObjectMake(ctx, classDefine.classDefine, obj);
    JSObjectSetPrototype(ctx, object, classDefine.prototype);
    return object;
}

JSObjectRef Bindings::cppToJs(void * obj, std::string className)
{
    JSObjectRef object = JSObjectMake(ctx, classRegistry[className].classDefine, obj);
    JSObjectSetPrototype(ctx, object, classRegistry[className].prototype);
    return object;
}

template <typename View>
void Bindings::defineViewClass(JSContextRef ctx, std::string name, JSObjectRef parentPrototype)
{
    auto globalContext = JSContextGetGlobalObject(ctx);
    
    JSClassDefinition instanceDefine = kJSClassDefinitionEmpty;
    instanceDefine.attributes = kJSClassAttributeNone;
    instanceDefine.className = name.c_str();
    instanceDefine.finalize = [] (JSObjectRef thiz) {
        auto * t = static_cast<View *>(JSObjectGetPrivate(thiz));
        // Not sure we should delete this here, could still be in the view hierarchy.
//            delete t;
    };
    
    JSObjectRef prototypeObject = JSObjectMake(ctx, nullptr, nullptr);
    if (parentPrototype != nullptr) {
        JSObjectSetPrototype(ctx, prototypeObject, parentPrototype);
    }
    
    instanceDefine.callAsConstructor = [] (JSContextRef ctx, JSObjectRef constructor, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception) {
        auto classDef = static_cast<RegisteredClass *>(JSObjectGetPrivate(constructor));
        auto view = View::Create();
        return ::rehax::jsc::cppToJs(ctx, *classDef, view);
    };
    
    auto clazz = JSClassCreate(&instanceDefine);
    classRegistry[name] = {
        .name = name,
        .classDefine = clazz,
        .prototype = prototypeObject,
    };
    auto jsClassObject = JSObjectMake(ctx, clazz, &classRegistry[name]);
    auto className = JSStringCreateWithUTF8CString(name.c_str());
    JSObjectSetProperty(ctx, globalContext, className, jsClassObject, kJSPropertyAttributeReadOnly, NULL);
    
    return clazz;
}

template <typename View>
void bindViewClassMethods(JSContextRef ctx, JSObjectRef prototype)
{
    {
        JSStringRef methodName = JSStringCreateWithUTF8CString("addView");
        auto functionObject = JSObjectMakeFunctionWithCallback(ctx, methodName, [] (JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception) {
            auto view = (View *) JSObjectGetPrivate(thisObject);
            auto childView = (View *) JSObjectGetPrivate((JSObjectRef) arguments[0]);
            view->addView(childView);
            return JSValueMakeUndefined(ctx);
        });
        JSObjectSetProperty(ctx, prototype, methodName, functionObject, kJSPropertyAttributeReadOnly, NULL);
    }
}

template <typename View>
void bindButtonClassMethods(JSContextRef ctx, JSObjectRef prototype)
{
    {
        JSStringRef methodName = JSStringCreateWithUTF8CString("setTitle");
        auto functionObject = JSObjectMakeFunctionWithCallback(ctx, methodName, [] (JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception) {
            auto view = (View *) JSObjectGetPrivate(thisObject);
            view->setTitle(Bindings::JSStringToStdString(ctx, (JSStringRef) arguments[0]));
            return JSValueMakeUndefined(ctx);
        });
        JSObjectSetProperty(ctx, prototype, methodName, functionObject, kJSPropertyAttributeReadOnly, NULL);
    }
}




#ifdef REHAX_WITH_APPKIT
void Bindings::bindAppkitToJsc()
{
    defineViewClass<::rehax::ui::appkit::rawptr::View>(ctx, "View", nullptr);
    bindViewClassMethods<::rehax::ui::appkit::rawptr::View>(ctx, classRegistry["View"].prototype);
    defineViewClass<::rehax::ui::appkit::rawptr::Button>(ctx, "Button", classRegistry["View"].prototype);
    bindButtonClassMethods<::rehax::ui::appkit::rawptr::Button>(ctx, classRegistry["Button"].prototype);
}
#endif

#ifdef REHAX_WITH_FLUXE
void Bindings::bindFluxeToJsc()
{
    defineViewClass<::rehax::ui::fluxe::rawptr::View>(ctx, "View", nullptr);
    bindViewClassMethods<::rehax::ui::fluxe::rawptr::View>(ctx, classRegistry["View"].prototype);
    defineViewClass<::rehax::ui::fluxe::rawptr::Button>(ctx, "Button", classRegistry["View"].prototype);
    bindButtonClassMethods<::rehax::ui::fluxe::rawptr::Button>(ctx, classRegistry["Button"].prototype);
}
#endif

}
}
