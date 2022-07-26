#include "jsc.h"

using namespace rehax::jsc;

JscVm::JscVm()
{
    vm = [JSVirtualMachine new];
    context = [[JSContext new] initWithVirtualMachine:vm];
    context.exceptionHandler = ^(JSContext *context, JSValue *exception) {
        NSLog(@"%@", exception);
    };

    Bindings::setContext(context.JSGlobalContextRef);
}

void JscVm::evaluate(std::string script)
{
    NSString * scriptString = [NSString stringWithUTF8String:script.c_str()];
    [context evaluateScript:scriptString];
}

void JscVm::makeConsole()
{
    context.globalObject[@"console"] = @{
        @"log": ^(NSString * msg) {
            NSLog(@"%@", msg);
        },
        @"error": ^(NSString * msg) {
            NSLog(@"Error: %@", msg);
        }
    };
}

#ifdef REHAX_WITH_FLUXE
void JscVm::setRootView(rehax::ui::fluxe::impl::View<rehax::ui::RawPtr<JscRegisteredClass>> * view)
{
    auto rootView = cppToJs(view, "View");

    JSObjectRef globalObject = JSContextGetGlobalObject(context.JSGlobalContextRef);
    JSStringRef rootName = JSStringCreateWithUTF8CString("rootView");
    JSObjectSetProperty(context.JSGlobalContextRef, globalObject, rootName, rootView, kJSPropertyAttributeReadOnly, nullptr);
}
#endif

#ifdef REHAX_WITH_APPKIT
void JscVm::setRootView(rehax::ui::appkit::impl::View<rehax::ui::RawPtr<JscRegisteredClass>> * view)
{
    auto rootView = cppToJs(view, "View");

    JSObjectRef globalObject = JSContextGetGlobalObject(context.JSGlobalContextRef);
    JSStringRef rootName = JSStringCreateWithUTF8CString("rootView");
    JSObjectSetProperty(context.JSGlobalContextRef, globalObject, rootName, rootView, kJSPropertyAttributeReadOnly, nullptr);
}
#endif
