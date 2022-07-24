#include "Button.h"
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface FunctionalNSButton : NSButton
{
  @public
  std::function<void(void)> callback;
}

- (void)setOnClick:(std::function<void(void)>)callback;
- (void)onClick:(id)sender;

@end

@implementation FunctionalNSButton

- (void)setOnClick:(std::function<void(void)>)cb
{
  callback = cb;
  [self setTarget:self];
  [self setAction:@selector(onClick:)];
}

- (void)onClick:(id)sender
{
  callback();
}

@end

std::shared_ptr<rehax::Button> rehax::Button::Create()
{
  auto view = std::make_shared<rehax::Button>();
  view->createNativeView();
  return view;
}

std::shared_ptr<rehax::Button> rehax::Button::CreateWithoutCreatingNativeView()
{
  auto view = std::make_shared<rehax::Button>();
  return view;
}

rehax::Button::Button()
{}

void rehax::Button::createNativeView() {
  FunctionalNSButton * view = [FunctionalNSButton new];
  [view setFrame:NSMakeRect(0, 0, 200, 200)];
  [view setTitle:@""];
  view.bezelStyle = NSBezelStyleRounded;
  nativeView = (void *) CFBridgingRetain(view);
}

void rehax::Button::setText(std::string text)
{
  FunctionalNSButton * view = (__bridge FunctionalNSButton *) nativeView;
  [view setTitle: [NSString stringWithUTF8String:text.c_str()]];
}

std::string rehax::Button::getText()
{
  FunctionalNSButton * view = (__bridge FunctionalNSButton *) nativeView;
  return std::string([view stringValue].UTF8String);
}

void rehax::Button::setTextColor(Color color)
{
  // NSButton * view = (__bridge NSButton *) nativeView;
  // NSColor * c = [NSColor colorWithRed:color.r green:color.g blue:color.b alpha:color.a];
  // [view setTextColor:c];
}

void rehax::Button::setOnClick(std::function<void(void)> onClick)
{
  FunctionalNSButton * view = (__bridge FunctionalNSButton *) nativeView;
  [view setOnClick:onClick];
}