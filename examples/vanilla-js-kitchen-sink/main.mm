#include "native-abstraction/rehax.h"
#include "bindings/generated/rehax/binding.h"
#include <iostream>
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <JavaScriptCore/JavaScriptCore.h>

using namespace rehax::ui::appkit::rawptr;

@interface AppDelegate : NSObject 

@property (retain) NSWindow * window;
@property (retain) NSView * view;

@end

@implementation AppDelegate

- (id)init
{
	if (self = [super init])
  {
		NSRect contentSize = NSMakeRect(0.0f, 0.0f, 480.0f, 320.0f);
		self.window = [[NSWindow alloc] initWithContentRect:contentSize styleMask:NSWindowStyleMaskTitled backing:NSBackingStoreBuffered defer:YES];
		self.view = [[NSView alloc] initWithFrame:contentSize];
	}
	return self;
}


- (void)applicationWillFinishLaunching:(NSNotification *)notification
{
	[self.window setContentView:self.view];

  auto view = View::CreateWithoutCreatingNativeView();
  view->setNativeViewRaw((__bridge void *) self.view);
  view->setWidthFill();
  view->setHeightFill();
  // auto btn = Button::Create();
  // btn->setTitle("XX");
  // btn->setOnPress([] () { std::cout << "Press" << std::endl; });
  // view->addView(btn);
  id vm = [JSVirtualMachine new];
  JSContext * context = [[JSContext new] initWithVirtualMachine:vm];
  context.exceptionHandler = ^(JSContext *context, JSValue *exception) {
    NSLog(@"%@", exception);
  };

  JSValueRef jsRootView = rehaxMakeViewInstanceObject(context.JSGlobalContextRef, view);
  JSObjectRef globalObject = JSContextGetGlobalObject(context.JSGlobalContextRef);
  JSStringRef rootName = JSStringCreateWithUTF8CString("rootView");
  JSObjectSetProperty(context.JSGlobalContextRef, globalObject, rootName, jsRootView, kJSPropertyAttributeReadOnly, nullptr);

  setupRehaxBindings(context.JSGlobalContextRef);
  [context evaluateScript:@"var btn = Rehax.Button.create(); btn.setTitle('Henlo'); btn.setOnPress(() => console.log('press')); rootView.addView(btn);"];

  // JSContextGroupRef contextGroup = JSContextGroupCreate();
  // JSGlobalContextRef globalContext = JSGlobalContextCreateInGroup(contextGroup, nullptr);
  // JSObjectRef globalObject = JSContextGetGlobalObject(globalContext);
  
  // // JSStringRef logFunctionName = JSStringCreateWithUTF8CString("log");
  // // JSObjectRef functionObject = JSObjectMakeFunctionWithCallback(globalContext, logFunctionName, &ObjectCallAsFunctionCallback);
      
  // // JSObjectSetProperty(globalContext, globalObject, logFunctionName, functionObject, kJSPropertyAttributeNone, nullptr);
  
  // JSStringRef logCallStatement = JSStringCreateWithUTF8CString("log()");
  
  // JSEvaluateScript(globalContext, logCallStatement, nullptr, nullptr, 1, nullptr);
  
  // /* memory management code to prevent memory leaks */
  
  // JSGlobalContextRelease(globalContext);
  // JSContextGroupRelease(contextGroup);
  // // JSStringRelease(logFunctionName);
  // JSStringRelease(logCallStatement);
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
	[self.window makeKeyAndOrderFront:self];
}

@end

int main()
{
  @autoreleasepool
  {
		NSApplication * application = [NSApplication sharedApplication];
		AppDelegate * applicationDelegate = [AppDelegate new];
		[application setDelegate:applicationDelegate];
		
		ProcessSerialNumber psn = { 0, kCurrentProcess }; 
		OSStatus returnCode = TransformProcessType(& psn, kProcessTransformToForegroundApplication);

		[NSApp activateIgnoringOtherApps:YES];
		[application run];
	}

  return 0;
}
