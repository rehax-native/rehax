#pragma once

#include <vector>
#include <iostream>
#include "../view/View.h"

namespace rehax {

class Text : public View
{
public:
  RHX_EXPORT static std::shared_ptr<Text> Create();
  RHX_EXPORT static std::shared_ptr<Text> CreateWithoutCreatingNativeView();
  RHX_EXPORT Text();

  RHX_EXPORT virtual void createNativeView() override;

  RHX_EXPORT void setText(std::string text);
  RHX_EXPORT std::string getText();

  RHX_EXPORT void setTextColor(Color color);
  RHX_EXPORT void setFontSize(float size);
  RHX_EXPORT void setFontFamilies(std::vector<std::string> fontFamilies);
  RHX_EXPORT virtual void addView(std::shared_ptr<View> child) override;

};

}
