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

template <typename View>
void bindViewClassMethods(JSContextRef ctx, JSObjectRef prototype) {
  {
    JSStringRef methodName = JSStringCreateWithUTF8CString("toString");
    auto functionObject = JSObjectMakeFunctionWithCallback(ctx, methodName, [] (JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception) {
      auto privateData = static_cast<ViewPrivateData<View> *>(JSObjectGetPrivate(thisObject));
      auto view = privateData->view;
      auto description = view->description();
      JSStringRef jsText = JSStringCreateWithUTF8CString(description.c_str());
      return JSValueMakeString(ctx, jsText);
    });
    JSObjectSetProperty(ctx, prototype, methodName, functionObject, kJSPropertyAttributeReadOnly, NULL);
  }
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
      auto privateData = static_cast<ViewPrivateData<View> *>(JSObjectGetPrivate(thisObject));
      auto view = privateData->view;
      view->removeFromParent();
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
void bindTextClassMethods(JSContextRef ctx, JSObjectRef prototype) {
  {
    JSStringRef methodName = JSStringCreateWithUTF8CString("setText");
    auto functionObject = JSObjectMakeFunctionWithCallback(ctx, methodName, [] (JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception) {
      auto privateData = static_cast<ViewPrivateData<View> *>(JSObjectGetPrivate(thisObject));
      auto view = privateData->view;
      view->setText(Bindings::JSStringToStdString(ctx, (JSStringRef) arguments[0]));
      return JSValueMakeUndefined(ctx);
    });
    JSObjectSetProperty(ctx, prototype, methodName, functionObject, kJSPropertyAttributeReadOnly, NULL);
  }
  {
    JSStringRef methodName = JSStringCreateWithUTF8CString("getText");
    auto functionObject = JSObjectMakeFunctionWithCallback(ctx, methodName, [] (JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception) {
      auto privateData = static_cast<ViewPrivateData<View> *>(JSObjectGetPrivate(thisObject));
      auto view = privateData->view;
      auto text = view->getText();
      JSStringRef jsText = JSStringCreateWithUTF8CString(text.c_str());
      return JSValueMakeString(ctx, jsText);
    });
    JSObjectSetProperty(ctx, prototype, methodName, functionObject, kJSPropertyAttributeReadOnly, NULL);
  }
}

template <typename View>
void bindButtonClassMethods(JSContextRef ctx, JSObjectRef prototype) {
  {
    JSStringRef methodName = JSStringCreateWithUTF8CString("setTitle");
    auto functionObject = JSObjectMakeFunctionWithCallback(ctx, methodName, [] (JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception) {
      auto privateData = static_cast<ViewPrivateData<View> *>(JSObjectGetPrivate(thisObject));
      auto view = privateData->view;
      view->setTitle(Bindings::JSStringToStdString(ctx, (JSStringRef) arguments[0]));
      return JSValueMakeUndefined(ctx);
    });
    JSObjectSetProperty(ctx, prototype, methodName, functionObject, kJSPropertyAttributeReadOnly, NULL);
  }
  {
    JSStringRef methodName = JSStringCreateWithUTF8CString("setOnPress");
    auto functionObject = JSObjectMakeFunctionWithCallback(ctx, methodName, [] (JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception) {
      auto privateData = static_cast<ViewPrivateData<View> *>(JSObjectGetPrivate(thisObject));
      auto view = privateData->view;
      JSObjectRef callback = (JSObjectRef) arguments[0];
      JSValueProtect(ctx, callback);
      privateData->retainedValues.push_back(callback);
      view->setOnPress([ctx, callback] () {
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
}




#ifdef REHAX_WITH_APPKIT
void Bindings::bindAppkitToJsc() {
  defineViewClass<rehax::ui::appkit::impl::View<rehax::ui::RefCountedPointer>>(ctx, "View", nullptr);
  bindViewClassMethods<rehax::ui::appkit::impl::View<rehax::ui::RefCountedPointer>>(ctx, classRegistry["View"].prototype);
  defineViewClass<rehax::ui::appkit::impl::Text<rehax::ui::RefCountedPointer>>(ctx, "Text", classRegistry["View"].prototype);
  bindTextClassMethods<rehax::ui::appkit::impl::Text<rehax::ui::RefCountedPointer>>(ctx, classRegistry["Text"].prototype);
  defineViewClass<rehax::ui::appkit::impl::Button<rehax::ui::RefCountedPointer>>(ctx, "Button", classRegistry["View"].prototype);
  bindButtonClassMethods<rehax::ui::appkit::impl::Button<rehax::ui::RefCountedPointer>>(ctx, classRegistry["Button"].prototype);
}
#endif

#ifdef REHAX_WITH_FLUXE
void Bindings::bindFluxeToJsc() {
  defineViewClass<rehax::ui::fluxe::impl::View<rehax::ui::RefCountedPointer>>(ctx, "View", nullptr);
  bindViewClassMethods<rehax::ui::fluxe::impl::View<rehax::ui::RefCountedPointer>>(ctx, classRegistry["View"].prototype);
  defineViewClass<rehax::ui::fluxe::impl::Text<rehax::ui::RefCountedPointer>>(ctx, "Text", classRegistry["View"].prototype);
  bindTextClassMethods<rehax::ui::fluxe::impl::Text<rehax::ui::RefCountedPointer>>(ctx, classRegistry["Text"].prototype);
  defineViewClass<rehax::ui::fluxe::impl::Button<rehax::ui::RefCountedPointer>>(ctx, "Button", classRegistry["View"].prototype);
  bindButtonClassMethods<rehax::ui::fluxe::impl::Button<rehax::ui::RefCountedPointer>>(ctx, classRegistry["Button"].prototype);
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
