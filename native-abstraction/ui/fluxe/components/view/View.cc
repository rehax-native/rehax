#include "View.h"
#include "../../../base.h"
#include "../../../fluxe/fluxe/misc/Object.h"
#include "../../../fluxe/fluxe/views/View.h"
// #include "Gesture.h"

namespace rehax::ui::fluxe::impl {

template <typename Container>
rehax::ui::fluxe::impl::View<Container>::View()
{}

template <typename Container>
rehax::ui::fluxe::impl::View<Container>::~View()
{}

template <typename Container>
void View<Container>::createNativeView()
{
  auto view = ::fluxe::Object<::fluxe::View>::Create();
  view->increaseReferenceCount();
  nativeView = view.get();
}

template <typename Container>
void View<Container>::destroyNativeView()
{
  if (nativeView != nullptr) {
    auto view = static_cast<::fluxe::View *>(nativeView);
    view->decreaseReferenceCount();
    nativeView = nullptr;
  }
}

template <typename Container>
void View<Container>::setNativeViewRaw(void * view)
{
  nativeView = view;
}

template <typename Container>
void * View<Container>::getNativeView()
{
  return nativeView;
}

template <typename Container>
void View<Container>::addNativeView(void * child)
{
  auto view = static_cast<::fluxe::View *>(nativeView);
  auto childView = static_cast<::fluxe::View *>(child);
  view->addSubView(childView);
}

template <typename Container>
void View<Container>::addNativeView(void * child, void * beforeChild)
{
  auto view = static_cast<::fluxe::View *>(nativeView);
  auto childView = static_cast<::fluxe::View *>(child);
  auto beforeChildView = static_cast<::fluxe::View *>(beforeChild);
  // view->addSubView(childView, beforeChildView);
}

template <typename Container>
void View<Container>::removeNativeView(void * child)
{
  auto view = static_cast<::fluxe::View *>(nativeView);
  auto childView = static_cast<::fluxe::View *>(child);
  view->removeSubView(childView);
}

template <typename Container>
void View<Container>::removeFromNativeParent()
{
  auto view = static_cast<::fluxe::View *>(nativeView);
  auto parent = view->getParent();
  if (parent.isValid()) {
    parent->removeSubView(view);
  }
}

template <typename Container>
void View<Container>::setWidthFill()
{
}

template <typename Container>
void View<Container>::setHeightFill()
{
}

template <typename Container>
void View<Container>::setWidthNatural()
{
}

template <typename Container>
void View<Container>::setHeightNatural()
{
}

template <typename Container>
void View<Container>::setWidthFixed(float width)
{
}

template <typename Container>
void View<Container>::setHeightFixed(float height)
{
}

template <typename Container>
void View<Container>::setWidthPercentage(float percentage)
{
}

template <typename Container>
void View<Container>::setHeightPercentage(float percentage)
{
}

template <typename Container>
void View<Container>::setNativeVerticalPositionNatural(void * previousView)
{
}

template <typename Container>
void View<Container>::setNativeHorizontalPositionNatural(void * previousView)
{
}

template <typename Container>
void View<Container>::setVerticalPositionFixed(float y)
{
}

template <typename Container>
void View<Container>::setHorizontalPositionFixed(float x)
{
}

// void View<Container>::setBackgroundColor(rehax::ui::Color color)
// {
//   NSView * view = (__bridge NSView *) nativeView;
//   // [view setWantsLayer:true];
//   // [view setLayer:[CALayer layer]];
//   NSColor *col = [NSColor colorWithDeviceRed:color.r/255.0 green:color.g/255.0 blue:color.b/255.0 alpha:color.a];
//   [view.layer setBackgroundColor:[col CGColor]];
// }

template <typename Container>
void View<Container>::setOpacity(float opacity)
{
}

// void rehax::View<Container>::addGesture(rehax::Gesture nativeGesture)
// {
//   NSView * view = (__bridge NSView *) nativeView;
//   NSGestureRecognizer * rec = (__bridge NSGestureRecognizer *) nativeGesture.native;

//   [view addGestureRecognizer:rec];
// }

// void rehax::View<Container>::removeGesture(rehax::Gesture nativeGesture)
// {
//     // [ TODO ]
// //   NSView * view = (__bridge NSView *) nativeView;
// //   NSGestureRecognizer * rec = (__bridge NSGestureRecognizer *) nativeGesture.native;

// //   [view addGestureRecognizer:rec];
// }

}
