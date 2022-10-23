#include "Select.h"
#include "../../../base.h"
#include <fluxe/views/Select.h>
#include <iostream>
#include <vector>

namespace rehax::ui::fluxe::impl {

#include "../../../shared/components/Select.cc"

std::string Select::description() {
  std::ostringstream stringStream;
  stringStream << instanceClassName() << "/fluxe " << this << ": " << getValue();
  return stringStream.str();
}

void Select::createNativeView() {
  auto view = ::rehaxUtils::Object<::fluxe::Select>::Create();
  view->increaseReferenceCount();
  this->nativeView = view.get();
}

void Select::setValue(std::string value) {
  auto view = static_cast<::fluxe::Select *>(this->nativeView);
  view->setValue(value);
}

std::string Select::getValue() {
  auto view = static_cast<::fluxe::Select *>(this->nativeView);
  auto option = view->getValue();
  return option.isSet ? option.value : "";
}

void Select::setOptions(std::vector<SelectOption> value) {
  std::vector<::fluxe::SelectOption> fluxeOptions;
  for (auto option : value) {
    fluxeOptions.push_back(::fluxe::SelectOption {
      .name = option.name,
      .value = option.value,
    });
  }
  auto view = static_cast<::fluxe::Select *>(this->nativeView);
  view->setOptions(fluxeOptions);
}

std::vector<SelectOption> Select::getOptions() {
  auto view = static_cast<::fluxe::Select *>(this->nativeView);
  std::vector<SelectOption> options;
  auto fluxeOptions = view->getOptions();
  for (auto option : fluxeOptions) {
    options.push_back(SelectOption {
      .name = option.name,
      .value = option.value,
    });
  }
  return options;
}

void Select::setOnValueChange(std::function<void(SelectOption)> onValueChange) {
  auto view = static_cast<::fluxe::Select *>(this->nativeView);
  view->onValueChanged = [onValueChange] (::fluxe::Nullable<::fluxe::SelectOption> value) {
    if (value.isSet) {
      onValueChange(SelectOption {
        .name = value.value.name,
        .value = value.value.value,
      });
    } else {
      onValueChange({});
    }
  };
}

}
