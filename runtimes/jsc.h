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
    void setRootView(rehax::ui::fluxe::rawptr::View * view);
    void setRootView(rehax::ui::appkit::rawptr::View * view);

private:
    JSVirtualMachine * vm;
    JSContext * context;
};

}
}
