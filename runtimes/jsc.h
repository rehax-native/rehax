#pragma once

#include "jscBindings.h"
#include <JavaScriptCore/JavaScriptCore.h>

namespace rehax {
namespace jsc {

class JscVm : public Bindings
{
public:
    JscVm();
    void evaluate(std::string script);
    #ifdef REHAX_WITH_FLUXE
    void setRootView(rehax::ui::fluxe::rawptr::View * view);
    #endif
    #ifdef REHAX_WITH_APPKIT
    void setRootView(rehax::ui::appkit::rawptr::View * view);
    #endif

private:
    JSVirtualMachine * vm;
    JSContext * context;
};

}
}
