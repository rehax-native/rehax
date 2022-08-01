#pragma once

#include "./bindings.h"
#include <JavaScriptCore/JavaScriptCore.h>

namespace rehax {
namespace jsc {

class Runtime : public Bindings {

public:
  Runtime();
  void evaluate(std::string script);
  void makeConsole();
  #ifdef REHAX_WITH_FLUXE
  void setRootView(rehaxUtils::ObjectPointer<rehax::ui::fluxe::View> view);
  #endif
  #ifdef REHAX_WITH_APPKIT
  void setRootView(rehaxUtils::ObjectPointer<rehax::ui::appkit::View> view);
  #endif

private:
  JSVirtualMachine * vm;
  JSContext * context;
};

}
}
