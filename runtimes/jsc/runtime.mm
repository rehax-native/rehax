#include "./runtime.h"

using namespace rehax::jsc;

Runtime::Runtime() {
  vm = [JSVirtualMachine new];
  context = [[JSContext new] initWithVirtualMachine:vm];
  context.exceptionHandler = ^(JSContext *context, JSValue *exception) {
    NSLog(@"%@", exception);
  };

  Bindings::setContext(context.JSGlobalContextRef);
}

void Runtime::evaluate(std::string script) {
  NSString * scriptString = [NSString stringWithUTF8String:script.c_str()];
  [context evaluateScript:scriptString];
}

void Runtime::makeConsole() {
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
void Runtime::setRootView(rehaxUtils::ObjectPointer<rehax::ui::fluxe::impl::View<rehax::ui::RefCountedPointer>> view) {
  auto rootView = cppToJs(view.get());

  JSObjectRef globalObject = JSContextGetGlobalObject(context.JSGlobalContextRef);
  JSStringRef rootName = JSStringCreateWithUTF8CString("rootView");
  JSObjectSetProperty(context.JSGlobalContextRef, globalObject, rootName, rootView, kJSPropertyAttributeReadOnly, nullptr);
}
#endif

#ifdef REHAX_WITH_APPKIT
void Runtime::setRootView(rehaxUtils::ObjectPointer<rehax::ui::appkit::impl::View<rehax::ui::RefCountedPointer>> view) {
  auto rootView = cppToJs(view.get());

  JSObjectRef globalObject = JSContextGetGlobalObject(context.JSGlobalContextRef);
  JSStringRef rootName = JSStringCreateWithUTF8CString("rootView");
  JSObjectSetProperty(context.JSGlobalContextRef, globalObject, rootName, rootView, kJSPropertyAttributeReadOnly, nullptr);
}
#endif
