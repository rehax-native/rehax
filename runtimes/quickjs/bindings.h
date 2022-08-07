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
  void defineViewClass(JSContext * ctx, std::string name, RegisteredClass * parentClass);

  template <typename View, typename Layout, typename Gesture> void bindViewClassMethods(JSContext * ctx, JSValue prototype);
  template <typename View> void bindButtonClassMethods(JSContext * ctx, JSValue prototype);
  template <typename View> void bindTextClassMethods(JSContext * ctx, JSValue prototype);
  template <typename View> void bindTextInputClassMethods(JSContext * ctx, JSValue prototype);
  template <typename View> void bindVectorElementClassMethods(JSContext * ctx, JSValue prototype);
  template <typename View> void bindVectorPathClassMethods(JSContext * ctx, JSValue prototype);
  template <typename Layout, typename View> void bindStackLayoutClassMethods(JSContext * ctx, JSValue prototype);
  template <typename Layout, typename View> void bindFlexLayoutClassMethods(JSContext * ctx, JSValue prototype);
  template <typename Gesture> void bindGestureClassMethods(JSContext * ctx, JSValue prototype);

  template <typename View, typename RET, RET (View::*Method)(void)> void bindMethod(std::string name, JSContext * ctx, JSValue prototype);
  template <typename View, void (View::*Method)(void)> void bindMethod(std::string name, JSContext * ctx, JSValue prototype);
  template <typename View, typename T1, void (View::*Method)(T1)>
  void bindMethod(std::string name, JSContext * ctx, JSValue prototype);
  template <typename View, typename T1, typename D1, void (View::*Method)(T1), void (View::*MethodDefault)(D1)>
  void bindMethod(std::string name, JSContext * ctx, JSValue prototype);
  template <typename View, typename T1, typename T2, void (View::*Method)(T1, T2)>
  void bindMethod(std::string name, JSContext * ctx, JSValue prototype);
  template <typename View, typename T1, typename T2, typename T3, void (View::*Method)(T1, T2)>
  void bindMethod(std::string name, JSContext * ctx, JSValue prototype);
  template <typename View, typename T1, typename T2, typename T3, void (View::*Method)(T1, T2, T3)>
  void bindMethod(std::string name, JSContext * ctx, JSValue prototype);
  template <typename View, typename T1, typename T2, typename T3, typename T4, void (View::*Method)(T1, T2, T3, T4)>
  void bindMethod(std::string name, JSContext * ctx, JSValue prototype);
  template <typename View, typename T1, typename T2, typename T3, typename T4, typename T5, void (View::*Method)(T1, T2, T3, T4, T5)>
  void bindMethod(std::string name, JSContext * ctx, JSValue prototype);
  template <typename View, typename T1, typename T2, typename T3, typename T4, typename T5, typename T6, void (View::*Method)(T1, T2, T3, T4, T5, T6)>
  void bindMethod(std::string name, JSContext * ctx, JSValue prototype);
  template <typename View, typename T1, typename T2, typename T3, typename T4, typename T5, typename T6, typename T7, void (View::*Method)(T1, T2, T3, T4, T5, T6, T7)>
  void bindMethod(std::string name, JSContext * ctx, JSValue prototype);

  RegisteredClass getRegisteredClass(std::string name);
  template <typename T> JSValue cppToJs(T obj);

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
