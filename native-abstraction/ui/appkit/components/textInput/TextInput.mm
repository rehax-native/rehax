#include "TextInput.h"
#include "../../../base.h"
#include "FunctionalTextInput.h"
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#include <iostream>
#include <vector>

namespace rehax::ui::appkit::impl {

template <typename Container>
void TextInput<Container>::createNativeView() {
  NSTextField * view = [NSTextField new];
  [view setFrame:NSMakeRect(0, 0, 200, 200)];
  [view setStringValue:@""];
  view.editable = YES;
  view.bezeled = NO;
  [view setBackgroundColor:[NSColor clearColor]];
  [view sizeToFit];
  this->nativeView = (void *) CFBridgingRetain(view);
}

template <typename Container>
void TextInput<Container>::setValue(std::string value) {
  NSTextField * view = (__bridge NSTextField *) this->nativeView;
  [view setStringValue: [NSString stringWithUTF8String: value.c_str()]];
  [view sizeToFit];
}

template <typename Container>
std::string TextInput<Container>::getValue() {
  NSTextField * view = (__bridge NSTextField *) this->nativeView;
  return std::string([view stringValue].UTF8String);
}

template <typename Container>
void TextInput<Container>::setTextColor(rehax::ui::Color color) {
  NSTextField * view = (__bridge NSTextField *) this->nativeView;
  NSColor * c = [NSColor colorWithRed:color.r/255.0 green:color.g/255.0 blue:color.b/255.0 alpha:color.a];
  [view setTextColor:c];
}

template <typename Container>
void TextInput<Container>::setFontSize(float size) {
  NSTextField * view = (__bridge NSTextField *) this->nativeView;
  view.font = [NSFont fontWithName:view.font.fontName size:size];
}

template <typename Container>
void TextInput<Container>::setFontFamilies(std::vector<std::string> fontFamilies) {
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

template <typename Container>
void TextInput<Container>::addNativeView(void * child) {
  View<Container>::addNativeView(child);
  NSTextField * view = (__bridge NSTextField *) this->nativeView;
  [view sizeToFit];
}

template <typename Container>
void TextInput<Container>::addNativeView(void * child, void * beforeView) {
  View<Container>::addNativeView(child, beforeView);
  NSTextField * view = (__bridge NSTextField *) this->nativeView;
  [view sizeToFit];
}

template <typename Container>
void TextInput<Container>::setPlaceholder(std::string placeholder) {
  NSTextField * view = (__bridge NSTextField *) this->nativeView;
  view.placeholderString = [NSString stringWithUTF8String:placeholder.c_str()];
}

template <typename Container>
void TextInput<Container>::setTextAlignment(TextAlignment alignment) {
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

template <typename Container>
void TextInput<Container>::setOnValueChange(std::function<void(void)> onValueChange) {
  FunctionalNSTextField * view = (__bridge FunctionalNSTextField *) this->nativeView;
  [view setCallback:onValueChange];
}

}
