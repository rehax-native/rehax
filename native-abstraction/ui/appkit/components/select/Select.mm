#include "Select.h"
#include "../../../base.h"
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "FunctionalPopUp.h"
#include <iostream>
#include <vector>

namespace rehax::ui::appkit::impl {

#include "../../../shared/components/Select.cc"

std::string Select::description() {
  std::ostringstream stringStream;
  stringStream << instanceClassName() << "/NSPopUpButton (Appkit) " << this << ": " << getValue();
  return stringStream.str();
}

void Select::createNativeView() {
  FunctionalNSPopUpButton * view = [FunctionalNSPopUpButton new];
  [view setFrame:NSMakeRect(0, 0, 200, 200)];
  [view sizeToFit];
  this->nativeView = (void *) CFBridgingRetain(view);
}

void Select::setValue(std::string value) {
  FunctionalNSPopUpButton * view = (__bridge FunctionalNSPopUpButton *) this->nativeView;
  for (int i = 0; i < options.size(); i++) {
    if (options[i].value == value) {
      [view selectItemAtIndex:i];
      return;
    }
  }
}

std::string Select::getValue() {
  FunctionalNSPopUpButton * view = (__bridge FunctionalNSPopUpButton *) this->nativeView;
  return options[[view indexOfSelectedItem]].value;
}

void Select::setOptions(std::vector<SelectOption> value) {
  options = value;

  FunctionalNSPopUpButton * view = (__bridge FunctionalNSPopUpButton *) this->nativeView;
  [view removeAllItems];
   for (auto option : value) {
     [view addItemWithTitle:[NSString stringWithUTF8String:option.name.c_str()]];
     view.menu.itemArray.lastObject.action = @selector(handleSelection:);
     view.menu.itemArray.lastObject.target = view;
   }
}

std::vector<SelectOption> Select::getOptions() {
  return options;
}

void Select::setOnValueChange(std::function<void(SelectOption)> onValueChange) {
  FunctionalNSPopUpButton * view = (__bridge FunctionalNSPopUpButton *) this->nativeView;
  [view setCallback:[this, onValueChange, view] () {
    onValueChange(options[[view indexOfSelectedItem]]);
  }];
}

}
