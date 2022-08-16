#pragma once

#include "../../native-abstraction/rehax.h"
#include <unordered_map>
#include <quickjs-src/quickjs.h>
#include "./runtimeUtils.h"
#include <array>

namespace rehax {
namespace quickjs {

constexpr JSClassID kPointerClassId = 0;
constexpr JSClassID kClassClassId = 1;
constexpr JSClassID kPrototypeClassId = 2;


struct RegisteredClass {
  std::string name;
  JSValue prototype;
  JSClassID classId;
};

class Bindings;

template<typename View>
struct ViewPrivateData {
  Bindings * bindings;
  View * view;
  std::vector<JSValue> retainedValues;
  JSContext * context;
};

class Bindings {

public:
    
  Bindings();
  void setContext(JSContext * ctx, JSRuntime * runtime);
  JSContext * getContext();

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


  template <typename Object, bool instantiable = true>
  void defineClass(std::string name, RegisteredClass * parentClass);

  template <typename Object, typename RET, RET (Object::*Method)(void)> void bindMethod(std::string name, JSValue prototype);
  template <typename Object, void (Object::*Method)(void)> void bindMethod(std::string name, JSValue prototype);
  template <typename Object, typename T1, void (Object::*Method)(T1)>
  void bindMethod(std::string name, JSValue prototype);
  template <typename Object, typename R1, typename T1, R1 (Object::*Method)(T1)>
  void bindMethod(std::string name, JSValue prototype);
  template <typename Object, typename T1, typename D1, void (Object::*Method)(T1), void (Object::*MethodDefault)(D1)>
  void bindMethod(std::string name, JSValue prototype);
  template <typename Object, typename T1, typename T2, void (Object::*Method)(T1, T2)>
  void bindMethod(std::string name, JSValue prototype);
  template <typename Object, typename T1, typename T2, typename T3, void (Object::*Method)(T1, T2)>
  void bindMethod(std::string name, JSValue prototype);
  template <typename Object, typename T1, typename T2, typename T3, void (Object::*Method)(T1, T2, T3)>
  void bindMethod(std::string name, JSValue prototype);
  template <typename Object, typename T1, typename T2, typename T3, typename T4, void (Object::*Method)(T1, T2, T3, T4)>
  void bindMethod(std::string name, JSValue prototype);
  template <typename Object, typename T1, typename T2, typename T3, typename T4, typename T5, void (Object::*Method)(T1, T2, T3, T4, T5)>
  void bindMethod(std::string name, JSValue prototype);
  template <typename Object, typename T1, typename T2, typename T3, typename T4, typename T5, typename T6, void (Object::*Method)(T1, T2, T3, T4, T5, T6)>
  void bindMethod(std::string name, JSValue prototype);
  template <typename Object, typename T1, typename T2, typename T3, typename T4, typename T5, typename T6, typename T7, void (Object::*Method)(T1, T2, T3, T4, T5, T6, T7)>
  void bindMethod(std::string name, JSValue prototype);

  RegisteredClass getRegisteredClass(std::string name);
  bool hasRegisteredClass(std::string name);
  template <typename T> JSValue cppToJs(T obj);

  template <typename View, typename Layout, typename Gesture> void bindViewClassMethods(JSValue prototype);
  template <typename View> void bindButtonClassMethods(JSValue prototype);
  template <typename View> void bindTextClassMethods(JSValue prototype);
  template <typename View> void bindTextInputClassMethods(JSValue prototype);
  template <typename View> void bindVectorElementClassMethods(JSValue prototype);
  template <typename View> void bindVectorPathClassMethods(JSValue prototype);
  template <typename Layout, typename View> void bindStackLayoutClassMethods(JSValue prototype);
  template <typename Layout, typename View> void bindFlexLayoutClassMethods(JSValue prototype);
  template <typename Gesture> void bindGestureClassMethods(JSValue prototype);

  void bindFs();
  void bindFetch();

private:
  JSContext * ctx;
  JSRuntime * rt;

  std::unordered_map<std::string, RegisteredClass> classRegistry;
};

#include "./converters.h"

template <typename T>
runtime::Value Bindings::cppToJs(T obj) {
  auto js = Converter<T>::toScript(ctx, obj, this);
  return js;
}

#include "bindings.hpp"

}
}
