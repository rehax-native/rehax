#pragma once

#include "../view/View.h"
#include <functional>
#include <iostream>

namespace rehax::ui::fluxe::impl {

template <typename Container>
class Button : public View<Container>
{
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

  RHX_EXPORT virtual void createNativeView() override;

  RHX_EXPORT void setTitle(std::string title);
  RHX_EXPORT std::string getTitle();

  // RHX_EXPORT void setTitleColor(Color color);

  RHX_EXPORT void setOnPress(std::function<void(void)> onPress);
};

}
