#include "./bindings.h"
#include <array>

namespace rehax {
namespace quickjs {

// TODO move this to finalizer
// QuickJsContainerData::~QuickJsContainerData() {
//     for (auto value : retainedValues) {
//         JS_FreeValue(ctx, value);
//     }
// }

Bindings::Bindings() {}

void Bindings::setContext(JSContext * ctx, JSRuntime * runtime) {
  this->ctx = ctx;
  this->rt = runtime;
}

RegisteredClass Bindings::getRegisteredClass(std::string name) {
  return classRegistry[name];
}

template <typename View>
JSValue cppToJs(JSContext * ctx, Bindings * bindings, View * obj) {
  auto privateData = new ViewPrivateData<View>();
  privateData->view = obj;
  privateData->bindings = bindings;

  auto className = obj->viewName();
  auto classDefine = bindings->getRegisteredClass(className);

  auto object = JS_NewObjectClass(ctx, kInstanceClassId);
  JS_SetOpaque(object, privateData);
  JS_SetPrototype(ctx, object, classDefine.prototype);
  JS_SetPropertyStr(ctx, object, "__className", JS_NewAtomString(ctx, className.c_str()));
  return object;
}

template <typename View>
void Bindings::defineViewClass(JSContext * ctx, std::string name, JSValue parentPrototype) {
  auto prototypeObject = JS_NewObjectClass(ctx, kPrototypeClassId);
  if (!JS_IsNull(parentPrototype)) {
    JS_SetPrototype(ctx, prototypeObject, parentPrototype);
  }

  classRegistry[name] = RegisteredClass {};
  classRegistry[name].name = name;
  classRegistry[name].prototype = prototypeObject;
  
  auto funData = JS_NewObjectClass(ctx, kPointerClassId);
  JS_SetOpaque(funData, this);
  
  std::array<JSValue, 1> funDataArray {
    funData
  };

  auto classObject = JS_NewCFunctionData(
    ctx,
    [] (JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic, JSValue* func_data) {
      auto bindings = (Bindings *) JS_GetOpaque(func_data[0], kPointerClassId);
      auto view = View::Create();
      return ::rehax::quickjs::cppToJs(ctx, bindings, view);
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
void bindViewClassMethods(JSContext * ctx, JSValue prototype) {
  {
    auto call = [] (JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic, JSValue* func_data) {
      auto privateData = static_cast<ViewPrivateData<View> *>(JS_GetOpaque(this_val, kInstanceClassId));
      View * view = privateData->view;
      return JS_NewAtomString(ctx, view->description().c_str());
    };
    auto functionObject = JS_NewCFunctionData(ctx, call, 0, 0, 0, {});
    JS_SetPropertyStr(ctx, prototype, "toString", functionObject);
  }
  {
    auto call = [] (JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic, JSValue* func_data) {
      auto privateData = static_cast<ViewPrivateData<View> *>(JS_GetOpaque(this_val, kInstanceClassId));
      View * view = privateData->view;

      auto childPrivateData = static_cast<ViewPrivateData<View> *>(JS_GetOpaque(argv[0], kInstanceClassId));
      View * childView = childPrivateData->view;
      
      if (argc <= 1 || JS_IsNull(argv[1]) || JS_IsUndefined(argv[1])) {
        view->addView(childView);
      } else {
        auto beforeView = static_cast<ViewPrivateData<View> *>(JS_GetOpaque(argv[1], kInstanceClassId));
        view->addView(childView, (typename View::PtrType) beforeView);
      }
      return JS_UNDEFINED;
    };

    auto functionObject = JS_NewCFunctionData(ctx, call, 0, 0, 0, {});
    JS_SetPropertyStr(ctx, prototype, "addView", functionObject);
  }
  {
    auto call = [] (JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic, JSValue* func_data) {
      auto privateData = static_cast<ViewPrivateData<View> *>(JS_GetOpaque(this_val, kInstanceClassId));
      View * view = privateData->view;
      view->removeFromParent();
      return JS_UNDEFINED;
    };

    auto functionObject = JS_NewCFunctionData(ctx, call, 0, 0, 0, {});
    JS_SetPropertyStr(ctx, prototype, "removeFromParent", functionObject);
  }
  {
    auto call = [] (JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic, JSValue* func_data) {
      auto privateData = static_cast<ViewPrivateData<View> *>(JS_GetOpaque(this_val, kInstanceClassId));
      View * view = privateData->view;

      auto childPrivateData = static_cast<ViewPrivateData<View> *>(JS_GetOpaque(argv[0], kInstanceClassId));
      View * childView = childPrivateData->view;
      view->removeView(childView);
      return JS_UNDEFINED;
    };

    auto functionObject = JS_NewCFunctionData(ctx, call, 0, 0, 0, {});
    JS_SetPropertyStr(ctx, prototype, "removeView", functionObject);
  }
  {
    auto call = [] (JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic, JSValue* func_data) {
      auto privateData = static_cast<ViewPrivateData<View> *>(JS_GetOpaque(this_val, kInstanceClassId));
      View * view = privateData->view;

      auto parent = view->getParent();
      auto jsParent = ::rehax::quickjs::cppToJs(ctx, privateData->bindings, (typename View::PtrType) parent);
      return jsParent;
    };

    auto functionObject = JS_NewCFunctionData(ctx, call, 0, 0, 0, {});
    JS_SetPropertyStr(ctx, prototype, "getParent", functionObject);
  }
  {
    auto call = [] (JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic, JSValue* func_data) {
      auto privateData = static_cast<ViewPrivateData<View> *>(JS_GetOpaque(this_val, kInstanceClassId));
      View * view = privateData->view;
      auto children = view->children;
      auto firstChild = * children.begin();
      return ::rehax::quickjs::cppToJs(ctx, privateData->bindings, (typename View::PtrType) firstChild);
    };

    auto functionObject = JS_NewCFunctionData(ctx, call, 0, 0, 0, {});
    JS_SetPropertyStr(ctx, prototype, "getFirstChild", functionObject);
  }
  {
    auto call = [] (JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic, JSValue* func_data) {
      auto privateData = static_cast<ViewPrivateData<View> *>(JS_GetOpaque(this_val, kInstanceClassId));
      View * view = privateData->view;
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
      return ::rehax::quickjs::cppToJs(ctx, privateData->bindings, (typename View::PtrType) nextSibling);
    };

    auto functionObject = JS_NewCFunctionData(ctx, call, 0, 0, 0, {});
    JS_SetPropertyStr(ctx, prototype, "getNextSibling", functionObject);
  }
}

template <typename View>
void bindTextClassMethods(JSContext * ctx, JSValue prototype) {
  {
    auto call = [] (JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic, JSValue* func_data) {
      auto privateData = static_cast<ViewPrivateData<View> *>(JS_GetOpaque(this_val, kInstanceClassId));
      View * view = privateData->view;
      view->setText(std::string(JS_ToCString(ctx, argv[0])));
      return JS_UNDEFINED;
    };

    auto functionObject = JS_NewCFunctionData(ctx, call, 0, 0, 0, {});
    JS_SetPropertyStr(ctx, prototype, "setText", functionObject);
  }
  {
    auto call = [] (JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic, JSValue* func_data) {
      auto privateData = static_cast<ViewPrivateData<View> *>(JS_GetOpaque(this_val, kInstanceClassId));
      View * view = privateData->view;
      return JS_NewAtomString(ctx, view->getText().c_str());
    };

    auto functionObject = JS_NewCFunctionData(ctx, call, 0, 0, 0, {});
    JS_SetPropertyStr(ctx, prototype, "getText", functionObject);
  }
}

template <typename View>
void bindButtonClassMethods(JSContext * ctx, JSValue prototype) {
  {
    auto call = [] (JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic, JSValue* func_data) {
      auto privateData = static_cast<ViewPrivateData<View> *>(JS_GetOpaque(this_val, kInstanceClassId));
      View * view = privateData->view;
      view->setTitle(std::string(JS_ToCString(ctx, argv[0])));
      return JS_UNDEFINED;
    };

    auto functionObject = JS_NewCFunctionData(ctx, call, 0, 0, 0, {});
    JS_SetPropertyStr(ctx, prototype, "setTitle", functionObject);
  }
  {
    auto call = [] (JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic, JSValue* func_data) {
      auto privateData = static_cast<ViewPrivateData<View> *>(JS_GetOpaque(this_val, kInstanceClassId));
      View * view = privateData->view;
      JSValue callback = JS_DupValue(ctx, argv[0]);
      privateData->retainedValues.push_back(callback);
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
void Bindings::bindAppkitToQuickJs() {
  defineViewClass<rehax::ui::appkit::impl::View<rehax::ui::RawPtr>>(ctx, "View", JS_NULL);
  bindViewClassMethods<rehax::ui::appkit::impl::View<rehax::ui::RawPtr>>(ctx, classRegistry["View"].prototype);
  defineViewClass<rehax::ui::appkit::impl::Text<rehax::ui::RawPtr>>(ctx, "Text", classRegistry["View"].prototype);
  bindTextClassMethods<rehax::ui::appkit::impl::Text<rehax::ui::RawPtr>>(ctx, classRegistry["Text"].prototype);
  defineViewClass<rehax::ui::appkit::impl::Button<rehax::ui::RawPtr>>(ctx, "Button", classRegistry["View"].prototype);
  bindButtonClassMethods<rehax::ui::appkit::impl::Button<rehax::ui::RawPtr>>(ctx, classRegistry["Button"].prototype);
}
#endif

#ifdef REHAX_WITH_FLUXE
void Bindings::bindFluxeToQuickJs() {
  defineViewClass<rehax::ui::fluxe::impl::View<rehax::ui::RawPtr>>(ctx, "View", JS_NULL);
  bindViewClassMethods<rehax::ui::fluxe::impl::View<rehax::ui::RawPtr>>(ctx, classRegistry["View"].prototype);
  defineViewClass<rehax::ui::fluxe::impl::Text<rehax::ui::RawPtr>>(ctx, "Text", classRegistry["View"].prototype);
  bindTextClassMethods<rehax::ui::fluxe::impl::Text<rehax::ui::RawPtr>>(ctx, classRegistry["Text"].prototype);
  defineViewClass<rehax::ui::fluxe::impl::Button<rehax::ui::RawPtr>>(ctx, "Button", classRegistry["View"].prototype);
  bindButtonClassMethods<rehax::ui::fluxe::impl::Button<rehax::ui::RawPtr>>(ctx, classRegistry["Button"].prototype);
}
#endif

}
}


#ifdef REHAX_WITH_APPKIT
#include "../../native-abstraction/ui/appkit/components/view/View.mm"
#include "../../native-abstraction/ui/appkit/components/text/Text.mm"
#include "../../native-abstraction/ui/appkit/components/button/Button.mm"
#endif

#ifdef REHAX_WITH_FLUXE
#include "../../native-abstraction/ui/fluxe/components/view/View.cc"
#include "../../native-abstraction/ui/fluxe/components/text/Text.cc"
#include "../../native-abstraction/ui/fluxe/components/button/Button.cc"
#endif
