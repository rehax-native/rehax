#pragma once

#include "../view/View.h"

namespace rehax {

enum StackLayoutDirection {
  StackLayoutDirection_Vertical,
  StackLayoutDirection_Horizontal,
};

struct StackLayoutOptions {
  StackLayoutDirection direction;
  float spacing;
};

class StackLayout : public ILayout
{
public:
  RHX_EXPORT StackLayout();
  RHX_EXPORT StackLayout(StackLayoutOptions options);
  RHX_EXPORT ~StackLayout();
  RHX_EXPORT void layoutContainer(std::shared_ptr<View> container);
  RHX_EXPORT void cleanUp(std::shared_ptr<View> container);

private:
  float spacing = 0.0;
  bool isHorizontal = false;
  void * nativeInfo = nullptr;
};

}
