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

template <typename T>
T jsToCpp(JSContext * ctx, JSValue value) {
  return T();
}

template <>
std::string jsToCpp(JSContext * ctx, JSValue value) {
  if (JS_IsString(value)) {
    return JS_ToCString(ctx, value);
  }
  return "";
}

template <>
float jsToCpp(JSContext * ctx, JSValue value) {
  if (JS_IsNumber(value)) {
    double val;
    JS_ToFloat64(ctx, &val, value);
    return val;
  }
  return 0;
}

template <typename View, void (View::*Method)(void)>
void bindMethod(std::string name, JSContext * ctx, Bindings *bindings, JSValue prototype) {
  auto funData = JS_NewObjectClass(ctx, kPointerClassId);
  JS_SetOpaque(funData, bindings);
  std::array<JSValue, 1> funDataArray {
    funData
  };
  auto call = [] (JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic, JSValue* func_data) {
    auto bindings = (Bindings *) JS_GetOpaque(func_data[0], kPointerClassId);
    auto privateData = static_cast<ViewPrivateData<View> *>(JS_GetOpaque(this_val, bindings->instanceClassId));
    View * view = privateData->view;
    (view->*Method)();
    return JS_UNDEFINED;
  };

  auto functionObject = JS_NewCFunctionData(ctx, call, 0, 0, funDataArray.size(), funDataArray.data());
  JS_SetPropertyStr(ctx, prototype, name.c_str(), functionObject);
  for (auto v : funDataArray) {
    JS_FreeValue(ctx, v);
  }
}

template <typename View, void (View::*Method)(std::string)>
void bindMethod(std::string name, JSContext * ctx, Bindings *bindings, JSValue prototype) {
  auto funData = JS_NewObjectClass(ctx, kPointerClassId);
  JS_SetOpaque(funData, bindings);
  std::array<JSValue, 1> funDataArray {
    funData
  };
  auto call = [] (JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic, JSValue* func_data) {
    auto bindings = (Bindings *) JS_GetOpaque(func_data[0], kPointerClassId);
    auto privateData = static_cast<ViewPrivateData<View> *>(JS_GetOpaque(this_val, bindings->instanceClassId));
    View * view = privateData->view;
    (view->*Method)(jsToCpp<std::string>(ctx, argv[0]));
    return JS_UNDEFINED;
  };

  auto functionObject = JS_NewCFunctionData(ctx, call, 0, 0, funDataArray.size(), funDataArray.data());
  JS_SetPropertyStr(ctx, prototype, name.c_str(), functionObject);
  for (auto v : funDataArray) {
    JS_FreeValue(ctx, v);
  }
}

template <typename View, std::string (View::*Method)(void)>
void bindMethod(std::string name, JSContext * ctx, Bindings *bindings, JSValue prototype) {
  auto funData = JS_NewObjectClass(ctx, kPointerClassId);
  JS_SetOpaque(funData, bindings);
  std::array<JSValue, 1> funDataArray {
    funData
  };
  auto call = [] (JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic, JSValue* func_data) {
    auto bindings = (Bindings *) JS_GetOpaque(func_data[0], kPointerClassId);
    auto privateData = static_cast<ViewPrivateData<View> *>(JS_GetOpaque(this_val, bindings->instanceClassId));
    View * view = privateData->view;
    return JS_NewAtomString(ctx, (view->*Method)().c_str());
  };

  auto functionObject = JS_NewCFunctionData(ctx, call, 0, 0, funDataArray.size(), funDataArray.data());
  JS_SetPropertyStr(ctx, prototype, name.c_str(), functionObject);
  for (auto v : funDataArray) {
    JS_FreeValue(ctx, v);
  }
}

template <typename View, void (View::*Method)(float)>
void bindMethod(std::string name, JSContext * ctx, Bindings *bindings, JSValue prototype) {
  auto funData = JS_NewObjectClass(ctx, kPointerClassId);
  JS_SetOpaque(funData, bindings);
  std::array<JSValue, 1> funDataArray {
    funData
  };
  auto call = [] (JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic, JSValue* func_data) {
    auto bindings = (Bindings *) JS_GetOpaque(func_data[0], kPointerClassId);
    auto privateData = static_cast<ViewPrivateData<View> *>(JS_GetOpaque(this_val, bindings->instanceClassId));
    View * view = privateData->view;
    (view->*Method)(jsToCpp<float>(ctx, argv[0]));
    return JS_UNDEFINED;
  };

  auto functionObject = JS_NewCFunctionData(ctx, call, 0, 0, funDataArray.size(), funDataArray.data());
  JS_SetPropertyStr(ctx, prototype, name.c_str(), functionObject);
  for (auto v : funDataArray) {
    JS_FreeValue(ctx, v);
  }
}

template <typename View, void (View::*Method)(float, float)>
void bindMethod(std::string name, JSContext * ctx, Bindings *bindings, JSValue prototype) {
  auto funData = JS_NewObjectClass(ctx, kPointerClassId);
  JS_SetOpaque(funData, bindings);
  std::array<JSValue, 1> funDataArray {
    funData
  };
  auto call = [] (JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic, JSValue* func_data) {
    auto bindings = (Bindings *) JS_GetOpaque(func_data[0], kPointerClassId);
    auto privateData = static_cast<ViewPrivateData<View> *>(JS_GetOpaque(this_val, bindings->instanceClassId));
    View * view = privateData->view;
    double val1;
    JS_ToFloat64(ctx, &val1, argv[0]);
    double val2;
    JS_ToFloat64(ctx, &val2, argv[1]);
    (view->*Method)(val1, val2);
    return JS_UNDEFINED;
  };

  auto functionObject = JS_NewCFunctionData(ctx, call, 0, 0, funDataArray.size(), funDataArray.data());
  JS_SetPropertyStr(ctx, prototype, name.c_str(), functionObject);
  for (auto v : funDataArray) {
    JS_FreeValue(ctx, v);
  }
}

template <typename View, void (View::*Method)(std::function<void(void)>)>
void bindMethod(std::string name, JSContext * ctx, Bindings *bindings, JSValue prototype) {
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
    (view->*Method)([ctx, callback, this_val] () {
      JS_Call(ctx, callback, this_val, 0, {});
    });
    return JS_UNDEFINED;
  };

  auto functionObject = JS_NewCFunctionData(ctx, call, 0, 0, funDataArray.size(), funDataArray.data());
  JS_SetPropertyStr(ctx, prototype, name.c_str(), functionObject);
  for (auto v : funDataArray) {
    JS_FreeValue(ctx, v);
  }
}

template <typename View, void (View::*Method)(rehax::ui::Color)>
void bindMethod(std::string name, JSContext * ctx, Bindings *bindings, JSValue prototype) {
  auto funData = JS_NewObjectClass(ctx, kPointerClassId);
  JS_SetOpaque(funData, bindings);
  std::array<JSValue, 1> funDataArray {
    funData
  };
  auto call = [] (JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic, JSValue* func_data) {
    auto bindings = (Bindings *) JS_GetOpaque(func_data[0], kPointerClassId);
    auto privateData = static_cast<ViewPrivateData<View> *>(JS_GetOpaque(this_val, bindings->instanceClassId));
    View * view = privateData->view;
    JSValue jr = JS_GetPropertyUint32(ctx, argv[0], 0);
    JSValue jg = JS_GetPropertyUint32(ctx, argv[0], 1);
    JSValue jb = JS_GetPropertyUint32(ctx, argv[0], 2);
    JSValue ja = JS_GetPropertyUint32(ctx, argv[0], 3);
    double r, g, b, a;
    JS_ToFloat64(ctx, &r, jr);
    JS_ToFloat64(ctx, &g, jg);
    JS_ToFloat64(ctx, &b, jb);
    JS_ToFloat64(ctx, &a, ja);
      
    (view->*Method)(rehax::ui::Color::RGBA(r/255.0, g/255.0, b/255.0, a));
    return JS_UNDEFINED;
  };

  auto functionObject = JS_NewCFunctionData(ctx, call, 0, 0, funDataArray.size(), funDataArray.data());
  JS_SetPropertyStr(ctx, prototype, name.c_str(), functionObject);
  for (auto v : funDataArray) {
    JS_FreeValue(ctx, v);
  }
}

template <typename View>
void bindViewClassMethods(JSContext * ctx, Bindings *bindings, JSValue prototype) {
  bindMethod<View, &View::description>("toString", ctx, bindings, prototype);
  bindMethod<View, &View::removeFromParent>("removeFromParent", ctx, bindings, prototype);
  bindMethod<View, &View::setWidthFixed>("setWidthFixed", ctx, bindings, prototype);
  bindMethod<View, &View::setHeightFixed>("setHeightFixed", ctx, bindings, prototype);
    
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
  bindMethod<View, &View::setTitle>("setTitle", ctx, bindings, prototype);
  bindMethod<View, &View::getTitle>("getTitle", ctx, bindings, prototype);
  bindMethod<View, &View::setOnPress>("setOnPress", ctx, bindings, prototype);
}

template <typename View>
void bindTextClassMethods(JSContext * ctx, Bindings *bindings, JSValue prototype) {
  bindMethod<View, &View::setText>("setText", ctx, bindings, prototype);
  bindMethod<View, &View::getText>("getText", ctx, bindings, prototype);
  bindMethod<View, &View::setTextColor>("setTextColor", ctx, bindings, prototype);
  bindMethod<View, &View::setFontSize>("setFontSize", ctx, bindings, prototype);
}


template <typename View>
void bindTextInputClassMethods(JSContext * ctx, Bindings *bindings, JSValue prototype) {
  bindMethod<View, &View::setValue>("setValue", ctx, bindings, prototype);
  bindMethod<View, &View::getValue>("getValue", ctx, bindings, prototype);
}

template <typename View>
void bindVectorElementClassMethods(JSContext * ctx, Bindings *bindings, JSValue prototype) {
  // RHX_EXPORT void setLineCap(int capsStyle);
  // RHX_EXPORT void setLineJoin(int joinStyle);
  // RHX_EXPORT void setFillGradient(Gradient gradient);
  // RHX_EXPORT void setStrokeGradient(Gradient gradient);
  // RHX_EXPORT void setFilters(Filters filters);

  bindMethod<View, &View::setLineWidth>("setLineWidth", ctx, bindings, prototype);
  bindMethod<View, &View::setFillColor>("setFillColor", ctx, bindings, prototype);
  bindMethod<View, &View::setStrokeColor>("setStrokeColor", ctx, bindings, prototype);
}

template <typename View>
void bindVectorPathClassMethods(JSContext * ctx, Bindings *bindings, JSValue prototype) {

  // RHX_EXPORT void pathArc(float rx, float ry, float xAxisRotation, int largeArcFlag, int sweepFlag, float x, float y);
  // RHX_EXPORT void pathCubicBezier(float x1, float y1, float x2, float y2, float x, float y);
  // RHX_EXPORT void pathQuadraticBezier(float x1, float y1, float x, float y);
    
  bindMethod<View, &View::beginPath>("beginPath", ctx, bindings, prototype);
  bindMethod<View, &View::pathHorizontalTo>("pathHorizontalTo", ctx, bindings, prototype);
  bindMethod<View, &View::pathVerticalTo>("pathVerticalTo", ctx, bindings, prototype);
  bindMethod<View, &View::pathMoveTo>("pathMoveTo", ctx, bindings, prototype);
  bindMethod<View, &View::pathMoveBy>("pathMoveBy", ctx, bindings, prototype);
  bindMethod<View, &View::pathLineTo>("pathLineTo", ctx, bindings, prototype);
  bindMethod<View, &View::pathClose>("pathClose", ctx, bindings, prototype);
  bindMethod<View, &View::endPath>("endPath", ctx, bindings, prototype);
}


#ifdef REHAX_WITH_APPKIT
void Bindings::bindAppkitToQuickJs() {
  defineViewClass<rehax::ui::appkit::impl::View<rehax::ui::RefCountedPointer>>(ctx, "View", JS_NULL);
  defineViewClass<rehax::ui::appkit::impl::Button<rehax::ui::RefCountedPointer>>(ctx, "Button", classRegistry["View"].prototype);
  defineViewClass<rehax::ui::appkit::impl::Text<rehax::ui::RefCountedPointer>>(ctx, "Text", classRegistry["View"].prototype);
  defineViewClass<rehax::ui::appkit::impl::TextInput<rehax::ui::RefCountedPointer>>(ctx, "TextInput", classRegistry["View"].prototype);
  defineViewClass<rehax::ui::appkit::impl::VectorContainer<rehax::ui::RefCountedPointer>>(ctx, "VectorContainer", classRegistry["View"].prototype);
  defineViewClass<rehax::ui::appkit::impl::VectorElement<rehax::ui::RefCountedPointer>>(ctx, "VectorElement", classRegistry["View"].prototype);
  defineViewClass<rehax::ui::appkit::impl::VectorPath<rehax::ui::RefCountedPointer>>(ctx, "VectorPath", classRegistry["VectorElement"].prototype);
    
  bindViewClassMethods<rehax::ui::appkit::impl::View<rehax::ui::RefCountedPointer>>(ctx, this, classRegistry["View"].prototype);
  bindButtonClassMethods<rehax::ui::appkit::impl::Button<rehax::ui::RefCountedPointer>>(ctx, this, classRegistry["Button"].prototype);
  bindTextClassMethods<rehax::ui::appkit::impl::Text<rehax::ui::RefCountedPointer>>(ctx, this, classRegistry["Text"].prototype);
  bindTextInputClassMethods<rehax::ui::appkit::impl::TextInput<rehax::ui::RefCountedPointer>>(ctx, this, classRegistry["TextInput"].prototype);
  bindVectorElementClassMethods<rehax::ui::appkit::impl::VectorElement<rehax::ui::RefCountedPointer>>(ctx, this, classRegistry["VectorElement"].prototype);
  bindVectorPathClassMethods<rehax::ui::appkit::impl::VectorPath<rehax::ui::RefCountedPointer>>(ctx, this, classRegistry["VectorPath"].prototype);
}
#endif

#ifdef REHAX_WITH_FLUXE
void Bindings::bindFluxeToQuickJs() {
  defineViewClass<rehax::ui::fluxe::impl::View<rehax::ui::RefCountedPointer>>(ctx, "View", JS_NULL);
  defineViewClass<rehax::ui::fluxe::impl::Button<rehax::ui::RefCountedPointer>>(ctx, "Button", classRegistry["View"].prototype);
  defineViewClass<rehax::ui::fluxe::impl::Text<rehax::ui::RefCountedPointer>>(ctx, "Text", classRegistry["View"].prototype);
  defineViewClass<rehax::ui::fluxe::impl::TextInput<rehax::ui::RefCountedPointer>>(ctx, "TextInput", classRegistry["View"].prototype);
    
  bindViewClassMethods<rehax::ui::fluxe::impl::View<rehax::ui::RefCountedPointer>>(ctx, this, classRegistry["View"].prototype);
  bindButtonClassMethods<rehax::ui::fluxe::impl::Button<rehax::ui::RefCountedPointer>>(ctx, this, classRegistry["Button"].prototype);
  bindTextClassMethods<rehax::ui::fluxe::impl::Text<rehax::ui::RefCountedPointer>>(ctx, this, classRegistry["Text"].prototype);
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
#include "../../native-abstraction/ui/appkit/components/vector/VectorContainer.mm"
#include "../../native-abstraction/ui/appkit/components/vector/VectorElement.mm"
#include "../../native-abstraction/ui/appkit/components/vector/VectorPath.mm"
#endif

#ifdef REHAX_WITH_FLUXE
#include "../../native-abstraction/ui/fluxe/components/view/View.cc"
#include "../../native-abstraction/ui/fluxe/components/button/Button.cc"
#include "../../native-abstraction/ui/fluxe/components/text/Text.cc"
#include "../../native-abstraction/ui/fluxe/components/textInput/TextInput.cc"
#endif
