#pragma once

#include "../view/View.h"
#include <functional>
#include <iostream>

namespace rehax::ui::appkit::impl {

template <typename Container>
class Button : public View<Container> {

public:
  static typename Container::template Ptr<Button<Container>> Create() {
    auto ptr = new Button<Container>();
    ptr->createNativeView();
    return ptr;
  }

  static typename Container::template Ptr<Button<Container>> CreateWithoutCreatingNativeView() {
    auto ptr = new Button<Container>();
    return ptr;
  }

  virtual std::string viewName() override {
    return "Button";
  }

  virtual std::string description() override {
    std::ostringstream stringStream;
    stringStream << viewName() << "/NSButton (Appkit) " << this << ": " << getTitle();
    return stringStream.str();
  }

  RHX_EXPORT virtual void createNativeView() override;

  RHX_EXPORT void setTitle(std::string title);
  RHX_EXPORT std::string getTitle();

  // RHX_EXPORT void setTitleColor(Color color);

  RHX_EXPORT void setOnPress(std::function<void(void)> onPress);
};

}
