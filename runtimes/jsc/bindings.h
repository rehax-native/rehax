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
  void bindAppkitRehax();
  #endif
  #ifdef REHAX_WITH_FLUXE
  void bindFluxeRehax();
  #endif
  
  template <typename Object> JSValueRef cppToJs(rehaxUtils::ObjectPointer<Object> obj);

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
  void bindRehax();

private:
  JSContextRef ctx;

  std::unordered_map<std::string, RegisteredClass> classRegistry;
  
  template <typename View, bool instantiable = true>
  void defineViewClass(JSContextRef ctx, std::string name, JSObjectRef parentPrototype);

};

}
}

#include "./converters.h"

template <typename Object>
JSValueRef rehax::jsc::Bindings::cppToJs(rehaxUtils::ObjectPointer<Object> obj) {
  auto js = Converter<Object>::toScript(ctx, obj.get(), this);
  return js;
}
