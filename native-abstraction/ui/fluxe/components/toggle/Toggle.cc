#include "Toggle.h"
#include "../../../base.h"
#include <fluxe/views/CheckBox.h>
#include <iostream>
#include <vector>

namespace rehax::ui::fluxe::impl {

#include "../../../shared/components/Toggle.cc"

std::string Toggle::description() {
  std::ostringstream stringStream;
  stringStream << instanceClassName() << "/fluxe " << this << ": " << getValue();
  return stringStream.str();
}

void Toggle::createNativeView() {
  auto view = ::rehaxUtils::Object<::fluxe::CheckBox>::Create();
  view->increaseReferenceCount();
  this->nativeView = view.get();
}

void Toggle::setValue(bool value) {
  auto view = static_cast<::fluxe::CheckBox *>(this->nativeView);
  view->setValue(value);
}

bool Toggle::getValue() {
  auto view = static_cast<::fluxe::CheckBox *>(this->nativeView);
  return view->getValue();
}

void Toggle::setOnValueChange(std::function<void(bool)> onValueChange) {
  auto view = static_cast<::fluxe::CheckBox *>(this->nativeView);
  view->onToggle = [onValueChange] (ObjectPointer<::fluxe::CheckBox> checkbox) {
    onValueChange(checkbox->getValue());
  };
}

}
