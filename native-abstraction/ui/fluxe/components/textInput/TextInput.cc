#include "TextInput.h"
#include "../../../base.h"
#include "../../../fluxe/fluxe/views/TextInput.h"
#include <iostream>
#include <vector>

namespace rehax::ui::fluxe::impl {

#include "../../../shared/components/TextInput.cc"

std::string TextInput::description() {
  std::ostringstream stringStream;
  stringStream << instanceClassName() << "/fluxe " << this << ": " << getValue();
  return stringStream.str();
}

void TextInput::createNativeView() {
  auto view = ::rehaxUtils::Object<::fluxe::TextInput>::Create();
  view->increaseReferenceCount();
  this->nativeView = view.get();
}

void TextInput::setValue(std::string value) {
  auto view = static_cast<::fluxe::TextInput *>(this->nativeView);
  view->setValue(value);
}

std::string TextInput::getValue() {
  auto view = static_cast<::fluxe::TextInput *>(this->nativeView);
  return view->getValue();
}

void TextInput::setTextColor(rehax::ui::Color color) {
//  auto view = static_cast<::fluxe::TextInput *>(this->nativeView);
//  view->setTextColor(::fluxe::Color::RGBA(color.r, color.g, color.b, color.a));
}

void TextInput::setFontSize(float size) {
//  auto view = static_cast<::fluxe::TextInput *>(this->nativeView);
//  view->setTextSize(size);
}

void TextInput::setFontFamilies(std::vector<std::string> fontFamilies) {
//  auto view = static_cast<::fluxe::TextInput *>(this->nativeView);
//  view->setFontFamilies(fontFamilies);
}

void TextInput::addNativeView(void * child) {
  View::addNativeView(child);
}

void TextInput::addNativeView(void * child, void * beforeView) {
  View::addNativeView(child, beforeView);
}

void TextInput::setPlaceholder(std::string placeholder) {
//  auto view = static_cast<::fluxe::TextInput *>(this->nativeView);
//  view->setPlaceholder(text);
}

void TextInput::setTextAlignment(TextAlignment alignment) {
  // NSTextField * view = (__bridge NSTextField *) this->nativeView;
  // switch (alignment) {
  //   case Left:
  //     [view setAlignment:NSTextAlignmentLeft];
  //     break;
  //   case Center:
  //     [view setAlignment:NSTextAlignmentCenter];
  //     break;
  //   case Right:
  //     [view setAlignment:NSTextAlignmentRight];
  //     break;
  // }
}

void TextInput::setOnValueChange(std::function<void(void)> onValueChange) {
  auto view = static_cast<::fluxe::TextInput *>(this->nativeView);
  view->onValueChanged = [onValueChange] (std::string value) {
    onValueChange();
  };
}

}
