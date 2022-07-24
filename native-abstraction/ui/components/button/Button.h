#pragma once

#include <functional>
#include <iostream>
#include "../view/View.h"

namespace rehax {

class Button : public View
{
public:
  RHX_EXPORT static std::shared_ptr<Button> Create();
  RHX_EXPORT static std::shared_ptr<Button> CreateWithoutCreatingNativeView();
  RHX_EXPORT Button();

  RHX_EXPORT virtual void createNativeView() override;

  RHX_EXPORT void setText(std::string text);
  RHX_EXPORT std::string getText();

  RHX_EXPORT void setTextColor(Color color);

  RHX_EXPORT void setOnClick(std::function<void(void)> onClick);
};

}
