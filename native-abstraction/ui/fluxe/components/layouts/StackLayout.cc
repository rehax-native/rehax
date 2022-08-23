#include "StackLayout.h"
#include <fluxe/views/View.h>
#include <fluxe/layout/StackLayout.h>

using namespace rehax::ui::fluxe::impl;

#include "../../../shared/components/StackLayout.cc"

std::string StackLayout::description() {
  std::ostringstream stringStream;
  stringStream << instanceClassName() << "/fluxe " << this;
  return stringStream.str();
}

void StackLayout::layoutContainer(void * container) {
  auto view = static_cast<::fluxe::View *>(container);
  if (nativeInfo == nullptr) {
    auto layout = Object<::fluxe::StackLayout>::Create();
    layout->increaseReferenceCount();
    nativeInfo = layout.get();
  }
    
  auto layout = static_cast<::fluxe::StackLayout *>(nativeInfo);
    
  if (view->layout.get() != layout) {
    view->setLayout(layout);
  }

  layout->spacing = spacing;
  layout->layoutDirection = isHorizontal ? ::fluxe::StackLayoutDirection::Horizontal : ::fluxe::StackLayoutDirection::Vertical;
    
//  view->setNeedsLayout();
  view->setNeedsRerender(true);
}

void StackLayout::removeLayout(void * container) {
  if (nativeInfo != nullptr) {
    auto layout = static_cast<::fluxe::StackLayout *>(nativeInfo);
    layout->decreaseReferenceCount();
    nativeInfo = nullptr;
    // view->setLayout(Object<::fluxe::StackLayout>::Create());
  }
}

void StackLayout::onViewAdded(void * nativeView, void * addedNativeView) {
  layoutContainer(nativeView);
}

void StackLayout::onViewRemoved(void * nativeView, void * removedNativeView) {
  layoutContainer(nativeView);
}
