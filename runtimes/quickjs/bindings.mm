#include "./bindings.h"
#include <array>

namespace rehax {
namespace quickjs {



Bindings::Bindings() {}

void Bindings::setContext(JSContext * ctx, JSRuntime * runtime) {
  this->ctx = ctx;
  this->rt = runtime;
  JS_SetRuntimeOpaque(rt, this);
    
  // JS_NewClassID(&instanceClassId);
  // JSClassDef classDef;
  // classDef.class_name = "ViewInstance";
  // classDef.finalizer = finalizeViewInstance;
  // auto classId = JS_NewClass(runtime, instanceClassId, &classDef);
  // instanceClassId = classId;
}

RegisteredClass Bindings::getRegisteredClass(std::string name) {
  if (classRegistry.find(name) == classRegistry.end()) {
    throw std::runtime_error("Class not registered: " + name);
  }
  return classRegistry[name];
}

#include "../common/bindRehax.cc"

}
}
