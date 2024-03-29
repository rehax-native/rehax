#pragma once

#include <JavaScriptCore/JavaScriptCore.h>
#include "../../native-abstraction/rehax.h"
#include <unordered_map>
#include <vector>
#include "./runtimeUtils.h"
#include "rehaxUtils/timer/timer.h"
#include "rehaxUtils/linking/linking.h"
#include "rehaxUtils/app/app.h"
#include "rehaxUtils/paths/paths.h"
#include "rehaxUtils/os/os.h"

namespace rehax {
namespace jsc {

struct RegisteredClass {
  std::string name;
  JSClassRef classDefine;
  JSObjectRef classObject;
  JSObjectRef prototype;
};

class Bindings;

template<typename View>
struct ViewPrivateData {
  Bindings * bindings;
  JSContextRef ctx;
  View * view;
};

class Bindings
{
public:
    
  Bindings();
  void setContext(JSContextRef ctx);
  JSContextRef getContext();

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
    typename Select,
    typename Toggle,
    typename VectorContainer,
    typename VectorElement,
    typename VectorRect,
    typename VectorPath,
    typename ILayout,
    typename Gesture,
    typename KeyHandler,
    typename MouseHandler
  >
  void bindRehax();

  template <typename Object, bool instantiable = true>
  void defineClass(std::string name, RegisteredClass * parentClass);

  template <typename FN> void bindStaticMethod(std::string name, runtime::Value classObject, FN fn);

  template <typename Object, typename RET, RET (Object::*Method)(void)> void bindMethod(std::string name,  runtime::Value prototype);
  template <typename Object, void (Object::*Method)(void)> void bindMethod(std::string name, runtime::Value prototype);
  template <typename Object, typename T1, void (Object::*Method)(T1)>
  void bindMethod(std::string name, runtime::Value prototype);
  template <typename Object, typename R1, typename T1, R1 (Object::*Method)(T1)>
  void bindMethod(std::string name, runtime::Value prototype);
  template <typename Object, typename T1, typename D1, void (Object::*Method)(T1), void (Object::*MethodDefault)(D1)>
  void bindMethod(std::string name, runtime::Value prototype);
  template <typename Object, typename T1, typename T2, void (Object::*Method)(T1, T2)>
  void bindMethod(std::string name, runtime::Value prototype);
  template <typename Object, typename T1, typename T2, typename T3, void (Object::*Method)(T1, T2)>
  void bindMethod(std::string name, runtime::Value prototype);
  template <typename Object, typename T1, typename T2, typename T3, typename T4, void (Object::*Method)(T1, T2, T3, T4)>
  void bindMethod(std::string name, runtime::Value prototype);
  template <typename Object, typename T1, typename T2, typename T3, typename T4, typename T5, void (Object::*Method)(T1, T2, T3, T4, T5)>
  void bindMethod(std::string name, runtime::Value prototype);
  template <typename Object, typename T1, typename T2, typename T3, typename T4, typename T5, typename T6, void (Object::*Method)(T1, T2, T3, T4, T5, T6)>
  void bindMethod(std::string name, runtime::Value prototype);
  template <typename Object, typename T1, typename T2, typename T3, typename T4, typename T5, typename T6, typename T7, void (Object::*Method)(T1, T2, T3, T4, T5, T6, T7)>
  void bindMethod(std::string name, runtime::Value prototype);

  RegisteredClass getRegisteredClass(std::string name);
  bool hasRegisteredClass(std::string name);
  template <typename T> JSValueRef cppToJs(T obj);

  template <typename View, typename Layout, typename Gesture, typename KeyHandler, typename MouseHandler> void bindViewClassMethods(runtime::Value classObject, runtime::Value prototype);
  template <typename View> void bindButtonClassMethods(runtime::Value prototype);
  template <typename View> void bindTextClassMethods(runtime::Value prototype);
  template <typename View> void bindTextInputClassMethods(runtime::Value prototype);
  template <typename View> void bindSelectClassMethods(runtime::Value prototype);
  template <typename View> void bindToggleClassMethods(runtime::Value prototype);
  template <typename View> void bindVectorElementClassMethods(runtime::Value prototype);
  template <typename View> void bindVectorRectClassMethods(runtime::Value prototype);
  template <typename View> void bindVectorPathClassMethods(runtime::Value prototype);
  template <typename Layout, typename View> void bindStackLayoutClassMethods(runtime::Value prototype);
  template <typename Layout, typename View> void bindFlexLayoutClassMethods(runtime::Value prototype);
  template <typename Gesture> void bindGestureClassMethods(runtime::Value prototype);
  template <typename KeyHandler> void bindKeyHandlerClassMethods(runtime::Value prototype);
  template <typename MouseHandler> void bindMouseHandlerClassMethods(runtime::Value prototype);

  void bindRequire();
  void bindBuffer();
  void bindCrypto();
  void bindFs();
  void bindFetch();
  void bindTimer();
  void bindLinking();
  void bindOS();
  void bindApp();
  void bindLocalStorage();

private:
  JSContextRef ctx;
  std::unordered_map<std::string, RegisteredClass> classRegistry;
  std::unordered_map<int, rehaxUtils::Timer *> timerRegistry;
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
