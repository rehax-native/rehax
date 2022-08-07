#pragma once

#include <JavaScriptCore/JavaScriptCore.h>
#include "../../native-abstraction/rehax.h"
#include <unordered_map>
#include <vector>

namespace rehax {
namespace jsc {

struct RegisteredClass {
  std::string name;
  JSClassRef classDefine;
  JSObjectRef prototype;
};

class Bindings;

template<typename View>
struct ViewPrivateData {
  Bindings * bindings;
  std::vector<JSValueRef> retainedValues;
  JSContextRef ctx;
  View * view;
};

class Bindings
{
public:
    
  Bindings();
  void setContext(JSContextRef ctx);
  #ifdef REHAX_WITH_APPKIT
  void bindAppkitToJsc();
  #endif
  #ifdef REHAX_WITH_FLUXE
  void bindFluxeToJsc();
  #endif
  
  template <typename View>
  JSObjectRef cppToJs(View * obj)
  {
    auto className = obj->instanceClassName();
    auto privateData = new ViewPrivateData<View>();
    privateData->view = obj;
    privateData->bindings = this;
    privateData->ctx = ctx;
    obj->increaseReferenceCount(); // decreased in finalizer
    JSObjectRef object = JSObjectMake(ctx, classRegistry[className].classDefine, privateData);
    JSObjectSetPrototype(ctx, object, classRegistry[className].prototype);
    JSStringRef __className = JSStringCreateWithUTF8CString(className.c_str());
    JSObjectSetProperty(ctx, object, JSStringCreateWithUTF8CString("__className"), (JSValueRef) JSValueMakeString(ctx, __className), kJSPropertyAttributeReadOnly, NULL);
    return object;
  }

  RegisteredClass getRegisteredClass(std::string name);

  template <
    typename StackLayout,
    typename FlexLayout,
    typename View,
    typename Button,
    typename Text,
    typename TextInput,
    typename VectorContainer,
    typename VectorElement,
    typename VectorPath,
    typename ILayout,
    typename Gesture
  >
  void bindToJsc();

private:
  JSContextRef ctx;

  std::unordered_map<std::string, RegisteredClass> classRegistry;
  
  template <typename View, bool instantiable = true>
  void defineViewClass(JSContextRef ctx, std::string name, JSObjectRef parentPrototype);

};

}
}
