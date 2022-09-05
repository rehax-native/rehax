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

void StackLayout::layoutContainer(View * container) {
  auto view = static_cast<::fluxe::View *>(container->getNativeView());
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

void StackLayout::removeLayout(View * container) {
  if (nativeInfo != nullptr) {
    auto layout = static_cast<::fluxe::StackLayout *>(nativeInfo);
    layout->decreaseReferenceCount();
    nativeInfo = nullptr;
    // view->setLayout(Object<::fluxe::StackLayout>::Create());
  }
}

void StackLayout::onViewAdded(View * view, View * addedView) {
  layoutContainer(view);
}

void StackLayout::onViewRemoved(View * view, View * removedView) {
  layoutContainer(view);
}
