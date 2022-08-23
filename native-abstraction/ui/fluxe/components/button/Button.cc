#include "Button.h"
#include "../../../base.h"
#include <fluxe/views/Button.h>

namespace rehax::ui::fluxe::impl {

#include "../../../shared/components/Button.cc"

std::string Button::description() {
  std::ostringstream stringStream;
  stringStream << instanceClassName() << "/fluxe::Button (fluxe) " << this << ": " << getTitle();
  return stringStream.str();
}

void Button::createNativeView() {
  auto view = ::rehaxUtils::Object<::fluxe::Button>::Create();
  view->increaseReferenceCount();
  this->nativeView = view.get();
}

void Button::setTitle(std::string title) {
  auto view = static_cast<::fluxe::Button *>(this->nativeView);
  view->getTitle()->setText(title);
}

std::string Button::getTitle() {
  auto view = static_cast<::fluxe::Button *>(this->nativeView);
  return view->getTitle()->getText();
}

// void Button::setTitleColor(Color color)
// {
//   // NSButton * view = (__bridge NSButton *) nativeView;
//   // NSColor * c = [NSColor colorWithRed:color.r green:color.g blue:color.b alpha:color.a];
//   // [view setTextColor:c];
// }

void Button::setOnPress(std::function<void(void)> onPress) {
  auto view = static_cast<::fluxe::Button *>(this->nativeView);
  view->onClick = [onPress] (::rehaxUtils::ObjectPointer<::fluxe::Button> btn) {
    onPress();
  };
}

}
