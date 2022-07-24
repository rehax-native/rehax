#pragma once

#include "../view/View.h"
#include <iostream>
#include <functional>

namespace rehax {

enum TextAlignment {
  Left,
  Center,
  Right,
};

class TextInput : public View
{
public:

  RHX_EXPORT static std::shared_ptr<TextInput> Create();
  RHX_EXPORT static std::shared_ptr<TextInput> CreateWithoutCreatingNativeView();
  RHX_EXPORT TextInput();

  RHX_EXPORT virtual void createNativeView() override;

  RHX_EXPORT void setText(std::string text);
  RHX_EXPORT std::string getText();

  RHX_EXPORT void setOnValueChange(std::function<void(void)> onValueChange);

  RHX_EXPORT void setPlaceholder(std::string text);

  RHX_EXPORT void setTextAlignment(TextAlignment alignment);
  RHX_EXPORT void setTextColor(Color color);
  RHX_EXPORT virtual void addView(std::shared_ptr<View> child) override;

};

}
