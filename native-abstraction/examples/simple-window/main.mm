#include "../../rehax.h"
#include <iostream>
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

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
  auto btn = Button::Create();
  btn->setTitle("XX");
  btn->setOnPress([] () { std::cout << "Press" << std::endl; });
  view->addView(btn);
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
