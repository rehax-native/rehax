#include "Root.h"
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>


@interface NativeRootView : NSView
- (BOOL)isFlipped;
@end

@implementation NativeRootView
- (BOOL)isFlipped {
    return YES;
}
@end


void rehax::Root::initialize(std::function<void(void)> onReady) {
  @autoreleasepool {
    NSRect frame = NSMakeRect(200, 200, 600, 600);
    NSWindow* window = [[NSWindow alloc] initWithContentRect:frame
                        // styleMask: NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskResizable | NSWindowStyleMaskUnifiedTitleAndToolbar | NSWindowStyleMaskFullSizeContentView
                        styleMask: NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskResizable | NSWindowStyleMaskUnifiedTitleAndToolbar
                        backing:NSBackingStoreBuffered
                        defer:NO];

    NSView * view = (__bridge NSView *) nativeView;
    [window setContentView:view];

    [window makeKeyAndOrderFront:NSApp];

    onReady();

    [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
    [NSApp run];
  }
}

std::shared_ptr<rehax::Root> rehax::Root::Create()
{
  auto view = std::make_shared<rehax::Root>();
  view->createNativeView();
  return view;
}

std::shared_ptr<rehax::Root> rehax::Root::CreateWithExistingPlatformView(void * platformView)
{
  auto view = std::make_shared<rehax::Root>();
  view->nativeView = (void *) CFBridgingRetain((__bridge NSView *) platformView);
  return view;
}

rehax::Root::Root()
{}

void rehax::Root::createNativeView()
{
  NSView * view = [NativeRootView new];
  // [view setFrame:NSMakeRect(0, 0, 600, 600)];
  [view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
  view.translatesAutoresizingMaskIntoConstraints = YES;
  nativeView = (void *) CFBridgingRetain(view);
}

void rehax::Root::addView(std::shared_ptr<rehax::View> child)
{
  rehax::View::addView(child);
  NSView * view = (__bridge NSView *) nativeView;
  NSView * childView = (__bridge NSView *) child->nativeView;
  [childView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
  [childView setFrame:[view bounds]];

  NSLayoutConstraint * constraint;
  constraint = [NSLayoutConstraint constraintWithItem:childView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
  [view addConstraint:constraint];
  constraint = [NSLayoutConstraint constraintWithItem:childView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
  [view addConstraint:constraint];
  constraint = [NSLayoutConstraint constraintWithItem:childView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0];
  [view addConstraint:constraint];
  constraint = [NSLayoutConstraint constraintWithItem:childView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0];
  [view addConstraint:constraint];
}
