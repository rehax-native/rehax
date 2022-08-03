#include "FlexLayout.h"
#include "../../../fluxe/fluxe/views/View.h"
#include "../../../fluxe/fluxe/layout/FlexLayout.h"

using namespace rehax::ui::fluxe::impl;
using namespace rehax::ui;

#include "../../../shared/components/FlexLayout.cc"

std::string FlexLayout::description() {
  std::ostringstream stringStream;
  stringStream << instanceClassName() << "/fluxe " << this;
  return stringStream.str();
}

void FlexLayout::layoutContainer(void * container) {
  auto view = static_cast<::fluxe::View *>(container);
  if (nativeInfo == nullptr) {
    auto layout = Object<::fluxe::FlexLayout>::Create();
    layout->increaseReferenceCount();
    nativeInfo = layout.get();
  }
    
  auto layout = static_cast<::fluxe::FlexLayout *>(nativeInfo);
    
  if (view->layout.get() != layout) {
    view->setLayout(layout);
  }

  if (isHorizontal) {
    if (isReverse) {
      layout->direction = ::fluxe::FlexDirection::RowReverse;
    } else {
      layout->direction = ::fluxe::FlexDirection::Row;
    }
  } else {
    if (isReverse) {
      layout->direction = ::fluxe::FlexDirection::ColumnReverse;
    } else {
      layout->direction = ::fluxe::FlexDirection::Column;
    }
  }
  switch (justifyContent) {
    case FlexJustifyContent::FlexStart:
      layout->justifyContent = ::fluxe::FlexJustifyContent::FlexStart;
      break;
    case FlexJustifyContent::FlexEnd:
      layout->justifyContent = ::fluxe::FlexJustifyContent::FlexEnd;
      break;
    case FlexJustifyContent::Center:
      layout->justifyContent = ::fluxe::FlexJustifyContent::Center;
      break;
  }
  switch (alignItems) {
    case FlexAlignItems::FlexStart:
      layout->alignItems = ::fluxe::FlexAlignItems::FlexStart;
      break;
    case FlexAlignItems::FlexEnd:
      layout->alignItems = ::fluxe::FlexAlignItems::FlexEnd;
      break;
    case FlexAlignItems::Center:
      layout->alignItems = ::fluxe::FlexAlignItems::Center;
      break;
    case FlexAlignItems::Stretch:
      layout->alignItems = ::fluxe::FlexAlignItems::Stretch;
      break;
  }
    
//  view->setNeedsLayout();
  view->setNeedsRerender(true);
}

void FlexLayout::removeLayout(void * container) {
  if (nativeInfo != nullptr) {
    auto layout = static_cast<::fluxe::FlexLayout *>(nativeInfo);
    layout->decreaseReferenceCount();
    nativeInfo = nullptr;
    // view->setLayout(Object<::fluxe::StackLayout>::Create());
  }
}

void FlexLayout::onViewAdded(void * nativeView, void * addedNativeView) {
  layoutContainer(nativeView);
}

void FlexLayout::onViewRemoved(void * nativeView, void * removedNativeView) {
  layoutContainer(nativeView);
}
