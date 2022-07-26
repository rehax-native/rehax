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

JSObjectRef cppToJs(JSContextRef ctx, JscRegisteredClass classDefine, void * obj)
{
    JSObjectRef object = JSObjectMake(ctx, classDefine.classDefine, obj);
    JSObjectSetPrototype(ctx, object, classDefine.prototype);
    auto __className = JSStringCreateWithUTF8CString(classDefine.name.c_str());
    JSObjectSetProperty(ctx, object, JSStringCreateWithUTF8CString("__className"), (JSValueRef) JSValueMakeString(ctx, __className), kJSPropertyAttributeReadOnly, NULL);
    return object;
}

//template <typename View>
//JSObjectRef Bindings::cppToJs(View * obj, std::string className)
//{
//    JSObjectRef object = JSObjectMake(ctx, classRegistry[className].classDefine, obj);
//    JSObjectSetPrototype(ctx, object, classRegistry[className].prototype);
//    return object;
//}

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
        std::cout << "GC !" << std::endl;
//            delete t;
    };
    
    JSObjectRef prototypeObject = JSObjectMake(ctx, nullptr, nullptr);
    if (parentPrototype != nullptr) {
        JSObjectSetPrototype(ctx, prototypeObject, parentPrototype);
    }
    
    instanceDefine.callAsConstructor = [] (JSContextRef ctx, JSObjectRef constructor, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception) {
        auto classDef = static_cast<JscRegisteredClass *>(JSObjectGetPrivate(constructor));
        auto view = View::Create();
        view->containerAdditionalData = *classDef;
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
        JSStringRef methodName = JSStringCreateWithUTF8CString("toString");
        auto functionObject = JSObjectMakeFunctionWithCallback(ctx, methodName, [] (JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception) {
            auto view = (View *) JSObjectGetPrivate(thisObject);
            auto description = view->description();
            JSStringRef jsText = JSStringCreateWithUTF8CString(description.c_str());
            return JSValueMakeString(ctx, jsText);
        });
        JSObjectSetProperty(ctx, prototype, methodName, functionObject, kJSPropertyAttributeReadOnly, NULL);
    }
    {
        JSStringRef methodName = JSStringCreateWithUTF8CString("addView");
        auto functionObject = JSObjectMakeFunctionWithCallback(ctx, methodName, [] (JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception) {
            auto view = (View *) JSObjectGetPrivate(thisObject);
            auto childView = (View *) JSObjectGetPrivate((JSObjectRef) arguments[0]);
            if (argumentCount <= 1 || JSValueIsNull(ctx, arguments[1]) || JSValueIsUndefined(ctx, arguments[1])) {
                view->addView(childView);
            } else {
                auto beforeView = (View *) JSObjectGetPrivate((JSObjectRef) arguments[1]);
                view->addView(childView, beforeView);
            }
            return JSValueMakeUndefined(ctx);
        });
        JSObjectSetProperty(ctx, prototype, methodName, functionObject, kJSPropertyAttributeReadOnly, NULL);
    }
    {
        JSStringRef methodName = JSStringCreateWithUTF8CString("removeFromParent");
        auto functionObject = JSObjectMakeFunctionWithCallback(ctx, methodName, [] (JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception) {
            auto view = (View *) JSObjectGetPrivate(thisObject);
            view->removeFromParent();
            return JSValueMakeUndefined(ctx);
        });
        JSObjectSetProperty(ctx, prototype, methodName, functionObject, kJSPropertyAttributeReadOnly, NULL);
    }
    {
        JSStringRef methodName = JSStringCreateWithUTF8CString("removeView");
        auto functionObject = JSObjectMakeFunctionWithCallback(ctx, methodName, [] (JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception) {
            auto view = (View *) JSObjectGetPrivate(thisObject);
            auto childView = (View *) JSObjectGetPrivate((JSObjectRef) arguments[0]);
            view->removeView(childView);
            return JSValueMakeUndefined(ctx);
        });
        JSObjectSetProperty(ctx, prototype, methodName, functionObject, kJSPropertyAttributeReadOnly, NULL);
    }
    {
        JSStringRef methodName = JSStringCreateWithUTF8CString("getParent");
        auto functionObject = JSObjectMakeFunctionWithCallback(ctx, methodName, [] (JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception) {
            auto view = (View *) JSObjectGetPrivate(thisObject);
            auto parent = view->getParent();
            auto classDef = parent->containerAdditionalData;
            JSObjectRef jsParent = ::rehax::jsc::cppToJs(ctx, classDef, parent);
            return (JSValueRef) jsParent;
        });
        JSObjectSetProperty(ctx, prototype, methodName, functionObject, kJSPropertyAttributeReadOnly, NULL);
    }
    {
        JSStringRef methodName = JSStringCreateWithUTF8CString("getFirstChild");
        auto functionObject = JSObjectMakeFunctionWithCallback(ctx, methodName, [] (JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception) {
            auto view = (View *) JSObjectGetPrivate(thisObject);
            auto children = view->children;
            auto firstChild = * children.begin();
            return (JSValueRef) ::rehax::jsc::cppToJs(ctx, firstChild->containerAdditionalData, firstChild);
        });
        JSObjectSetProperty(ctx, prototype, methodName, functionObject, kJSPropertyAttributeReadOnly, NULL);
    }
    {
        JSStringRef methodName = JSStringCreateWithUTF8CString("getNextSibling");
        auto functionObject = JSObjectMakeFunctionWithCallback(ctx, methodName, [] (JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception) {
            auto view = (View *) JSObjectGetPrivate(thisObject);
            // TODO this should probably be moved to the core
            auto parent = view->getParent();
            if (parent == nullptr) {
                return JSValueMakeNull(ctx);
            }
            auto it = parent->children.find(view);
            it++;
            if (it == parent->children.end()) {
                return JSValueMakeNull(ctx);
            }
            auto nextSibling = * it;
            return (JSValueRef) ::rehax::jsc::cppToJs(ctx, nextSibling->containerAdditionalData, nextSibling);
        });
        JSObjectSetProperty(ctx, prototype, methodName, functionObject, kJSPropertyAttributeReadOnly, NULL);
    }
}

template <typename View>
void bindTextClassMethods(JSContextRef ctx, JSObjectRef prototype)
{
    {
        JSStringRef methodName = JSStringCreateWithUTF8CString("setText");
        auto functionObject = JSObjectMakeFunctionWithCallback(ctx, methodName, [] (JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception) {
            auto view = (View *) JSObjectGetPrivate(thisObject);
            view->setText(Bindings::JSStringToStdString(ctx, (JSStringRef) arguments[0]));
            return JSValueMakeUndefined(ctx);
        });
        JSObjectSetProperty(ctx, prototype, methodName, functionObject, kJSPropertyAttributeReadOnly, NULL);
    }
    {
        JSStringRef methodName = JSStringCreateWithUTF8CString("getText");
        auto functionObject = JSObjectMakeFunctionWithCallback(ctx, methodName, [] (JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception) {
            auto view = (View *) JSObjectGetPrivate(thisObject);
            auto text = view->getText();
            JSStringRef jsText = JSStringCreateWithUTF8CString(text.c_str());
            return JSValueMakeString(ctx, jsText);
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
    {
        JSStringRef methodName = JSStringCreateWithUTF8CString("setOnPress");
        auto functionObject = JSObjectMakeFunctionWithCallback(ctx, methodName, [] (JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception) {
            auto view = (View *) JSObjectGetPrivate(thisObject);
            // view->setOnPress(Bindings::JSStringToStdString(ctx, (JSStringRef) arguments[0]));
            JSObjectRef callback = (JSObjectRef) arguments[0];
            JSValueProtect(ctx, callback);
            view->setOnPress([ctx, callback] () {
//                auto exception = JSObjectMake(ctx, nullptr, nullptr);
                JSValueRef exception = nullptr;
                JSObjectCallAsFunction(ctx, callback, NULL, 0, NULL, &exception);
                if (exception != nullptr) {
                    auto exMessage = JSObjectGetProperty(ctx, (JSObjectRef) exception, JSStringCreateWithUTF8CString("message"), nullptr);
                    auto message = Bindings::JSStringToStdString(ctx, (JSStringRef) exMessage);
                    std::cout << message << std::endl;
                }
            });
            return JSValueMakeUndefined(ctx);
        });
        JSObjectSetProperty(ctx, prototype, methodName, functionObject, kJSPropertyAttributeReadOnly, NULL);
    }
}




#ifdef REHAX_WITH_APPKIT
void Bindings::bindAppkitToJsc()
{
    defineViewClass<rehax::ui::appkit::impl::View<rehax::ui::RawPtr<JscRegisteredClass>>>(ctx, "View", nullptr);
    bindViewClassMethods<rehax::ui::appkit::impl::View<rehax::ui::RawPtr<JscRegisteredClass>>>(ctx, classRegistry["View"].prototype);
    defineViewClass<rehax::ui::appkit::impl::Text<rehax::ui::RawPtr<JscRegisteredClass>>>(ctx, "Text", classRegistry["View"].prototype);
    bindTextClassMethods<rehax::ui::appkit::impl::Text<rehax::ui::RawPtr<JscRegisteredClass>>>(ctx, classRegistry["Text"].prototype);
    defineViewClass<rehax::ui::appkit::impl::Button<rehax::ui::RawPtr<JscRegisteredClass>>>(ctx, "Button", classRegistry["View"].prototype);
    bindButtonClassMethods<rehax::ui::appkit::impl::Button<rehax::ui::RawPtr<JscRegisteredClass>>>(ctx, classRegistry["Button"].prototype);
}
#endif

#ifdef REHAX_WITH_FLUXE
void Bindings::bindFluxeToJsc()
{
    defineViewClass<rehax::ui::fluxe::impl::View<rehax::ui::RawPtr<JscRegisteredClass>>>(ctx, "View", nullptr);
    bindViewClassMethods<rehax::ui::fluxe::impl::View<rehax::ui::RawPtr<JscRegisteredClass>>>(ctx, classRegistry["View"].prototype);
    defineViewClass<rehax::ui::fluxe::impl::Text<rehax::ui::RawPtr<JscRegisteredClass>>>(ctx, "Text", classRegistry["View"].prototype);
    bindTextClassMethods<rehax::ui::fluxe::impl::Text<rehax::ui::RawPtr<JscRegisteredClass>>>(ctx, classRegistry["Text"].prototype);
    defineViewClass<rehax::ui::fluxe::impl::Button<rehax::ui::RawPtr<JscRegisteredClass>>>(ctx, "Button", classRegistry["View"].prototype);
    bindButtonClassMethods<rehax::ui::fluxe::impl::Button<rehax::ui::RawPtr<JscRegisteredClass>>>(ctx, classRegistry["Button"].prototype);
}
#endif

}
}

#ifdef REHAX_WITH_APPKIT
#include "../native-abstraction/ui/appkit/components/view/View.mm"
#include "../native-abstraction/ui/appkit/components/text/Text.mm"
#include "../native-abstraction/ui/appkit/components/button/Button.mm"
#endif

#ifdef REHAX_WITH_FLUXE
#include "../native-abstraction/ui/fluxe/components/view/View.cc"
#include "../native-abstraction/ui/fluxe/components/text/Text.cc"
#include "../native-abstraction/ui/fluxe/components/button/Button.cc"
#endif
