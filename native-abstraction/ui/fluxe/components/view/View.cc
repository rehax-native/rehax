#include "View.h"
#include "../../../base.h"
#include "../../../fluxe/fluxe/views/View.h"
#include "../layouts/StackLayout.h"
#include "Gesture.h"

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
  auto parent = view->getParent();
  if (parent.isValid()) {
    parent->removeSubView(view);
  }
}

void View::setWidthFill() {
}

void View::setHeightFill() {
}

void View::setWidthNatural() {
}

void View::setHeightNatural() {
}

void View::setWidthFixed(float width) {
}

void View::setHeightFixed(float height) {
}

void View::setWidthPercentage(float percentage) {
}

void View::setHeightPercentage(float percentage) {
}

void View::setVerticalPositionNatural(ObjectPointer<View> previousView) {
}

void View::setHorizontalPositionNatural(ObjectPointer<View> previousView) {
}

void View::setVerticalPositionFixed(float y) {
}

void View::setHorizontalPositionFixed(float x) {
}

// void View<Container>::setBackgroundColor(rehax::ui::Color color)
// {
//   NSView * view = (__bridge NSView *) nativeView;
//   // [view setWantsLayer:true];
//   // [view setLayer:[CALayer layer]];
//   NSColor *col = [NSColor colorWithDeviceRed:color.r/255.0 green:color.g/255.0 blue:color.b/255.0 alpha:color.a];
//   [view.layer setBackgroundColor:[col CGColor]];
// }

void View::setOpacity(float opacity) {
}

void View::addGesture(ObjectPointer<Gesture> gesture) {
  auto view = static_cast<::fluxe::View *>(nativeView);

  auto listener = view->addEventListener<RehaxFluxeIEventListener>();
  listener->callbacks = static_cast<GestureCallbackContainer *>(gesture->native);
//  gesture->native = listener;
}

void View::removeGesture(ObjectPointer<Gesture> gesture)
{
    // [ TODO ]
//   NSView * view = (__bridge NSView *) nativeView;
//   NSGestureRecognizer * rec = (__bridge NSGestureRecognizer *) nativeGesture.native;

//   [view addGestureRecognizer:rec];
}

}
