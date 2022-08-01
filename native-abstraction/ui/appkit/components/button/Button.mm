#include "Button.h"
#include "../../../base.h"
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "FunctionalButton.h"

namespace rehax::ui::appkit::impl {

ObjectPointer<Button> Button::Create() {
  auto ptr = Object<Button>::Create();
  ptr->createNativeView();
  return ptr;
}

ObjectPointer<Button> Button::CreateWithoutCreatingNativeView() {
  auto ptr = Object<Button>::Create();
  return ptr;
}

std::string Button::ClassName() {
  return "Button";
}

std::string Button::instanceClassName() {
  return Button::ClassName();
}

std::string Button::description() {
  std::ostringstream stringStream;
  stringStream << instanceClassName() << "/NSButton (Appkit) " << this << ": " << getTitle();
  return stringStream.str();
}

void Button::createNativeView() {
  FunctionalNSButton * view = [FunctionalNSButton new];
  [view setFrame:NSMakeRect(0, 0, 200, 200)];
  [view setTitle:@""];
  view.bezelStyle = NSBezelStyleRounded;
  this->nativeView = (void *) CFBridgingRetain(view);
}

void Button::setTitle(std::string title) {
  FunctionalNSButton * view = (__bridge FunctionalNSButton *) this->nativeView;
  [view setTitle: [NSString stringWithUTF8String:title.c_str()]];
}

std::string Button::getTitle() {
  FunctionalNSButton * view = (__bridge FunctionalNSButton *) this->nativeView;
  return std::string([view stringValue].UTF8String);
}

// void Button::setTitleColor(Color color)
// {
//   // NSButton * view = (__bridge NSButton *) nativeView;
//   // NSColor * c = [NSColor colorWithRed:color.r green:color.g blue:color.b alpha:color.a];
//   // [view setTextColor:c];
// }

void Button::setOnPress(std::function<void(void)> onPress) {
  FunctionalNSButton * view = (__bridge FunctionalNSButton *) this->nativeView;
  [view setOnPress:onPress];
}

}
