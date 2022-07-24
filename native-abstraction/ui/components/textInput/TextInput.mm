#include "TextInput.h"
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface FunctionalNSTextField : NSTextField <NSTextFieldDelegate>
{
  @public
  std::function<void(void)> callback;
}

- (void)setCallback:(std::function<void(void)>)callback;
- (void)controlTextDidChange:(id)notification;

@end

@implementation FunctionalNSTextField

- (void)setCallback:(std::function<void(void)>)cb
{
  self.delegate = self;
  callback = cb;
}

- (void)controlTextDidChange:(id)notification
{
  callback();
}

@end


std::shared_ptr<rehax::TextInput> Create()
{
  auto view = std::make_shared<rehax::TextInput>();
  view->createNativeView();
  return view;
}

std::shared_ptr<rehax::TextInput> CreateWithoutCreatingNativeView()
{
  auto view = std::make_shared<rehax::TextInput>();
  return view;
}

rehax::TextInput::TextInput()
{}

void rehax::TextInput::createNativeView() {
  NSTextField * view = [FunctionalNSTextField new];
  [view setFrame:NSMakeRect(0, 0, 200, 200)];
  [view setStringValue:@""];
  view.editable = YES;
  view.bezeled = NO;
  [view setBackgroundColor:[NSColor clearColor]];
  [view sizeToFit];
  // [view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
  nativeView = (void *) CFBridgingRetain(view);
}

void rehax::TextInput::setText(std::string text)
{
  NSTextField * view = (__bridge NSTextField *) nativeView;
  [view setStringValue: [NSString stringWithUTF8String: text.c_str()]];
  [view sizeToFit];
}

std::string rehax::TextInput::getText()
{
  NSTextField * view = (__bridge NSTextField *) nativeView;
  return std::string([view stringValue].UTF8String);
}

void rehax::TextInput::setPlaceholder(std::string text)
{
  NSTextField * view = (__bridge NSTextField *) nativeView;
  view.placeholderString = [NSString stringWithUTF8String: text.c_str()];
}

void rehax::TextInput::setTextColor(Color color)
{
  NSTextField * view = (__bridge NSTextField *) nativeView;
  NSColor * c = [NSColor colorWithRed:color.r green:color.g blue:color.b alpha:color.a];
  [view setTextColor:c];
}

void rehax::TextInput::setTextAlignment(TextAlignment alignment)
{
  NSTextField * view = (__bridge NSTextField *) nativeView;
  switch (alignment) {
    case Left:
      [view setAlignment:NSTextAlignmentLeft];
      break;
    case Center:
      [view setAlignment:NSTextAlignmentCenter];
      break;
    case Right:
      [view setAlignment:NSTextAlignmentRight];
      break;
  }
}

void rehax::TextInput::addView(std::shared_ptr<View> child)
{
  View::addView(child);
  NSTextField * view = (__bridge NSTextField *) nativeView;
  [view sizeToFit];
}

void rehax::TextInput::setOnValueChange(std::function<void(void)> onValueChange)
{
  FunctionalNSTextField * view = (__bridge FunctionalNSTextField *) nativeView;
  [view setCallback:onValueChange];
}
