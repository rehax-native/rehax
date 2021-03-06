#pragma once

#include <vector>
#include <iostream>
#include "../../../style.h"
#include "../view/View.h"

namespace rehax::ui::fluxe::impl {

template <typename Container>
class Text : public View<Container> {

public:
  static typename Container::template Ptr<Text<Container>> Create() {
    auto ptr = new Text<Container>();
    ptr->createNativeView();
    return ptr;
  }

  static typename Container::template Ptr<Text<Container>> CreateWithoutCreatingNativeView() {
    auto ptr = new Text<Container>();
    return ptr;
  }

  virtual std::string viewName() override {
    return "Text";
  }

  virtual std::string description() override {
    std::ostringstream stringStream;
    stringStream << viewName() << "/fluxe::Text (fluxe) " << this << ": " << getText();
    return stringStream.str();
  }

  RHX_EXPORT virtual void createNativeView() override;

  RHX_EXPORT void setText(std::string text);
  RHX_EXPORT std::string getText();

  RHX_EXPORT void setTextColor(::rehax::ui::Color color);
  RHX_EXPORT void setFontSize(float size);
  RHX_EXPORT void setFontFamilies(std::vector<std::string> fontFamilies);

};

}
