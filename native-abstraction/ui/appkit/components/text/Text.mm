#include "Text.h"
#include "../../../base.h"
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#include <iostream>

using namespace rehax::ui::appkit::impl;


template <typename Container>
void Text<Container>::createNativeView()
{
  NSTextField * view = [NSTextField new];
  [view setFrame:NSMakeRect(0, 0, 200, 200)];
  [view setStringValue:@""];
  view.editable = NO;
  view.bezeled = NO;
  [view setBackgroundColor:[NSColor clearColor]];
  [view sizeToFit];
  // [view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
  this->nativeView = (void *) CFBridgingRetain(view);
}

// void rehax::Text::mount(NativeView *parent)
// {
//   NSView * parentView = (__bridge NSView *) parent->nativeView;
//   NSView * view = (__bridge NSView *) nativeView;
//   view.wantsLayer = true;
//   [parentView addSubview: view];
// }

template <typename Container>
void Text<Container>::setText(std::string text)
{
  NSTextField * view = (__bridge NSTextField *) this->nativeView;
  [view setStringValue: [NSString stringWithUTF8String: text.c_str()]];
  [view sizeToFit];
}

template <typename Container>
std::string Text<Container>::getText()
{
  NSTextField * view = (__bridge NSTextField *) this->nativeView;
  return std::string([view stringValue].UTF8String);
}

template <typename Container>
void Text<Container>::setTextColor(rehax::ui::Color color)
{
  NSTextField * view = (__bridge NSTextField *) this->nativeView;
  NSColor * c = [NSColor colorWithRed:color.r/255.0 green:color.g/255.0 blue:color.b/255.0 alpha:color.a];
  [view setTextColor:c];
}

template <typename Container>
void Text<Container>::setFontSize(float size)
{
  NSTextField * view = (__bridge NSTextField *) this->nativeView;
  view.font = [NSFont fontWithName:view.font.fontName size:size];
}

template <typename Container>
void Text<Container>::setFontFamilies(std::vector<std::string> fontFamilies)
{
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
void Text<Container>::addNativeView(void * child)
{
  View<Container>::addNativeView(child);
  NSTextField * view = (__bridge NSTextField *) this->nativeView;
  [view sizeToFit];
}

template class rehax::ui::appkit::impl::Text<rehax::ui::RawPtr<rehax::ui::JscRegisteredClass>>;
