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
void Runtime::setRootView(rehaxUtils::ObjectPointer<rehax::ui::fluxe::View> view) {
  auto rootView = cppToJs(view);

  auto ctx = context.JSGlobalContextRef;
  JSObjectRef globalObject = JSContextGetGlobalObject(context.JSGlobalContextRef);
  JSStringRef rootName = JSStringCreateWithUTF8CString("rootView");
    
  runtime::Value rehax;
  if (!runtime::HasObjectProperty(ctx, globalObject, "rehax")) {
    rehax = runtime::MakeObject(ctx);
    runtime::SetObjectProperty(ctx, globalObject, "rehax", rehax);
  } else {
    rehax = runtime::GetObjectProperty(ctx, globalObject, "rehax");
  }
    
  JSObjectSetProperty(ctx, (JSObjectRef) rehax, rootName, rootView, kJSPropertyAttributeReadOnly, nullptr);
  JSStringRelease(rootName);
}
#endif

#ifdef REHAX_WITH_APPKIT
void Runtime::setRootView(rehaxUtils::ObjectPointer<rehax::ui::appkit::View> view) {
  auto rootView = cppToJs(view);

  auto ctx = context.JSGlobalContextRef;
  JSObjectRef globalObject = JSContextGetGlobalObject(context.JSGlobalContextRef);
  JSStringRef rootName = JSStringCreateWithUTF8CString("rootView");
    
  runtime::Value rehax;
  if (!runtime::HasObjectProperty(ctx, globalObject, "rehax")) {
    rehax = runtime::MakeObject(ctx);
    runtime::SetObjectProperty(ctx, globalObject, "rehax", rehax);
  } else {
    rehax = runtime::GetObjectProperty(ctx, globalObject, "rehax");
  }
    
  JSObjectSetProperty(ctx, (JSObjectRef) rehax, rootName, rootView, kJSPropertyAttributeReadOnly, nullptr);
  JSStringRelease(rootName);
}
#endif
