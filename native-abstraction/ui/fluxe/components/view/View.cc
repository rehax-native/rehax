#include "View.h"
#include "../../../base.h"
#include <fluxe/views/View.h>
#include <fluxe/layout/LayoutTypes.h>
#include "../layouts/StackLayout.h"
#include "Gesture.h"
#include "KeyHandler.h"

namespace rehax::ui::fluxe::impl {

#include "../../../shared/components/View.cc"

void View::createNativeView() {
  auto view = ::rehaxUtils::Object<::fluxe::View>::Create();
  view->increaseReferenceCount();
  nativeView = view.get();
}

void View::destroyNativeView() {
  if (nativeView != nullptr) {
    auto view = static_cast<::fluxe::View *>(nativeView);
    view->decreaseReferenceCount();
    nativeView = nullptr;
  }
}

rehax::ui::Color View::DefaultBackgroundColor() {
  // FIXME: This is fluxe's default color background, but it should come from there
  return rehax::ui::Color::RGBA(0.156, 0.156, 0.156, 1.0);
}

std::string View::description() {
  std::ostringstream stringStream;
  stringStream << instanceClassName() << "/fluxe " << this;
  return stringStream.str();
}

void View::addNativeView(void * child) {
  auto view = static_cast<::fluxe::View *>(nativeView);
  auto childView = static_cast<::fluxe::View *>(child);
  view->addSubView(childView);
}

void View::addNativeView(void * child, void * beforeChild) {
  auto view = static_cast<::fluxe::View *>(nativeView);
  auto childView = static_cast<::fluxe::View *>(child);
  auto beforeChildView = static_cast<::fluxe::View *>(beforeChild);
  view->addSubView(childView, beforeChildView);
}

void View::removeNativeView(void * child) {
  auto view = static_cast<::fluxe::View *>(nativeView);
  auto childView = static_cast<::fluxe::View *>(child);
  view->removeSubView(childView);
}

void View::removeFromNativeParent() {
  auto view = static_cast<::fluxe::View *>(nativeView);
  if (view != nullptr) {
    auto parent = view->getParent();
    if (parent.isValid()) {
      parent->removeSubView(view);
    }
  }
}

void View::setWidthFill() {
  auto view = static_cast<::fluxe::View *>(nativeView);
  view->setSize(::fluxe::LayoutSizeOverride {
    .width = ::fluxe::SizeDimensionTypes::Fill{},
    .height = view->layoutSizeOverride.isSet ? view->layoutSizeOverride.value.height : ::fluxe::SizeDimensionTypes::Natural{},
  });
}

void View::setHeightFill() {
  auto view = static_cast<::fluxe::View *>(nativeView);
  view->setSize(::fluxe::LayoutSizeOverride {
    .width = view->layoutSizeOverride.isSet ? view->layoutSizeOverride.value.width : ::fluxe::SizeDimensionTypes::Natural{},
    .height = ::fluxe::SizeDimensionTypes::Fill{},
  });
}

void View::setWidthNatural() {
  auto view = static_cast<::fluxe::View *>(nativeView);
  view->setSize(::fluxe::LayoutSizeOverride {
    .width = ::fluxe::SizeDimensionTypes::Natural{},
    .height = view->layoutSizeOverride.isSet ? view->layoutSizeOverride.value.height : ::fluxe::SizeDimensionTypes::Natural{},
  });
}

void View::setHeightNatural() {
  auto view = static_cast<::fluxe::View *>(nativeView);
  view->setSize(::fluxe::LayoutSizeOverride {
    .width = view->layoutSizeOverride.isSet ? view->layoutSizeOverride.value.width : ::fluxe::SizeDimensionTypes::Natural{},
    .height = ::fluxe::SizeDimensionTypes::Natural{},
  });
}

void View::setWidthFixed(float width) {
  auto view = static_cast<::fluxe::View *>(nativeView);
  view->setSize(::fluxe::LayoutSizeOverride {
    .width = ::fluxe::SizeDimensionTypes::Fixed{ width },
    .height = view->layoutSizeOverride.isSet ? view->layoutSizeOverride.value.height : ::fluxe::SizeDimensionTypes::Natural{},
  });
}

void View::setHeightFixed(float height) {
  auto view = static_cast<::fluxe::View *>(nativeView);
  view->setSize(::fluxe::LayoutSizeOverride {
    .width = view->layoutSizeOverride.isSet ? view->layoutSizeOverride.value.width : ::fluxe::SizeDimensionTypes::Natural{},
    .height = ::fluxe::SizeDimensionTypes::Fixed{ height },
  });
}

void View::setWidthPercentage(float percentage) {
  auto view = static_cast<::fluxe::View *>(nativeView);
  view->setSize(::fluxe::LayoutSizeOverride {
    .width = ::fluxe::SizeDimensionTypes::Percentage{percentage},
    .height = view->layoutSizeOverride.isSet ? view->layoutSizeOverride.value.height : ::fluxe::SizeDimensionTypes::Natural{},
  });
}

void View::setHeightPercentage(float percentage) {
  auto view = static_cast<::fluxe::View *>(nativeView);
  view->setSize(::fluxe::LayoutSizeOverride {
    .width = view->layoutSizeOverride.isSet ? view->layoutSizeOverride.value.width : ::fluxe::SizeDimensionTypes::Natural{},
    .height = ::fluxe::SizeDimensionTypes::Percentage{percentage},
  });
}

void View::setVerticalPositionNatural(ObjectPointer<View> previousView) {
}

void View::setHorizontalPositionNatural(ObjectPointer<View> previousView) {
}

void View::setVerticalPositionFixed(float y) {
  auto view = static_cast<::fluxe::View *>(nativeView);
  view->setPosition(::fluxe::LayoutPositionOverride {
    .left = view->layoutPositionOverride.value.left,
    .top = ::fluxe::PositionDimensionTypes::Fixed{y},
  });
}

void View::setHorizontalPositionFixed(float x) {
  auto view = static_cast<::fluxe::View *>(nativeView);
  view->setPosition(::fluxe::LayoutPositionOverride {
    .left = ::fluxe::PositionDimensionTypes::Fixed{x},
    .top = view->layoutPositionOverride.value.top,
  });
}

void View::setBackgroundColor(rehax::ui::Color color) {
  auto view = static_cast<::fluxe::View *>(nativeView);
  view->setBackgroundColor(::fluxe::Color::RGBA(color.r, color.g, color.b, color.a));
}

void View::setOpacity(float opacity) {
}

void View::addGesture(ObjectPointer<Gesture> gesture) {
  auto view = static_cast<::fluxe::View *>(nativeView);

  auto listener = view->addEventListener<RehaxFluxeIEventListener>();
  listener->callbacks = static_cast<GestureCallbackContainer *>(gesture->native);
}

void View::removeGesture(ObjectPointer<Gesture> gesture)
{
    // [ TODO ]
//   NSView * view = (__bridge NSView *) nativeView;
//   NSGestureRecognizer * rec = (__bridge NSGestureRecognizer *) nativeGesture.native;

//   [view addGestureRecognizer:rec];
}

void View::addKeyHandler(ObjectPointer<KeyHandler> keyHandler) {
  auto view = static_cast<::fluxe::View *>(nativeView);

std::cout << " add key handler " << std::endl;
  auto listener = view->addEventListener<RehaxFluxeKeyListener>(keyHandler);
  // listener->callbacks = static_cast<GestureCallbackContainer *>(gesture->native);
}

}
