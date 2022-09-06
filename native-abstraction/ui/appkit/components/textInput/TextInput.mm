#include "TextInput.h"
#include "../../../base.h"
#include "FunctionalTextInput.h"
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#include <iostream>
#include <vector>

namespace rehax::ui::appkit::impl {

#include "../../../shared/components/TextInput.cc"

std::string TextInput::description() {
  std::ostringstream stringStream;
  stringStream << instanceClassName() << "/NSTextField (Appkit) " << this << ": " << getValue();
  return stringStream.str();
}

void TextInput::createNativeView() {
  NSTextField * view = [FunctionalNSTextField new];
  [view setFrame:NSMakeRect(0, 0, 200, 200)];
  [view setStringValue:@""];
  view.editable = YES;
  view.bezeled = NO;
  [view setBackgroundColor:[NSColor clearColor]];
  [view sizeToFit];
  this->nativeView = (void *) CFBridgingRetain(view);
}

void TextInput::setValue(std::string value) {
  NSTextField * view = (__bridge NSTextField *) this->nativeView;
  [view setStringValue: [NSString stringWithUTF8String: value.c_str()]];
  [view sizeToFit];
}

std::string TextInput::getValue() {
  NSTextField * view = (__bridge NSTextField *) this->nativeView;
  return std::string([view stringValue].UTF8String);
}

void TextInput::setTextColor(rehax::ui::Color color) {
  NSTextField * view = (__bridge NSTextField *) this->nativeView;
  NSColor * c = [NSColor colorWithRed:color.r/255.0 green:color.g/255.0 blue:color.b/255.0 alpha:color.a];
  [view setTextColor:c];
}

void TextInput::setFontSize(float size) {
  NSTextField * view = (__bridge NSTextField *) this->nativeView;
  view.font = [NSFont fontWithName:view.font.fontName size:size];
}

void TextInput::setFontFamilies(std::vector<std::string> fontFamilies) {
  NSTextField * view = (__bridge NSTextField *) this->nativeView;
  for (int i = 0; i < fontFamilies.size(); i++)
  {
    NSString * str = [NSString stringWithCString:fontFamilies[0].c_str() encoding:NSUTF8StringEncoding];
    NSFont * font = [NSFont fontWithName:str size:view.font.pointSize];
    if (font != nullptr) {
      view.font = font;
      break;
    }
  }
}

void TextInput::addNativeView(void * child) {
  View::addNativeView(child);
  NSTextField * view = (__bridge NSTextField *) this->nativeView;
  [view sizeToFit];
}

void TextInput::addNativeView(void * child, void * beforeView) {
  View::addNativeView(child, beforeView);
  NSTextField * view = (__bridge NSTextField *) this->nativeView;
  [view sizeToFit];
}

void TextInput::setPlaceholder(std::string placeholder) {
  NSTextField * view = (__bridge NSTextField *) this->nativeView;
  view.placeholderString = [NSString stringWithUTF8String:placeholder.c_str()];
}

void TextInput::setTextAlignment(TextAlignment alignment) {
  NSTextField * view = (__bridge NSTextField *) this->nativeView;
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

void TextInput::setOnValueChange(std::function<void(std::string)> onValueChange) {
  FunctionalNSTextField * view = (__bridge FunctionalNSTextField *) this->nativeView;
  [view setCallback:onValueChange];
}

void TextInput::focus() {
  FunctionalNSTextField * view = (__bridge FunctionalNSTextField *) this->nativeView;
  [view becomeFirstResponder];
  // If we do it manually it doesn't detect the focus change
  if (view->focusCallback) {
    view->focusCallback();
  }
}

void TextInput::setOnFocus(std::function<void(void)> onFocus) {
  FunctionalNSTextField * view = (__bridge FunctionalNSTextField *) this->nativeView;
  [view setOnFocusCallback:onFocus];
}

void TextInput::setOnBlur(std::function<void(void)> onBlur) {
  FunctionalNSTextField * view = (__bridge FunctionalNSTextField *) this->nativeView;
  [view setOnBlurCallback:onBlur];
}

}
