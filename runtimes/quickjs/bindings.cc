#include "./bindings.h"
#include <vector>
#include <fstream>
#include <filesystem>
#include "rehaxUtils/httpFetch/HttpFetch.h"

namespace rehax {
namespace quickjs {

Bindings::Bindings() {}

void Bindings::setContext(JSContext * ctx, JSRuntime * runtime) {
  this->ctx = ctx;
  this->rt = runtime;
  JS_SetRuntimeOpaque(rt, this);
}

JSContext * Bindings::getContext() {
  return ctx;
}

RegisteredClass Bindings::getRegisteredClass(std::string name) {
  if (classRegistry.find(name) == classRegistry.end()) {
    throw std::runtime_error("Class not registered: " + name);
  }
  return classRegistry[name];
}

bool Bindings::hasRegisteredClass(std::string name) {
  return classRegistry.find(name) != classRegistry.end();
}

#include "../common/bindRequire.cc"
#include "../common/bindBuffer.cc"
#include "../common/bindCrypto.cc"
#include "../common/bindRehax.cc"
#include "../common/bindFs.cc"
#include "../common/bindFetch.cc"
#include "../common/bindTimer.cc"
#include "../common/bindUtils.cc"
#include "../common/bindLocalStorage.cc"

}
}
