#include "Button.h"
#include "../../../base.h"
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

using namespace rehax::ui::appkit::impl;

@interface FunctionalNSButton : NSButton
{
  @public
  std::function<void(void)> callback;
}

- (void)setOnPress:(std::function<void(void)>)callback;
- (void)onPress:(id)sender;

@end

@implementation FunctionalNSButton

- (void)setOnPress:(std::function<void(void)>)cb
{
  callback = cb;
  [self setTarget:self];
  [self setAction:@selector(onPress:)];
}

- (void)onPress:(id)sender
{
  callback();
}

@end


template <typename Container>
void Button<Container>::createNativeView()
{
  FunctionalNSButton * view = [FunctionalNSButton new];
  [view setFrame:NSMakeRect(0, 0, 200, 200)];
  [view setTitle:@""];
  view.bezelStyle = NSBezelStyleRounded;
  this->nativeView = (void *) CFBridgingRetain(view);
}

template <typename Container>
void Button<Container>::setTitle(std::string title)
{
  FunctionalNSButton * view = (__bridge FunctionalNSButton *) this->nativeView;
  [view setTitle: [NSString stringWithUTF8String:title.c_str()]];
}

template <typename Container>
std::string Button<Container>::getTitle()
{
  FunctionalNSButton * view = (__bridge FunctionalNSButton *) this->nativeView;
  return std::string([view stringValue].UTF8String);
}

// void Button::setTitleColor(Color color)
// {
//   // NSButton * view = (__bridge NSButton *) nativeView;
//   // NSColor * c = [NSColor colorWithRed:color.r green:color.g blue:color.b alpha:color.a];
//   // [view setTextColor:c];
// }

template <typename Container>
void Button<Container>::setOnPress(std::function<void(void)> onPress)
{
  FunctionalNSButton * view = (__bridge FunctionalNSButton *) this->nativeView;
  [view setOnPress:onPress];
}

template class rehax::ui::appkit::impl::Button<rehax::ui::RawPtr<rehax::ui::JscRegisteredClass>>;
