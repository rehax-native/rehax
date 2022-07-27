#pragma once

#include "../view/View.h"

namespace rehax::ui::appkit::impl {

enum StackLayoutDirection {
  StackLayoutDirection_Vertical,
  StackLayoutDirection_Horizontal,
};

struct StackLayoutOptions {
  StackLayoutDirection direction;
  float spacing;
};

class StackLayout : public ILayout {
public:
  RHX_EXPORT StackLayout();
  RHX_EXPORT StackLayout(StackLayoutOptions options);
  RHX_EXPORT ~StackLayout();

  RHX_EXPORT void layoutContainer(void * nativeView);
  RHX_EXPORT void removeLayout(void * nativeView);
  RHX_EXPORT void onViewAdded(void * nativeView, void * addedNativeView);
  RHX_EXPORT void onViewRemoved(void * nativeView, void * removedNativeView);

private:
  float spacing = 0.0;
  bool isHorizontal = false;
  void * nativeInfo = nullptr;
};

}
