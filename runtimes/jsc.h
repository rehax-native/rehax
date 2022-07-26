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
    void makeConsole();
    #ifdef REHAX_WITH_FLUXE
    void setRootView(rehax::ui::fluxe::impl::View<rehax::ui::RawPtr<JscRegisteredClass>> * view);
    #endif
    #ifdef REHAX_WITH_APPKIT
    void setRootView(rehax::ui::appkit::impl::View<rehax::ui::RawPtr<JscRegisteredClass>> * view);
    #endif

private:
    JSVirtualMachine * vm;
    JSContext * context;
};

}
}
