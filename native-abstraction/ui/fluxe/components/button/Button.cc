#include "Button.h"
#include "../../../base.h"
#include "../../../fluxe/fluxe/misc/Object.h"
#include "../../../fluxe/fluxe/views/Button.h"

using namespace rehax::ui::fluxe::impl;

template <typename Container>
void Button<Container>::createNativeView()
{
  auto view = ::fluxe::Object<::fluxe::Button>::Create();
  view->increaseReferenceCount();
  this->nativeView = view.get();
}

template <typename Container>
void Button<Container>::setTitle(std::string title)
{
  auto view = static_cast<::fluxe::Button *>(this->nativeView);
  view->getTitle()->setText(title);
}

template <typename Container>
std::string Button<Container>::getTitle()
{
  auto view = static_cast<::fluxe::Button *>(this->nativeView);
//  return view->getTitle()->getText();
    return "";
}

// void Button::setTitleColor(Color color)
// {
//   // NSButton * view = (__bridge NSButton *) nativeView;
//   // NSColor * c = [NSColor colorWithRed:color.r green:color.g blue:color.b alpha:color.a];
//   // [view setTextColor:c];
// }

template <typename Container>
void Button<Container>::setOnPress(std::function<void(void)> onPress)
{
  auto view = static_cast<::fluxe::Button *>(this->nativeView);
  view->onClick = [onPress] (::fluxe::ObjectPointer<::fluxe::Button> btn) {
    onPress();
  };
}

template class rehax::ui::fluxe::impl::Button<rehax::ui::RawPtr<rehax::ui::JscRegisteredClass>>;
