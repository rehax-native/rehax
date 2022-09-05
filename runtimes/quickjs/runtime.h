#pragma once

#include "./bindings.h"
#include <thread>

namespace rehax {
namespace quickjs {

class Runtime : public Bindings
{
public:
  Runtime();
  ~Runtime();
  void evaluate(std::string script);
  void makeConsole();
  #ifdef REHAX_WITH_FLUXE
  void setRootView(rehaxUtils::ObjectPointer<rehax::ui::fluxe::View> view);
  #endif
  #ifdef REHAX_WITH_APPKIT
  void setRootView(rehaxUtils::ObjectPointer<rehax::ui::appkit::View> view);
  #endif

private:
  JSRuntime * runtime;
  JSContext * context;
  std::thread * runtimeThread;
};

}
}
