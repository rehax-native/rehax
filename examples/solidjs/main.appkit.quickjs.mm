#include "../../runtimes/quickjs/runtime.h"
#include <iostream>
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

using namespace rehax::ui::appkit;

@interface AppDelegate : NSObject<NSApplicationDelegate>

@property (retain) NSWindow * window;
@property (retain) NSView * view;

@end

@implementation AppDelegate

- (id)init
{
	if (self = [super init])
  {
		NSRect contentSize = NSMakeRect(0.0f, 0.0f, 480.0f, 320.0f);
		self.window = [[NSWindow alloc] initWithContentRect:contentSize styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskResizable backing:NSBackingStoreBuffered defer:YES];
		self.view = [[NSView alloc] initWithFrame:contentSize];
	}
	return self;
}


- (void)applicationWillFinishLaunching:(NSNotification *)notification
{
	[self.window setContentView:self.view];

  auto view = View::Create();
  view->setNativeViewRaw((__bridge void *) self.view);
  // view->setWidthFill();
  // view->setHeightFill();


  auto vm = new rehax::quickjs::Runtime();
  vm->makeConsole();
  vm->bindRequire();
  vm->bindFs();
  vm->bindFetch();
  vm->bindTimer();
  vm->bindBuffer();
  vm->bindCrypto();
  vm->bindOS();
  vm->bindApp();
  vm->bindLocalStorage();
  vm->bindAppkitRehax();
  vm->setRootView(view);

  NSString * resourcePath = [[NSBundle mainBundle] resourcePath];
  NSString * scriptPath = [NSString pathWithComponents:@[resourcePath, @"index.native.js"]];
  NSString * script = [NSString stringWithContentsOfFile:scriptPath encoding:NSUTF8StringEncoding error:NULL];
    
  vm->evaluate([script UTF8String]);
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
