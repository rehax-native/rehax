#include "./bindings.h"

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

ui::Color JSColorArrayToUIColor(JSContextRef ctx, JSObjectRef colorArrayValue) {
  auto r = JSValueToNumber(ctx, JSObjectGetPropertyAtIndex(ctx, colorArrayValue, 0, NULL), NULL);
  auto g = JSValueToNumber(ctx, JSObjectGetPropertyAtIndex(ctx, colorArrayValue, 1, NULL), NULL);
  auto b = JSValueToNumber(ctx, JSObjectGetPropertyAtIndex(ctx, colorArrayValue, 2, NULL), NULL);
  auto a = JSValueToNumber(ctx, JSObjectGetPropertyAtIndex(ctx, colorArrayValue, 3, NULL), NULL);
  return ui::Color::RGBA(r/255.0, g/255.0, b/255.0, a);
}

Bindings::Bindings() {}

void Bindings::setContext(JSContextRef ctx) {
  this->ctx = ctx;
}

RegisteredClass Bindings::getRegisteredClass(std::string name) {
  return classRegistry[name];
}

template <typename View>
JSObjectRef cppToJs(JSContextRef ctx, Bindings * bindings, View * obj) {
  auto privateData = new ViewPrivateData<View>();
  privateData->view = obj;
  privateData->bindings = bindings;
  privateData->ctx = ctx;

  auto className = obj->viewName();
  obj->increaseReferenceCount(); // decreased in finalizer
    
  auto registeredClass = bindings->getRegisteredClass(className);

  JSObjectRef object = JSObjectMake(ctx, registeredClass.classDefine, privateData);
  JSObjectSetPrototype(ctx, object, registeredClass.prototype);
  auto __className = JSStringCreateWithUTF8CString(className.c_str());
  JSObjectSetProperty(ctx, object, JSStringCreateWithUTF8CString("__className"), (JSValueRef) JSValueMakeString(ctx, __className), kJSPropertyAttributeReadOnly, NULL);
  return object;
}

template <typename View>
void Bindings::defineViewClass(JSContextRef ctx, std::string name, JSObjectRef parentPrototype) {
  
  JSClassDefinition instanceDefine = kJSClassDefinitionEmpty;
  instanceDefine.attributes = kJSClassAttributeNone;
  instanceDefine.className = name.c_str();
  instanceDefine.finalize = [] (JSObjectRef thiz) {
    auto privateData = static_cast<ViewPrivateData<View> *>(JSObjectGetPrivate(thiz));
    auto ctx = privateData->ctx;

    for (auto value : privateData->retainedValues) {
      JSValueUnprotect(ctx, value);
    }

    privateData->view->decreaseReferenceCount();
    delete privateData;
  };
  
  JSObjectRef prototypeObject = JSObjectMake(ctx, nullptr, nullptr);
  if (parentPrototype != nullptr) {
    JSObjectSetPrototype(ctx, prototypeObject, parentPrototype);
  }
  
  instanceDefine.callAsConstructor = [] (JSContextRef ctx, JSObjectRef constructor, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception) {
    auto bindings = static_cast<Bindings *>(JSObjectGetPrivate(constructor));
    auto view = View::Create();
    return ::rehax::jsc::cppToJs(ctx, bindings, view.get());
  };
  
  auto clazz = JSClassCreate(&instanceDefine);
  classRegistry[name] = {
    .name = name,
    .classDefine = clazz,
    .prototype = prototypeObject,
  };
  auto jsClassObject = JSObjectMake(ctx, clazz, this);
  auto className = JSStringCreateWithUTF8CString(name.c_str());

  auto globalContext = JSContextGetGlobalObject(ctx);
  JSObjectSetProperty(ctx, globalContext, className, jsClassObject, kJSPropertyAttributeReadOnly, NULL);
  
  return clazz;
}

template <typename View, void (View::*Method)(void)>
void bindMethod(std::string name, JSContextRef ctx, JSObjectRef prototype) {
  JSStringRef methodName = JSStringCreateWithUTF8CString(name.c_str());
  auto functionObject = JSObjectMakeFunctionWithCallback(ctx, methodName, [] (JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception) {
    auto privateData = static_cast<ViewPrivateData<View> *>(JSObjectGetPrivate(thisObject));
    auto view = privateData->view;
    (view->*Method)();
    return JSValueMakeUndefined(ctx);
  });
  JSObjectSetProperty(ctx, prototype, methodName, functionObject, kJSPropertyAttributeReadOnly, NULL);
}

template <typename View, std::string (View::*Method)(void)>
void bindMethod(std::string name, JSContextRef ctx, JSObjectRef prototype) {
  JSStringRef methodName = JSStringCreateWithUTF8CString(name.c_str());
  auto functionObject = JSObjectMakeFunctionWithCallback(ctx, methodName, [] (JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception) {
    auto privateData = static_cast<ViewPrivateData<View> *>(JSObjectGetPrivate(thisObject));
    auto view = privateData->view;
    auto ret = (view->*Method)();
    JSStringRef jsText = JSStringCreateWithUTF8CString(ret.c_str());
    return JSValueMakeString(ctx, jsText);
  });
  JSObjectSetProperty(ctx, prototype, methodName, functionObject, kJSPropertyAttributeReadOnly, NULL);
}

template <typename View, void (View::*Method)(std::string)>
void bindMethod(std::string name, JSContextRef ctx, JSObjectRef prototype) {
  JSStringRef methodName = JSStringCreateWithUTF8CString(name.c_str());
  auto functionObject = JSObjectMakeFunctionWithCallback(ctx, methodName, [] (JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception) {
    auto privateData = static_cast<ViewPrivateData<View> *>(JSObjectGetPrivate(thisObject));
    auto view = privateData->view;
    (view->*Method)(Bindings::JSStringToStdString(ctx, (JSStringRef) arguments[0]));
    return JSValueMakeUndefined(ctx);
  });
  JSObjectSetProperty(ctx, prototype, methodName, functionObject, kJSPropertyAttributeReadOnly, NULL);
}

template <typename View, void (View::*Method)(double)>
void bindMethod(std::string name, JSContextRef ctx, JSObjectRef prototype) {
  JSStringRef methodName = JSStringCreateWithUTF8CString(name.c_str());
  auto functionObject = JSObjectMakeFunctionWithCallback(ctx, methodName, [] (JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception) {
    auto privateData = static_cast<ViewPrivateData<View> *>(JSObjectGetPrivate(thisObject));
    auto view = privateData->view;
    (view->*Method)(JSValueToNumber(ctx, arguments[0], NULL));
    return JSValueMakeUndefined(ctx);
  });
  JSObjectSetProperty(ctx, prototype, methodName, functionObject, kJSPropertyAttributeReadOnly, NULL);
}

template <typename View, void (View::*Method)(float)>
void bindMethod(std::string name, JSContextRef ctx, JSObjectRef prototype) {
  JSStringRef methodName = JSStringCreateWithUTF8CString(name.c_str());
  auto functionObject = JSObjectMakeFunctionWithCallback(ctx, methodName, [] (JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception) {
    auto privateData = static_cast<ViewPrivateData<View> *>(JSObjectGetPrivate(thisObject));
    auto view = privateData->view;
    (view->*Method)(JSValueToNumber(ctx, arguments[0], NULL));
    return JSValueMakeUndefined(ctx);
  });
  JSObjectSetProperty(ctx, prototype, methodName, functionObject, kJSPropertyAttributeReadOnly, NULL);
}

template <typename View, void (View::*Method)(float, float)>
void bindMethod(std::string name, JSContextRef ctx, JSObjectRef prototype) {
  JSStringRef methodName = JSStringCreateWithUTF8CString(name.c_str());
  auto functionObject = JSObjectMakeFunctionWithCallback(ctx, methodName, [] (JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception) {
    auto privateData = static_cast<ViewPrivateData<View> *>(JSObjectGetPrivate(thisObject));
    auto view = privateData->view;
    (view->*Method)(JSValueToNumber(ctx, arguments[0], nullptr), JSValueToNumber(ctx, arguments[1], nullptr));
    return JSValueMakeUndefined(ctx);
  });
  JSObjectSetProperty(ctx, prototype, methodName, functionObject, kJSPropertyAttributeReadOnly, NULL);
}

template <typename View, void (View::*Method)(std::function<void()>)>
void bindMethod(std::string name, JSContextRef ctx, JSObjectRef prototype) {
  JSStringRef methodName = JSStringCreateWithUTF8CString(name.c_str());
  auto functionObject = JSObjectMakeFunctionWithCallback(ctx, methodName, [] (JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception) {
    auto privateData = static_cast<ViewPrivateData<View> *>(JSObjectGetPrivate(thisObject));
    auto view = privateData->view;
    JSObjectRef callback = (JSObjectRef) arguments[0];
    JSValueProtect(ctx, callback);
    privateData->retainedValues.push_back(callback);
    (view->*Method)([ctx, callback] () {
//                auto exception = JSObjectMake(ctx, nullptr, nullptr);
      JSValueRef exception = nullptr;
      JSObjectCallAsFunction(ctx, callback, NULL, 0, NULL, &exception);
      // if (exception != nullptr) {
      //     auto exMessage = JSObjectGetProperty(ctx, (JSObjectRef) exception, JSStringCreateWithUTF8CString("message"), nullptr);
      //     auto message = Bindings::JSStringToStdString(ctx, (JSStringRef) exMessage);
      //     std::cout << message << std::endl;
      // }
    });
    return JSValueMakeUndefined(ctx);
  });
  JSObjectSetProperty(ctx, prototype, methodName, functionObject, kJSPropertyAttributeReadOnly, NULL);
}

template <typename View, void (View::*Method)(rehax::ui::Color)>
void bindMethod(std::string name, JSContextRef ctx, JSObjectRef prototype) {
  JSStringRef methodName = JSStringCreateWithUTF8CString(name.c_str());
  auto functionObject = JSObjectMakeFunctionWithCallback(ctx, methodName, [] (JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception) {
    auto privateData = static_cast<ViewPrivateData<View> *>(JSObjectGetPrivate(thisObject));
    auto view = privateData->view;
    (view->*Method)(JSColorArrayToUIColor(ctx, (JSObjectRef) arguments[0]));
    return JSValueMakeUndefined(ctx);
  });
  JSObjectSetProperty(ctx, prototype, methodName, functionObject, kJSPropertyAttributeReadOnly, NULL);
}

template <typename View>
void bindViewClassMethods(JSContextRef ctx, JSObjectRef prototype) {
  bindMethod<View, &View::description>("toString", ctx, prototype);
  bindMethod<View, &View::removeFromParent>("removeFromParent", ctx, prototype);
  bindMethod<View, &View::setWidthFixed>("setWidthFixed", ctx, prototype);
  bindMethod<View, &View::setHeightFixed>("setHeightFixed", ctx, prototype);
    
  {
    JSStringRef methodName = JSStringCreateWithUTF8CString("addView");
    auto functionObject = JSObjectMakeFunctionWithCallback(ctx, methodName, [] (JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception) {
      auto privateData = static_cast<ViewPrivateData<View> *>(JSObjectGetPrivate(thisObject));
      auto view = privateData->view;

      auto childPrivateData = static_cast<ViewPrivateData<View> *>(JSObjectGetPrivate((JSObjectRef) arguments[0]));
      auto childView = childPrivateData->view;

      if (argumentCount <= 1 || JSValueIsNull(ctx, arguments[1]) || JSValueIsUndefined(ctx, arguments[1])) {
        view->addView(childView);
      } else {
        auto beforeView = static_cast<ViewPrivateData<View> *>(JSObjectGetPrivate((JSObjectRef) arguments[1]));
        view->addView(childView, beforeView->view);
      }
      return JSValueMakeUndefined(ctx);
    });
    JSObjectSetProperty(ctx, prototype, methodName, functionObject, kJSPropertyAttributeReadOnly, NULL);
  }
  {
    JSStringRef methodName = JSStringCreateWithUTF8CString("removeView");
    auto functionObject = JSObjectMakeFunctionWithCallback(ctx, methodName, [] (JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception) {
      auto privateData = static_cast<ViewPrivateData<View> *>(JSObjectGetPrivate(thisObject));
      auto view = privateData->view;

      auto childPrivateData = static_cast<ViewPrivateData<View> *>(JSObjectGetPrivate((JSObjectRef) arguments[0]));
      auto childView = childPrivateData->view;

      view->removeView(childView);
      return JSValueMakeUndefined(ctx);
    });
    JSObjectSetProperty(ctx, prototype, methodName, functionObject, kJSPropertyAttributeReadOnly, NULL);
  }
  {
    JSStringRef methodName = JSStringCreateWithUTF8CString("getParent");
    auto functionObject = JSObjectMakeFunctionWithCallback(ctx, methodName, [] (JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception) {
      auto privateData = static_cast<ViewPrivateData<View> *>(JSObjectGetPrivate(thisObject));
      auto view = privateData->view;

      auto parent = view->getParent();
        
      if (!parent.isValid()) {
        return JSValueMakeNull(ctx);
      }
                
      View * parentView = dynamic_cast<View *>(parent.get());
      auto jsParent = ::rehax::jsc::cppToJs(ctx, privateData->bindings, parentView);
      return (JSValueRef) jsParent;
    });
    JSObjectSetProperty(ctx, prototype, methodName, functionObject, kJSPropertyAttributeReadOnly, NULL);
  }
  {
    JSStringRef methodName = JSStringCreateWithUTF8CString("getFirstChild");
    auto functionObject = JSObjectMakeFunctionWithCallback(ctx, methodName, [] (JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception) {
      auto privateData = static_cast<ViewPrivateData<View> *>(JSObjectGetPrivate(thisObject));
      auto view = privateData->view;

      auto children = view->children;
      auto firstChild = * children.begin();
      View * firstChildView = dynamic_cast<View *>(firstChild);

      return (JSValueRef) ::rehax::jsc::cppToJs(ctx, privateData->bindings, firstChildView);
    });
    JSObjectSetProperty(ctx, prototype, methodName, functionObject, kJSPropertyAttributeReadOnly, NULL);
  }
  {
    JSStringRef methodName = JSStringCreateWithUTF8CString("getNextSibling");
    auto functionObject = JSObjectMakeFunctionWithCallback(ctx, methodName, [] (JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception) {
      auto privateData = static_cast<ViewPrivateData<View> *>(JSObjectGetPrivate(thisObject));
      auto view = privateData->view;

      // TODO this should probably be moved to the core
      auto parent = view->getParent();
      if (!parent.isValid()) {
        return JSValueMakeNull(ctx);
      }
      auto it = parent->children.find(view);
      it++;
      if (it == parent->children.end()) {
        return JSValueMakeNull(ctx);
      }
      auto nextSibling = * it;
      View * siblingView = dynamic_cast<View *>(nextSibling);
      return (JSValueRef) ::rehax::jsc::cppToJs(ctx, privateData->bindings, siblingView);
    });
    JSObjectSetProperty(ctx, prototype, methodName, functionObject, kJSPropertyAttributeReadOnly, NULL);
  }
}

template <typename View>
void bindButtonClassMethods(JSContextRef ctx, JSObjectRef prototype) {
  bindMethod<View, &View::setTitle>("setTitle", ctx, prototype);
  bindMethod<View, &View::getTitle>("getTitle", ctx, prototype);
  bindMethod<View, &View::setOnPress>("setOnPress", ctx, prototype);
}

template <typename View>
void bindTextClassMethods(JSContextRef ctx, JSObjectRef prototype) {
  bindMethod<View, &View::setText>("setText", ctx, prototype);
  bindMethod<View, &View::getText>("getText", ctx, prototype);
  bindMethod<View, &View::setTextColor>("setTextColor", ctx, prototype);
  bindMethod<View, &View::setFontSize>("setFontSize", ctx, prototype);
}

template <typename View>
void bindTextInputClassMethods(JSContextRef ctx, JSObjectRef prototype) {
  bindMethod<View, &View::setValue>("setValue", ctx, prototype);
  bindMethod<View, &View::getValue>("getValue", ctx, prototype);
}

template <typename View>
void bindVectorElementClassMethods(JSContextRef ctx, JSObjectRef prototype) {
  // RHX_EXPORT void setLineCap(int capsStyle);
  // RHX_EXPORT void setLineJoin(int joinStyle);
  // RHX_EXPORT void setFillGradient(Gradient gradient);
  // RHX_EXPORT void setStrokeGradient(Gradient gradient);
  // RHX_EXPORT void setFilters(Filters filters);

  bindMethod<View, &View::setLineWidth>("setLineWidth", ctx, prototype);
  bindMethod<View, &View::setFillColor>("setFillColor", ctx, prototype);
  bindMethod<View, &View::setStrokeColor>("setStrokeColor", ctx, prototype);
}

template <typename View>
void bindVectorPathClassMethods(JSContextRef ctx, JSObjectRef prototype) {

  // RHX_EXPORT void pathArc(float rx, float ry, float xAxisRotation, int largeArcFlag, int sweepFlag, float x, float y);
  // RHX_EXPORT void pathCubicBezier(float x1, float y1, float x2, float y2, float x, float y);
  // RHX_EXPORT void pathQuadraticBezier(float x1, float y1, float x, float y);
    
  bindMethod<View, &View::beginPath>("beginPath", ctx, prototype);
  bindMethod<View, &View::pathHorizontalTo>("pathHorizontalTo", ctx, prototype);
  bindMethod<View, &View::pathVerticalTo>("pathVerticalTo", ctx, prototype);
  bindMethod<View, &View::pathMoveTo>("pathMoveTo", ctx, prototype);
  bindMethod<View, &View::pathMoveBy>("pathMoveBy", ctx, prototype);
  bindMethod<View, &View::pathLineTo>("pathLineTo", ctx, prototype);
  bindMethod<View, &View::pathClose>("pathClose", ctx, prototype);
  bindMethod<View, &View::endPath>("endPath", ctx, prototype);
}



#ifdef REHAX_WITH_APPKIT
void Bindings::bindAppkitToJsc() {
  defineViewClass<rehax::ui::appkit::impl::View<rehax::ui::RefCountedPointer>>(ctx, "View", nullptr);
  defineViewClass<rehax::ui::appkit::impl::Button<rehax::ui::RefCountedPointer>>(ctx, "Button", classRegistry["View"].prototype);
  defineViewClass<rehax::ui::appkit::impl::Text<rehax::ui::RefCountedPointer>>(ctx, "Text", classRegistry["View"].prototype);
  defineViewClass<rehax::ui::appkit::impl::TextInput<rehax::ui::RefCountedPointer>>(ctx, "TextInput", classRegistry["View"].prototype);
  defineViewClass<rehax::ui::appkit::impl::VectorContainer<rehax::ui::RefCountedPointer>>(ctx, "VectorContainer", classRegistry["View"].prototype);
  defineViewClass<rehax::ui::appkit::impl::VectorElement<rehax::ui::RefCountedPointer>>(ctx, "VectorElement", classRegistry["View"].prototype);
  defineViewClass<rehax::ui::appkit::impl::VectorPath<rehax::ui::RefCountedPointer>>(ctx, "VectorPath", classRegistry["VectorElement"].prototype);

  bindViewClassMethods<rehax::ui::appkit::impl::View<rehax::ui::RefCountedPointer>>(ctx, classRegistry["View"].prototype);
  bindButtonClassMethods<rehax::ui::appkit::impl::Button<rehax::ui::RefCountedPointer>>(ctx, classRegistry["Button"].prototype);
  bindTextClassMethods<rehax::ui::appkit::impl::Text<rehax::ui::RefCountedPointer>>(ctx, classRegistry["Text"].prototype);
  bindTextInputClassMethods<rehax::ui::appkit::impl::TextInput<rehax::ui::RefCountedPointer>>(ctx, classRegistry["TextInput"].prototype);
  bindVectorElementClassMethods<rehax::ui::appkit::impl::VectorElement<rehax::ui::RefCountedPointer>>(ctx, classRegistry["VectorElement"].prototype);
  bindVectorPathClassMethods<rehax::ui::appkit::impl::VectorPath<rehax::ui::RefCountedPointer>>(ctx, classRegistry["VectorPath"].prototype);
}
#endif

#ifdef REHAX_WITH_FLUXE
void Bindings::bindFluxeToJsc() {
  defineViewClass<rehax::ui::fluxe::impl::View<rehax::ui::RefCountedPointer>>(ctx, "View", nullptr);
  defineViewClass<rehax::ui::fluxe::impl::Button<rehax::ui::RefCountedPointer>>(ctx, "Button", classRegistry["View"].prototype);
  defineViewClass<rehax::ui::fluxe::impl::Text<rehax::ui::RefCountedPointer>>(ctx, "Text", classRegistry["View"].prototype);
  defineViewClass<rehax::ui::fluxe::impl::TextInput<rehax::ui::RefCountedPointer>>(ctx, "TextInput", classRegistry["View"].prototype);

  bindViewClassMethods<rehax::ui::fluxe::impl::View<rehax::ui::RefCountedPointer>>(ctx, classRegistry["View"].prototype);
  bindButtonClassMethods<rehax::ui::fluxe::impl::Button<rehax::ui::RefCountedPointer>>(ctx, classRegistry["Button"].prototype);
  bindTextClassMethods<rehax::ui::fluxe::impl::Text<rehax::ui::RefCountedPointer>>(ctx, classRegistry["Text"].prototype);
  bindTextInputClassMethods<rehax::ui::fluxe::impl::TextInput<rehax::ui::RefCountedPointer>>(ctx, classRegistry["TextInput"].prototype);
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
