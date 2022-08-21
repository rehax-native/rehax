#include "./bindings.h"
#include <fstream>
#include <filesystem>
#include "rehaxUtils/httpFetch/HttpFetch.h"

#define RHX_GEN_DOCS 0

#if RHX_GEN_DOCS
#include "../docs.h"
rehax::docs::Docs<rehax::ui::appkit::View> jscDocs("JavascriptCore");
#endif

namespace rehax {
namespace jsc {

Bindings::Bindings() {}

void Bindings::setContext(JSContextRef ctx) {
  this->ctx = ctx;
}

JSContextRef Bindings::getContext() {
  return ctx;
}

RegisteredClass Bindings::getRegisteredClass(std::string name) {
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
#include "../common/bindLinks.cc"

}
}
