#pragma once

#include "../view/View.h"
#include <iostream>
#include <functional>
#include "../../../style.h"

namespace rehax::ui::appkit::impl {

enum TextAlignment {
  Left,
  Center,
  Right,
};

template <typename Container>
class TextInput : public View<Container> {

public:
  static typename Container::template Ptr<TextInput<Container>> Create() {
    auto ptr = new TextInput<Container>();
    ptr->createNativeView();
    return ptr;
  }

  static typename Container::template Ptr<TextInput<Container>> CreateWithoutCreatingNativeView() {
    auto ptr = new TextInput<Container>();
    return ptr;
  }

  virtual std::string viewName() override {
    return "TextInput";
  }

  virtual std::string description() override {
    std::ostringstream stringStream;
    stringStream << viewName() << "/NSTextField (Appkit) " << this << ": " << getValue();
    return stringStream.str();
  }

  RHX_EXPORT virtual void createNativeView() override;

  RHX_EXPORT void setValue(std::string value);
  RHX_EXPORT std::string getValue();

  RHX_EXPORT void setOnValueChange(std::function<void(void)> onValueChange);

  RHX_EXPORT void setPlaceholder(std::string placeholder);

  RHX_EXPORT void setTextAlignment(TextAlignment alignment);
  RHX_EXPORT void setTextColor(rehax::ui::Color color);
  RHX_EXPORT void setFontSize(float size);
  RHX_EXPORT void setFontFamilies(std::vector<std::string> fontFamilies);
  RHX_EXPORT virtual void addNativeView(void * child) override;
  RHX_EXPORT virtual void addNativeView(void * child, void * beforeChild) override;

};

}
