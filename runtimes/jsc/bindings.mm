#include "./bindings.h"

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

RegisteredClass Bindings::getRegisteredClass(std::string name) {
  return classRegistry[name];
}

#include "../common/bindRehax.cc"

}
}
