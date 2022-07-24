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

void JscVm::setRootView(rehax::ui::fluxe::rawptr::View * view)
{
    auto rootView = cppToJs(view, "View");

    JSObjectRef globalObject = JSContextGetGlobalObject(context.JSGlobalContextRef);
    JSStringRef rootName = JSStringCreateWithUTF8CString("rootView");
    JSObjectSetProperty(context.JSGlobalContextRef, globalObject, rootName, rootView, kJSPropertyAttributeReadOnly, nullptr);
}

void JscVm::setRootView(rehax::ui::appkit::rawptr::View * view)
{
    auto rootView = cppToJs(view, "View");

    JSObjectRef globalObject = JSContextGetGlobalObject(context.JSGlobalContextRef);
    JSStringRef rootName = JSStringCreateWithUTF8CString("rootView");
    JSObjectSetProperty(context.JSGlobalContextRef, globalObject, rootName, rootView, kJSPropertyAttributeReadOnly, nullptr);
}
