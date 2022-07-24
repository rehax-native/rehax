#include "Text.h"
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#include <iostream>

std::shared_ptr<rehax::Text> rehax::Text::Create()
{
  auto view = std::make_shared<rehax::Text>();
  view->createNativeView();
  return view;
}

std::shared_ptr<rehax::Text> rehax::Text::CreateWithoutCreatingNativeView()
{
  auto view = std::make_shared<rehax::Text>();
  return view;
}

rehax::Text::Text()
{}

void rehax::Text::createNativeView() {
  NSTextField * view = [NSTextField new];
  [view setFrame:NSMakeRect(0, 0, 200, 200)];
  [view setStringValue:@""];
  view.editable = NO;
  view.bezeled = NO;
  [view setBackgroundColor:[NSColor clearColor]];
  [view sizeToFit];
  // [view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
  nativeView = (void *) CFBridgingRetain(view);
}

// void rehax::Text::mount(NativeView *parent)
// {
//   NSView * parentView = (__bridge NSView *) parent->nativeView;
//   NSView * view = (__bridge NSView *) nativeView;
//   view.wantsLayer = true;
//   [parentView addSubview: view];
// }

void rehax::Text::setText(std::string text)
{
  NSTextField * view = (__bridge NSTextField *) nativeView;
  [view setStringValue: [NSString stringWithUTF8String: text.c_str()]];
  [view sizeToFit];
}

std::string rehax::Text::getText()
{
  NSTextField * view = (__bridge NSTextField *) nativeView;
  return std::string([view stringValue].UTF8String);
}

void rehax::Text::setTextColor(rehax::Color color)
{
  NSTextField * view = (__bridge NSTextField *) nativeView;
  NSColor * c = [NSColor colorWithRed:color.r/255.0 green:color.g/255.0 blue:color.b/255.0 alpha:color.a];
  [view setTextColor:c];
}


void rehax::Text::setFontSize(float size)
{
  NSTextField * view = (__bridge NSTextField *) nativeView;
  view.font = [NSFont fontWithName:view.font.fontName size:size];
}

void rehax::Text::setFontFamilies(std::vector<std::string> fontFamilies)
{
  NSTextField * view = (__bridge NSTextField *) nativeView;
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

void rehax::Text::addView(std::shared_ptr<rehax::View> child)
{
  rehax::View::addView(child);
  NSTextField * view = (__bridge NSTextField *) nativeView;
  [view sizeToFit];
}
