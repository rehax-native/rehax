#include "Toggle.h"
#include "../../../base.h"
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "FunctionalSwitch.h"
#include <iostream>
#include <vector>

namespace rehax::ui::appkit::impl {

#include "../../../shared/components/Toggle.cc"

std::string Toggle::description() {
  std::ostringstream stringStream;
  stringStream << instanceClassName() << "/NSSwitch (Appkit) " << this << ": " << getValue();
  return stringStream.str();
}

void Toggle::createNativeView() {
  FunctionalNSSwitch * view = [FunctionalNSSwitch new];
  [view setFrame:NSMakeRect(0, 0, 200, 200)];
  [view sizeToFit];
  view.target = view;
  view.action = @selector(handleValue:);
  this->nativeView = (void *) CFBridgingRetain(view);
}

void Toggle::setValue(bool value) {
  FunctionalNSSwitch * view = (__bridge FunctionalNSSwitch *) this->nativeView;
  view.state = NSControlStateValueOn;
}

bool Toggle::getValue() {
  FunctionalNSSwitch * view = (__bridge FunctionalNSSwitch *) this->nativeView;
  return view.state == NSControlStateValueOn;
}

void Toggle::setOnValueChange(std::function<void(bool)> onValueChange) {
  FunctionalNSSwitch * view = (__bridge FunctionalNSSwitch *) this->nativeView;
  [view setCallback:[this, onValueChange, view] () {
    onValueChange(getValue());
  }];
}

}
