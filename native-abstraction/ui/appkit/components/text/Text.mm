#include "Text.h"
#include "../../../base.h"
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#include <iostream>

namespace rehax::ui::appkit::impl {

#include "../../../shared/components/Text.cc"

std::string Text::description() {
  std::ostringstream stringStream;
  stringStream << instanceClassName() << "/NSTextField (Appkit) " << this << ": " << getText();
  return stringStream.str();
}

void Text::createNativeView() {
  NSTextField * view = [NSTextField new];
  [view setFrame:NSMakeRect(0, 0, 200, 200)];
  [view setStringValue:@""];
  view.editable = NO;
  view.bezeled = NO;
  [view setBackgroundColor:[NSColor clearColor]];
  [view sizeToFit];
  this->nativeView = (void *) CFBridgingRetain(view);
}

void Text::setText(std::string text) {
  NSTextField * view = (__bridge NSTextField *) this->nativeView;
  [view setStringValue: [NSString stringWithUTF8String: text.c_str()]];
  [view sizeToFit];
}

std::string Text::getText() {
  NSTextField * view = (__bridge NSTextField *) this->nativeView;
  return std::string([view stringValue].UTF8String);
}

void Text::setTextColor(rehax::ui::Color color) {
  NSTextField * view = (__bridge NSTextField *) this->nativeView;
  NSColor * c = [NSColor colorWithRed:color.r/255.0 green:color.g/255.0 blue:color.b/255.0 alpha:color.a];
  [view setTextColor:c];
}

void Text::setFontSize(float size) {
  NSTextField * view = (__bridge NSTextField *) this->nativeView;
  view.font = [NSFont fontWithName:view.font.fontName size:size];
}

void Text::setFontFamilies(std::vector<std::string> fontFamilies) {
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

void Text::addNativeView(void * child) {
  View::addNativeView(child);
  NSTextField * view = (__bridge NSTextField *) this->nativeView;
  [view sizeToFit];
}

void Text::addNativeView(void * child, void * beforeView) {
  View::addNativeView(child, beforeView);
  NSTextField * view = (__bridge NSTextField *) this->nativeView;
  [view sizeToFit];
}

}
