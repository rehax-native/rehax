#pragma once

#include <JavaScriptCore/JavaScriptCore.h>
#include "../../native-abstraction/rehax.h"
#include <unordered_map>
#include <vector>
#include "./runtimeUtils.h"

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

  template <typename View, bool instantiable = true>
  void defineViewClass(JSContextRef ctx, std::string name, runtime::Value parentPrototype);

  template <typename View, typename Layout, typename Gesture> void bindViewClassMethods(runtime::Context ctx, runtime::Value prototype);
  template <typename View> void bindButtonClassMethods(runtime::Context ctx, runtime::Value prototype);
  template <typename View> void bindTextClassMethods(runtime::Context ctx, runtime::Value prototype);
  template <typename View> void bindTextInputClassMethods(runtime::Context ctx, runtime::Value prototype);
  template <typename View> void bindVectorElementClassMethods(runtime::Context ctx, runtime::Value prototype);
  template <typename View> void bindVectorPathClassMethods(runtime::Context ctx, runtime::Value prototype);
  template <typename Layout, typename View> void bindStackLayoutClassMethods(runtime::Context ctx, runtime::Value prototype);
  template <typename Layout, typename View> void bindFlexLayoutClassMethods(runtime::Context ctx, runtime::Value prototype);
  template <typename Gesture> void bindGestureClassMethods(runtime::Context ctx, runtime::Value prototype);

  template <typename View, typename RET, RET (View::*Method)(void)> void bindMethod(std::string name, runtime::Context ctx, runtime::Value prototype);
  template <typename View, void (View::*Method)(void)> void bindMethod(std::string name, runtime::Context ctx, runtime::Value prototype);
  template <typename View, typename T1, void (View::*Method)(T1)>
  void bindMethod(std::string name, runtime::Context ctx, runtime::Value prototype);
  template <typename View, typename T1, typename D1, void (View::*Method)(T1), void (View::*MethodDefault)(D1)>
  void bindMethod(std::string name, runtime::Context ctx, runtime::Value prototype);
  template <typename View, typename T1, typename T2, void (View::*Method)(T1, T2)>
  void bindMethod(std::string name, runtime::Context ctx, runtime::Value prototype);
  template <typename View, typename T1, typename T2, typename T3, void (View::*Method)(T1, T2)>
  void bindMethod(std::string name, runtime::Context ctx, runtime::Value prototype);
  template <typename View, typename T1, typename T2, typename T3, typename T4, void (View::*Method)(T1, T2, T3, T4)>
  void bindMethod(std::string name, runtime::Context ctx, runtime::Value prototype);
  template <typename View, typename T1, typename T2, typename T3, typename T4, typename T5, void (View::*Method)(T1, T2, T3, T4, T5)>
  void bindMethod(std::string name, runtime::Context ctx, runtime::Value prototype);
  template <typename View, typename T1, typename T2, typename T3, typename T4, typename T5, typename T6, void (View::*Method)(T1, T2, T3, T4, T5, T6)>
  void bindMethod(std::string name, runtime::Context ctx, runtime::Value prototype);
  template <typename View, typename T1, typename T2, typename T3, typename T4, typename T5, typename T6, typename T7, void (View::*Method)(T1, T2, T3, T4, T5, T6, T7)>
  void bindMethod(std::string name, runtime::Context ctx, runtime::Value prototype);

  RegisteredClass getRegisteredClass(std::string name);
  template <typename T> JSValueRef cppToJs(T obj);

private:
  JSContextRef ctx;
  std::unordered_map<std::string, RegisteredClass> classRegistry;
};


#include "./converters.h"

template <typename T>
JSValueRef Bindings::cppToJs(T obj) {
  auto js = Converter<T>::toScript(ctx, obj, this);
  return js;
}

#include "bindings.hpp"

}
}
