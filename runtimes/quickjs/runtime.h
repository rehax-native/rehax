#pragma once

#include "./bindings.h"

namespace rehax {
namespace quickjs {

class Runtime : public Bindings
{
public:
    Runtime();
    void evaluate(std::string script);
    void makeConsole();
    #ifdef REHAX_WITH_FLUXE
    void setRootView(rehaxUtils::ObjectPointer<rehax::ui::fluxe::impl::View<rehax::ui::RefCountedPointer>> view);
    #endif
    #ifdef REHAX_WITH_APPKIT
    void setRootView(rehaxUtils::ObjectPointer<rehax::ui::appkit::impl::View<rehax::ui::RefCountedPointer>> view);
    #endif

private:
    JSRuntime * runtime;
    JSContext * context;

};

}
}
