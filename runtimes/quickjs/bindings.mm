#include "./bindings.h"
#include <array>

namespace rehax {
namespace quickjs {



Bindings::Bindings() {}

void finalizeViewInstance(JSRuntime *rt, JSValue val) {
  auto bindings = static_cast<Bindings*>(JS_GetRuntimeOpaque(rt));
//  auto privateData = static_cast<ViewPrivateData<Object> *>(JS_GetOpaque(val, bindings->instanceClassId));
//  auto ctx = privateData->context;
//  for (auto value : privateData->retainedValues) {
//    JS_FreeValue(ctx, value);
//  }
//   std::cout << "GC" << std::endl;
//  auto view = privateData->view;
//  view->decreaseReferenceCount();
//  delete privateData;
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

#include "../common/bindRehax.cc"

}
}
