#include "Text.h"
#include "../../../base.h"
#include "../../../fluxe/fluxe/views/Text.h"
#include <iostream>

namespace rehax::ui::fluxe::impl {

#include "../../../shared/components/Text.cc"

std::string Text::description() {
  std::ostringstream stringStream;
  stringStream << instanceClassName() << "/fluxe " << this << ": " << getText();
  return stringStream.str();
}

void Text::createNativeView() {
  auto view = ::rehaxUtils::Object<::fluxe::Text>::Create();
  view->increaseReferenceCount();
  this->nativeView = view.get();
}

void Text::setText(std::string text) {
  auto view = static_cast<::fluxe::Text *>(this->nativeView);
  view->setText(text);
}

std::string Text::getText() {
  auto view = static_cast<::fluxe::Text *>(this->nativeView);
  return view->getText();
}

void Text::setTextColor(rehax::ui::Color color) {
  auto view = static_cast<::fluxe::Text *>(this->nativeView);
  view->setTextColor(::fluxe::Color::RGBA(color.r, color.g, color.b, color.a));
}

void Text::setFontSize(float size) {
  auto view = static_cast<::fluxe::Text *>(this->nativeView);
  view->setTextSize(size);
}

void Text::setFontFamilies(std::vector<std::string> fontFamilies) {
  auto view = static_cast<::fluxe::Text *>(this->nativeView);
  view->setFontFamilies(fontFamilies);
}

void Text::addNativeView(void * child) {
  View::addNativeView(child);
}

void Text::addNativeView(void * child, void * beforeView) {
  View::addNativeView(child, beforeView);
}

}
