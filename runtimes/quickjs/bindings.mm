#include "./bindings.h"
#include <array>

namespace rehax {
namespace quickjs {

Bindings::Bindings() {}

void finalizeViewInstance(JSRuntime *rt, JSValue val) {
  auto bindings = static_cast<Bindings*>(JS_GetRuntimeOpaque(rt));
  auto privateData = static_cast<ViewPrivateData<rehax::ui::fluxe::impl::View<rehax::ui::RefCountedPointer>> *>(JS_GetOpaque(val, bindings->instanceClassId));
  auto ctx = privateData->context;
  for (auto value : privateData->retainedValues) {
    JS_FreeValue(ctx, value);
  }
   std::cout << "GC" << std::endl;
  auto view = privateData->view;
  view->decreaseReferenceCount();
  delete privateData;
}

void Bindings::setContext(JSContext * ctx, JSRuntime * runtime) {
  this->ctx = ctx;
  this->rt = runtime;
  JS_SetRuntimeOpaque(rt, this);
    
  JS_NewClassID(&instanceClassId);
  JSClassDef classDef;
  classDef.class_name = "ViewInstance";
  classDef.finalizer = finalizeViewInstance;
  auto classId = JS_NewClass(runtime, instanceClassId, &classDef);
  instanceClassId = classId;
}

RegisteredClass Bindings::getRegisteredClass(std::string name) {
  return classRegistry[name];
}

template <typename View>
JSValue cppToJs(JSContext * ctx, Bindings * bindings, View * obj) {
  auto privateData = new ViewPrivateData<View>();
  privateData->view = obj;
  privateData->bindings = bindings;
  privateData->context = ctx;

  auto className = obj->viewName();
  auto classDefine = bindings->getRegisteredClass(className);

  obj->increaseReferenceCount(); // decreased in finalizer

  auto object = JS_NewObjectClass(ctx, bindings->instanceClassId);
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
      return ::rehax::quickjs::cppToJs(ctx, bindings, view.get());
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
void bindViewClassMethods(JSContext * ctx, Bindings *bindings, JSValue prototype) {
  {
    auto funData = JS_NewObjectClass(ctx, kPointerClassId);
    JS_SetOpaque(funData, bindings);
    std::array<JSValue, 1> funDataArray {
      funData
    };
    auto call = [] (JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic, JSValue* func_data) {
      auto bindings = (Bindings *) JS_GetOpaque(func_data[0], kPointerClassId);
      auto privateData = static_cast<ViewPrivateData<View> *>(JS_GetOpaque(this_val, bindings->instanceClassId));
      View * view = privateData->view;
      return JS_NewAtomString(ctx, view->description().c_str());
    };
    auto functionObject = JS_NewCFunctionData(ctx, call, 0, 0, funDataArray.size(), funDataArray.data());
    JS_SetPropertyStr(ctx, prototype, "toString", functionObject);
    for (auto v : funDataArray) {
      JS_FreeValue(ctx, v);
    }
  }
  {
    auto funData = JS_NewObjectClass(ctx, kPointerClassId);
    JS_SetOpaque(funData, bindings);
    std::array<JSValue, 1> funDataArray {
      funData
    };
    auto call = [] (JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic, JSValue* func_data) {
      auto bindings = (Bindings *) JS_GetOpaque(func_data[0], kPointerClassId);
      auto privateData = static_cast<ViewPrivateData<View> *>(JS_GetOpaque(this_val, bindings->instanceClassId));
      View * view = privateData->view;

      auto childPrivateData = static_cast<ViewPrivateData<View> *>(JS_GetOpaque(argv[0], bindings->instanceClassId));
      View * childView = childPrivateData->view;
      
      if (argc <= 1 || JS_IsNull(argv[1]) || JS_IsUndefined(argv[1])) {
        view->addView(childView);
      } else {
        auto beforeViewPrivateData = static_cast<ViewPrivateData<View> *>(JS_GetOpaque(argv[1], bindings->instanceClassId));
        View * beforeView = beforeViewPrivateData->view;
        view->addView(childView, beforeView);
      }
      return JS_UNDEFINED;
    };

    auto functionObject = JS_NewCFunctionData(ctx, call, 0, 0, funDataArray.size(), funDataArray.data());
    JS_SetPropertyStr(ctx, prototype, "addView", functionObject);
    for (auto v : funDataArray) {
      JS_FreeValue(ctx, v);
    }
  }
  {
    auto funData = JS_NewObjectClass(ctx, kPointerClassId);
    JS_SetOpaque(funData, bindings);
    std::array<JSValue, 1> funDataArray {
      funData
    };
    auto call = [] (JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic, JSValue* func_data) {
      auto bindings = (Bindings *) JS_GetOpaque(func_data[0], kPointerClassId);
      auto privateData = static_cast<ViewPrivateData<View> *>(JS_GetOpaque(this_val, bindings->instanceClassId));
      View * view = privateData->view;
      view->removeFromParent();
      return JS_UNDEFINED;
    };

    auto functionObject = JS_NewCFunctionData(ctx, call, 0, 0, funDataArray.size(), funDataArray.data());
    JS_SetPropertyStr(ctx, prototype, "removeFromParent", functionObject);
    for (auto v : funDataArray) {
      JS_FreeValue(ctx, v);
    }
  }
  {
    auto funData = JS_NewObjectClass(ctx, kPointerClassId);
    JS_SetOpaque(funData, bindings);
    std::array<JSValue, 1> funDataArray {
      funData
    };
    auto call = [] (JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic, JSValue* func_data) {
      auto bindings = (Bindings *) JS_GetOpaque(func_data[0], kPointerClassId);
      auto privateData = static_cast<ViewPrivateData<View> *>(JS_GetOpaque(this_val, bindings->instanceClassId));
      View * view = privateData->view;

      auto childPrivateData = static_cast<ViewPrivateData<View> *>(JS_GetOpaque(argv[0], bindings->instanceClassId));
      View * childView = childPrivateData->view;
      view->removeView(childView);
      return JS_UNDEFINED;
    };

    auto functionObject = JS_NewCFunctionData(ctx, call, 0, 0, funDataArray.size(), funDataArray.data());
    JS_SetPropertyStr(ctx, prototype, "removeView", functionObject);
    for (auto v : funDataArray) {
      JS_FreeValue(ctx, v);
    }
  }
  {
    auto funData = JS_NewObjectClass(ctx, kPointerClassId);
    JS_SetOpaque(funData, bindings);
    std::array<JSValue, 1> funDataArray {
      funData
    };
    auto call = [] (JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic, JSValue* func_data) {
      auto bindings = (Bindings *) JS_GetOpaque(func_data[0], kPointerClassId);
      auto privateData = static_cast<ViewPrivateData<View> *>(JS_GetOpaque(this_val, bindings->instanceClassId));
      View * view = privateData->view;

      auto parent = view->getParent();
      if (!parent.isValid()) {
        return JS_NULL;
      }
        
      View * parentView = dynamic_cast<View *>(parent.get());
      auto jsParent = ::rehax::quickjs::cppToJs(ctx, privateData->bindings, parentView);
      return jsParent;
    };

    auto functionObject = JS_NewCFunctionData(ctx, call, 0, 0, funDataArray.size(), funDataArray.data());
    JS_SetPropertyStr(ctx, prototype, "getParent", functionObject);
    for (auto v : funDataArray) {
      JS_FreeValue(ctx, v);
    }
  }
  {
    auto funData = JS_NewObjectClass(ctx, kPointerClassId);
    JS_SetOpaque(funData, bindings);
    std::array<JSValue, 1> funDataArray {
      funData
    };
    auto call = [] (JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic, JSValue* func_data) {
      auto bindings = (Bindings *) JS_GetOpaque(func_data[0], kPointerClassId);
      auto privateData = static_cast<ViewPrivateData<View> *>(JS_GetOpaque(this_val, bindings->instanceClassId));
      View * view = privateData->view;
      auto children = view->children;
      auto firstChild = * children.begin();
      View * firstChildView = dynamic_cast<View *>(firstChild);
      return ::rehax::quickjs::cppToJs(ctx, privateData->bindings, firstChildView);
    };

    auto functionObject = JS_NewCFunctionData(ctx, call, 0, 0, funDataArray.size(), funDataArray.data());
    JS_SetPropertyStr(ctx, prototype, "getFirstChild", functionObject);
    for (auto v : funDataArray) {
      JS_FreeValue(ctx, v);
    }
  }
  {
    auto funData = JS_NewObjectClass(ctx, kPointerClassId);
    JS_SetOpaque(funData, bindings);
    std::array<JSValue, 1> funDataArray {
      funData
    };
    auto call = [] (JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic, JSValue* func_data) {
      auto bindings = (Bindings *) JS_GetOpaque(func_data[0], kPointerClassId);
      auto privateData = static_cast<ViewPrivateData<View> *>(JS_GetOpaque(this_val, bindings->instanceClassId));
      View * view = privateData->view;
    // TODO this should probably be moved to the core
      auto parent = view->getParent();
      if (!parent.isValid()) {
        return JS_NULL;
      }
      auto it = parent->children.find(view);
      it++;
      if (it == parent->children.end()) {
        return JS_NULL;
      }
      auto nextSibling = * it;
      View * siblingView = dynamic_cast<View *>(nextSibling);
      return ::rehax::quickjs::cppToJs(ctx, privateData->bindings, siblingView);
    };

    auto functionObject = JS_NewCFunctionData(ctx, call, 0, 0, funDataArray.size(), funDataArray.data());
    JS_SetPropertyStr(ctx, prototype, "getNextSibling", functionObject);
    for (auto v : funDataArray) {
      JS_FreeValue(ctx, v);
    }
  }
}

template <typename View>
void bindButtonClassMethods(JSContext * ctx, Bindings *bindings, JSValue prototype) {
  {
    auto funData = JS_NewObjectClass(ctx, kPointerClassId);
    JS_SetOpaque(funData, bindings);
    std::array<JSValue, 1> funDataArray {
      funData
    };
    auto call = [] (JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic, JSValue* func_data) {
      auto bindings = (Bindings *) JS_GetOpaque(func_data[0], kPointerClassId);
      auto privateData = static_cast<ViewPrivateData<View> *>(JS_GetOpaque(this_val, bindings->instanceClassId));
      View * view = privateData->view;
      view->setTitle(std::string(JS_ToCString(ctx, argv[0])));
      return JS_UNDEFINED;
    };

    auto functionObject = JS_NewCFunctionData(ctx, call, 0, 0, funDataArray.size(), funDataArray.data());
    JS_SetPropertyStr(ctx, prototype, "setTitle", functionObject);
    for (auto v : funDataArray) {
      JS_FreeValue(ctx, v);
    }
  }
  {
    auto funData = JS_NewObjectClass(ctx, kPointerClassId);
    JS_SetOpaque(funData, bindings);
    std::array<JSValue, 1> funDataArray {
      funData
    };
    auto call = [] (JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic, JSValue* func_data) {
      auto bindings = (Bindings *) JS_GetOpaque(func_data[0], kPointerClassId);
      auto privateData = static_cast<ViewPrivateData<View> *>(JS_GetOpaque(this_val, bindings->instanceClassId));
      View * view = privateData->view;
      JSValue callback = JS_DupValue(ctx, argv[0]);
      privateData->retainedValues.push_back(callback);
      view->setOnPress([ctx, callback, this_val] () {
        JS_Call(ctx, callback, this_val, 0, {});
      });
      return JS_UNDEFINED;
    };

    auto functionObject = JS_NewCFunctionData(ctx, call, 0, 0, funDataArray.size(), funDataArray.data());
    JS_SetPropertyStr(ctx, prototype, "setOnPress", functionObject);
    for (auto v : funDataArray) {
      JS_FreeValue(ctx, v);
    }
  }
}

template <typename View>
void bindTextClassMethods(JSContext * ctx, Bindings *bindings, JSValue prototype) {
  {
    auto funData = JS_NewObjectClass(ctx, kPointerClassId);
    JS_SetOpaque(funData, bindings);
    std::array<JSValue, 1> funDataArray {
      funData
    };
    auto call = [] (JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic, JSValue* func_data) {
      auto bindings = (Bindings *) JS_GetOpaque(func_data[0], kPointerClassId);
      auto privateData = static_cast<ViewPrivateData<View> *>(JS_GetOpaque(this_val, bindings->instanceClassId));
      View * view = privateData->view;
      view->setText(std::string(JS_ToCString(ctx, argv[0])));
      return JS_UNDEFINED;
    };

    auto functionObject = JS_NewCFunctionData(ctx, call, 0, 0, funDataArray.size(), funDataArray.data());
    JS_SetPropertyStr(ctx, prototype, "setText", functionObject);
    for (auto v : funDataArray) {
      JS_FreeValue(ctx, v);
    }
  }
  {
    auto funData = JS_NewObjectClass(ctx, kPointerClassId);
    JS_SetOpaque(funData, bindings);
    std::array<JSValue, 1> funDataArray {
      funData
    };
    auto call = [] (JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic, JSValue* func_data) {
      auto bindings = (Bindings *) JS_GetOpaque(func_data[0], kPointerClassId);
      auto privateData = static_cast<ViewPrivateData<View> *>(JS_GetOpaque(this_val, bindings->instanceClassId));
      View * view = privateData->view;
      return JS_NewAtomString(ctx, view->getText().c_str());
    };

    auto functionObject = JS_NewCFunctionData(ctx, call, 0, 0, funDataArray.size(), funDataArray.data());
    JS_SetPropertyStr(ctx, prototype, "getText", functionObject);
    for (auto v : funDataArray) {
      JS_FreeValue(ctx, v);
    }
  }
}


template <typename View>
void bindTextInputClassMethods(JSContext * ctx, Bindings *bindings, JSValue prototype) {
  {
    auto funData = JS_NewObjectClass(ctx, kPointerClassId);
    JS_SetOpaque(funData, bindings);
    std::array<JSValue, 1> funDataArray {
      funData
    };
    auto call = [] (JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic, JSValue* func_data) {
      auto bindings = (Bindings *) JS_GetOpaque(func_data[0], kPointerClassId);
      auto privateData = static_cast<ViewPrivateData<View> *>(JS_GetOpaque(this_val, bindings->instanceClassId));
      View * view = privateData->view;
      view->setValue(std::string(JS_ToCString(ctx, argv[0])));
      return JS_UNDEFINED;
    };

    auto functionObject = JS_NewCFunctionData(ctx, call, 0, 0, funDataArray.size(), funDataArray.data());
    JS_SetPropertyStr(ctx, prototype, "setValue", functionObject);
    for (auto v : funDataArray) {
      JS_FreeValue(ctx, v);
    }
  }
  {
    auto funData = JS_NewObjectClass(ctx, kPointerClassId);
    JS_SetOpaque(funData, bindings);
    std::array<JSValue, 1> funDataArray {
      funData
    };
    auto call = [] (JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic, JSValue* func_data) {
      auto bindings = (Bindings *) JS_GetOpaque(func_data[0], kPointerClassId);
      auto privateData = static_cast<ViewPrivateData<View> *>(JS_GetOpaque(this_val, bindings->instanceClassId));
      View * view = privateData->view;
      return JS_NewAtomString(ctx, view->getValue().c_str());
    };

    auto functionObject = JS_NewCFunctionData(ctx, call, 0, 0, funDataArray.size(), funDataArray.data());
    JS_SetPropertyStr(ctx, prototype, "getValue", functionObject);
    for (auto v : funDataArray) {
      JS_FreeValue(ctx, v);
    }
  }
}


#ifdef REHAX_WITH_APPKIT
void Bindings::bindAppkitToQuickJs() {
  defineViewClass<rehax::ui::appkit::impl::View<rehax::ui::RefCountedPointer>>(ctx, "View", JS_NULL);
  bindViewClassMethods<rehax::ui::appkit::impl::View<rehax::ui::RefCountedPointer>>(ctx, this, classRegistry["View"].prototype);
  defineViewClass<rehax::ui::appkit::impl::Button<rehax::ui::RefCountedPointer>>(ctx, "Button", classRegistry["View"].prototype);
  bindButtonClassMethods<rehax::ui::appkit::impl::Button<rehax::ui::RefCountedPointer>>(ctx, this, classRegistry["Button"].prototype);
  defineViewClass<rehax::ui::appkit::impl::Text<rehax::ui::RefCountedPointer>>(ctx, "Text", classRegistry["View"].prototype);
  bindTextClassMethods<rehax::ui::appkit::impl::Text<rehax::ui::RefCountedPointer>>(ctx, this, classRegistry["Text"].prototype);
  defineViewClass<rehax::ui::appkit::impl::TextInput<rehax::ui::RefCountedPointer>>(ctx, "TextInput", classRegistry["View"].prototype);
  bindTextInputClassMethods<rehax::ui::appkit::impl::TextInput<rehax::ui::RefCountedPointer>>(ctx, this, classRegistry["TextInput"].prototype);
}
#endif

#ifdef REHAX_WITH_FLUXE
void Bindings::bindFluxeToQuickJs() {
  defineViewClass<rehax::ui::fluxe::impl::View<rehax::ui::RefCountedPointer>>(ctx, "View", JS_NULL);
  bindViewClassMethods<rehax::ui::fluxe::impl::View<rehax::ui::RefCountedPointer>>(ctx, this, classRegistry["View"].prototype);
  defineViewClass<rehax::ui::fluxe::impl::Button<rehax::ui::RefCountedPointer>>(ctx, "Button", classRegistry["View"].prototype);
  bindButtonClassMethods<rehax::ui::fluxe::impl::Button<rehax::ui::RefCountedPointer>>(ctx, this, classRegistry["Button"].prototype);
  defineViewClass<rehax::ui::fluxe::impl::Text<rehax::ui::RefCountedPointer>>(ctx, "Text", classRegistry["View"].prototype);
  bindTextClassMethods<rehax::ui::fluxe::impl::Text<rehax::ui::RefCountedPointer>>(ctx, this, classRegistry["Text"].prototype);
  defineViewClass<rehax::ui::fluxe::impl::TextInput<rehax::ui::RefCountedPointer>>(ctx, "TextInput", classRegistry["View"].prototype);
  bindTextInputClassMethods<rehax::ui::fluxe::impl::TextInput<rehax::ui::RefCountedPointer>>(ctx, this, classRegistry["TextInput"].prototype);
}
#endif

}
}


#ifdef REHAX_WITH_APPKIT
#include "../../native-abstraction/ui/appkit/components/view/View.mm"
#include "../../native-abstraction/ui/appkit/components/button/Button.mm"
#include "../../native-abstraction/ui/appkit/components/text/Text.mm"
#include "../../native-abstraction/ui/appkit/components/textInput/TextInput.mm"
#endif

#ifdef REHAX_WITH_FLUXE
#include "../../native-abstraction/ui/fluxe/components/view/View.cc"
#include "../../native-abstraction/ui/fluxe/components/button/Button.cc"
#include "../../native-abstraction/ui/fluxe/components/text/Text.cc"
#include "../../native-abstraction/ui/fluxe/components/textInput/TextInput.cc"
#endif
