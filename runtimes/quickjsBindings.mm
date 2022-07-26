#include "quickjsBindings.h"
#include <array>

namespace rehax {
namespace quickjs {

QuickJsContainerData::~QuickJsContainerData()
{
    for (auto value : retainedValues)
    {
        JS_FreeValue(ctx, value);
    }
}

Bindings::Bindings()
{}

void Bindings::setContext(JSContext * ctx, JSRuntime * runtime)
{
  JS_SetOpaque(JS_GetGlobalObject(ctx), this);
  this->ctx = ctx;
  this->rt = runtime;
}

JSValue cppToJs(JSContext * ctx, QuickJsRegisteredClass classDefine, void * obj)
{
    auto object = JS_NewObjectClass(ctx, kInstanceClassId);
    JS_SetOpaque(object, obj);
    JS_SetPrototype(ctx, object, classDefine.prototype);
    JS_SetPropertyStr(ctx, object, "__className", JS_NewAtomString(ctx, classDefine.name.c_str()));
    return object;
}

template <typename View>
void Bindings::defineViewClass(JSContext * ctx, std::string name, JSValue parentPrototype)
{
    auto prototypeObject = JS_NewObjectClass(ctx, kPrototypeClassId);
    if (!JS_IsNull(parentPrototype)) {
        JS_SetPrototype(ctx, prototypeObject, parentPrototype);
    }

    classRegistry[name] = QuickJsRegisteredClass {};
    classRegistry[name].name = name;
    classRegistry[name].prototype = prototypeObject;
    
    auto funData = JS_NewObjectClass(ctx, kPointerClassId);
    JS_SetOpaque(funData, &classRegistry[name]);
    
    std::array<JSValue, 1> funDataArray {
        funData
    };

    auto classObject = JS_NewCFunctionData(
        ctx,
        [] (JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic, JSValue* func_data) {
            QuickJsRegisteredClass * registeredClass = (QuickJsRegisteredClass *) JS_GetOpaque(func_data[0], kPointerClassId);
            auto view = View::Create();
            view->containerAdditionalData = {
                .ctx = ctx,
                .registeredClass = registeredClass,
            };
            return ::rehax::quickjs::cppToJs(ctx, *registeredClass, view);
        },
        0, 0, funDataArray.size(), funDataArray.data()
    );

    for (auto v : funDataArray) {
      JS_FreeValue(ctx, v);
    }
    
    JS_SetConstructorBit(ctx, classObject, true);
    auto globalContext = JS_GetGlobalObject(ctx);
    JS_SetPropertyStr(ctx, globalContext, name.c_str(), classObject);
}

 template <typename View>
 void bindViewClassMethods(JSContext * ctx, JSValue prototype)
 {
     {
         auto call = [] (JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic, JSValue* func_data) {
             View * view = (View *) JS_GetOpaque(this_val, kInstanceClassId);
             auto childView = (View *) JS_GetOpaque(argv[0], kInstanceClassId);
             
             if (argc <= 1 || JS_IsNull(argv[1]) || JS_IsUndefined(argv[1])) {
                 view->addView(childView);
             } else {
                 auto beforeView = (View *) JS_GetOpaque(argv[1], kInstanceClassId);
                 view->addView(childView, beforeView);
             }
             return JS_UNDEFINED;
         };

         auto functionObject = JS_NewCFunctionData(ctx, call, 0, 0, 0, {});
         JS_SetPropertyStr(ctx, prototype, "addView", functionObject);
     }
     {
         auto call = [] (JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic, JSValue* func_data) {
             View * view = (View *) JS_GetOpaque(this_val, kInstanceClassId);
             view->removeFromParent();
             return JS_UNDEFINED;
         };

         auto functionObject = JS_NewCFunctionData(ctx, call, 0, 0, 0, {});
         JS_SetPropertyStr(ctx, prototype, "removeFromParent", functionObject);
     }
     {
         auto call = [] (JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic, JSValue* func_data) {
             View * view = (View *) JS_GetOpaque(this_val, kInstanceClassId);
             auto childView = (View *) JS_GetOpaque(argv[0], kInstanceClassId);
             view->removeView(childView);
             return JS_UNDEFINED;
         };

         auto functionObject = JS_NewCFunctionData(ctx, call, 0, 0, 0, {});
         JS_SetPropertyStr(ctx, prototype, "removeView", functionObject);
     }
     {
         auto call = [] (JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic, JSValue* func_data) {
             View * view = (View *) JS_GetOpaque(this_val, kInstanceClassId);
             auto parent = view->getParent();
             auto classDef = parent->containerAdditionalData.registeredClass;
             auto jsParent = ::rehax::quickjs::cppToJs(ctx, *classDef, parent);
             return jsParent;
         };

         auto functionObject = JS_NewCFunctionData(ctx, call, 0, 0, 0, {});
         JS_SetPropertyStr(ctx, prototype, "getParent", functionObject);
     }
     {
         auto call = [] (JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic, JSValue* func_data) {
             View * view = (View *) JS_GetOpaque(this_val, kInstanceClassId);
             auto children = view->children;
             auto firstChild = * children.begin();
             return ::rehax::quickjs::cppToJs(ctx, *firstChild->containerAdditionalData.registeredClass, firstChild);
         };

         auto functionObject = JS_NewCFunctionData(ctx, call, 0, 0, 0, {});
         JS_SetPropertyStr(ctx, prototype, "getFirstChild", functionObject);
     }
     {
         auto call = [] (JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic, JSValue* func_data) {
             View * view = (View *) JS_GetOpaque(this_val, kInstanceClassId);
            // TODO this should probably be moved to the core
             auto parent = view->getParent();
             if (parent == nullptr) {
                 return JS_NULL;
             }
             auto it = parent->children.find(view);
             it++;
             if (it == parent->children.end()) {
                 return JS_NULL;
             }
             auto nextSibling = * it;
             return ::rehax::quickjs::cppToJs(ctx, *nextSibling->containerAdditionalData.registeredClass, nextSibling);
         };

         auto functionObject = JS_NewCFunctionData(ctx, call, 0, 0, 0, {});
         JS_SetPropertyStr(ctx, prototype, "getNextSibling", functionObject);
     }
 }

 template <typename View>
 void bindTextClassMethods(JSContext * ctx, JSValue prototype)
 {
     {
         auto call = [] (JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic, JSValue* func_data) {
             View * view = (View *) JS_GetOpaque(this_val, kInstanceClassId);
             view->setText(std::string(JS_ToCString(ctx, argv[0])));
             return JS_UNDEFINED;
         };

         auto functionObject = JS_NewCFunctionData(ctx, call, 0, 0, 0, {});
         JS_SetPropertyStr(ctx, prototype, "setText", functionObject);
     }
     {
         auto call = [] (JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic, JSValue* func_data) {
             View * view = (View *) JS_GetOpaque(this_val, kInstanceClassId);
             return JS_NewAtomString(ctx, view->getText().c_str());
         };

         auto functionObject = JS_NewCFunctionData(ctx, call, 0, 0, 0, {});
         JS_SetPropertyStr(ctx, prototype, "getText", functionObject);
     }
 }

 template <typename View>
 void bindButtonClassMethods(JSContext * ctx, JSValue prototype)
 {
     {
         auto call = [] (JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic, JSValue* func_data) {
            View * view = (View *) JS_GetOpaque(this_val, kInstanceClassId);
            view->setTitle(std::string(JS_ToCString(ctx, argv[0])));
            return JS_UNDEFINED;
         };

         auto functionObject = JS_NewCFunctionData(ctx, call, 0, 0, 0, {});
         JS_SetPropertyStr(ctx, prototype, "setTitle", functionObject);
     }
     {
         auto call = [] (JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic, JSValue* func_data) {
            View * view = (View *) JS_GetOpaque(this_val, kInstanceClassId);
            JSValue callback = JS_DupValue(ctx, argv[0]);
            view->containerAdditionalData.retainedValues.push_back(callback);
            view->setOnPress([ctx, callback, this_val] () {
                JS_Call(ctx, callback, this_val, 0, {});
            });
            return JS_UNDEFINED;
         };

         auto functionObject = JS_NewCFunctionData(ctx, call, 0, 0, 0, {});
         JS_SetPropertyStr(ctx, prototype, "setOnPress", functionObject);
     }
 }




#ifdef REHAX_WITH_APPKIT
void Bindings::bindAppkitToQuickJs()
{
    defineViewClass<rehax::ui::appkit::impl::View<rehax::ui::RawPtr<QuickJsContainerData>>>(ctx, "View", JS_NULL);
    bindViewClassMethods<rehax::ui::appkit::impl::View<rehax::ui::RawPtr<QuickJsContainerData>>>(ctx, classRegistry["View"].prototype);
    defineViewClass<rehax::ui::appkit::impl::Text<rehax::ui::RawPtr<QuickJsContainerData>>>(ctx, "Text", classRegistry["View"].prototype);
    bindTextClassMethods<rehax::ui::appkit::impl::Text<rehax::ui::RawPtr<QuickJsContainerData>>>(ctx, classRegistry["Text"].prototype);
    defineViewClass<rehax::ui::appkit::impl::Button<rehax::ui::RawPtr<QuickJsContainerData>>>(ctx, "Button", classRegistry["View"].prototype);
    bindButtonClassMethods<rehax::ui::appkit::impl::Button<rehax::ui::RawPtr<QuickJsContainerData>>>(ctx, classRegistry["Button"].prototype);
}
#endif

#ifdef REHAX_WITH_FLUXE
void Bindings::bindFluxeToQuickJs()
{
    defineViewClass<rehax::ui::fluxe::impl::View<rehax::ui::RawPtr<QuickJsContainerData>>>(ctx, "View", JS_NULL);
    bindViewClassMethods<rehax::ui::fluxe::impl::View<rehax::ui::RawPtr<QuickJsContainerData>>>(ctx, classRegistry["View"].prototype);
    defineViewClass<rehax::ui::fluxe::impl::Text<rehax::ui::RawPtr<QuickJsContainerData>>>(ctx, "Text", classRegistry["View"].prototype);
    bindTextClassMethods<rehax::ui::fluxe::impl::Text<rehax::ui::RawPtr<QuickJsContainerData>>>(ctx, classRegistry["Text"].prototype);
    defineViewClass<rehax::ui::fluxe::impl::Button<rehax::ui::RawPtr<QuickJsContainerData>>>(ctx, "Button", classRegistry["View"].prototype);
    bindButtonClassMethods<rehax::ui::fluxe::impl::Button<rehax::ui::RawPtr<QuickJsContainerData>>>(ctx, classRegistry["Button"].prototype);
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
