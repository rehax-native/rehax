#pragma once

#include <vector>
#include <iostream>
#include "../../../style.h"
#include "../view/View.h"

namespace rehax::ui::appkit::impl {

template <typename Container>
class Text : public View<Container>
{
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

  RHX_EXPORT virtual void createNativeView() override;

  RHX_EXPORT void setText(std::string text);
  RHX_EXPORT std::string getText();

  RHX_EXPORT void setTextColor(::rehax::ui::Color color);
  RHX_EXPORT void setFontSize(float size);
  RHX_EXPORT void setFontFamilies(std::vector<std::string> fontFamilies);
  RHX_EXPORT void addNativeView(void * child);

};

}
