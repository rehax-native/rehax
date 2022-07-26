#pragma once

#include "../../native-abstraction/rehax.h"
#include <unordered_map>
#include <quickjs-src/quickjs.h>

namespace rehax {
namespace quickjs {

constexpr JSClassID kPointerClassId = 0;
constexpr JSClassID kClassClassId = 1;
constexpr JSClassID kPrototypeClassId = 2;


struct RegisteredClass {
  std::string name;
  JSValue prototype;
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
  JSClassID instanceClassId = 0;
    
  Bindings();
  void setContext(JSContext * ctx, JSRuntime * runtime);
  #ifdef REHAX_WITH_APPKIT
  void bindAppkitToQuickJs();
  #endif
  #ifdef REHAX_WITH_FLUXE
  void bindFluxeToQuickJs();
  #endif
  
  template <typename View>
  JSValue cppToJs(View * obj)
  {
    auto className = obj->viewName();
    auto privateData = new ViewPrivateData<View>();
    privateData->view = obj;
    privateData->bindings = this;
    privateData->context = ctx;

    obj->increaseReferenceCount(); // decreased in finalizer

    auto object = JS_NewObjectClass(ctx, Bindings::instanceClassId);
    JS_SetOpaque(object, privateData);
    JS_SetPrototype(ctx, object, classRegistry[className].prototype);
    JS_SetPropertyStr(ctx, object, "__className", JS_NewAtomString(ctx, classRegistry[className].name.c_str()));
    return object;
  }

  RegisteredClass getRegisteredClass(std::string name);

private:
  JSContext * ctx;
  JSRuntime * rt;

  std::unordered_map<std::string, RegisteredClass> classRegistry;
  
  template <typename View>
  void defineViewClass(JSContext * ctx, std::string name, JSValue parentPrototype);

};

}
}
