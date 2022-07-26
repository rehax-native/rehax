#pragma once

#include "quickjsBindings.h"

namespace rehax {
namespace quickjs {

class QuickJsVm : public Bindings
{
public:
    QuickJsVm();
    void evaluate(std::string script);
    void makeConsole();
    #ifdef REHAX_WITH_FLUXE
    void setRootView(rehax::ui::fluxe::impl::View<rehax::ui::RawPtr<rehax::quickjs::QuickJsContainerData>> * view);
    #endif
    #ifdef REHAX_WITH_APPKIT
    void setRootView(rehax::ui::appkit::impl::View<rehax::ui::RawPtr<rehax::quickjs::QuickJsContainerData>> * view);
    #endif

private:
    JSRuntime * runtime;
    JSContext * context;

};

}
}
