#include "Gesture.h"

using namespace rehax::ui::fluxe::impl;

#include "../../../shared/components/Gesture.cc"

Gesture::~Gesture() {
  if (native != nullptr) {
    auto eventListener = static_cast<GestureCallbackContainer *>(native);
    delete eventListener;
    native = nullptr;
  }
}

void Gesture::setup(std::function<void(void)> action, std::function<void(float, float)> onMouseDown, std::function<void(float, float)> onMouseUp, std::function<void(float, float)> onMouseMove) {
  auto callbacks = new GestureCallbackContainer();
  native = callbacks;
  callbacks->action = action;
  callbacks->mouseDown = onMouseDown;
  callbacks->mouseUp = onMouseUp;
  callbacks->mouseMove = onMouseMove;
}

void Gesture::setState(GestureState state) {
  // NSGestureRecognizer * rec = (__bridge NSGestureRecognizer *) native;

  // switch (state) {
  //   case GestureState::Possible:
  //     rec.state = NSGestureRecognizerStatePossible;
  //     break;
  //   case GestureState::Recognized:
  //     rec.state = NSGestureRecognizerStateRecognized;
  //     break;
  //   case GestureState::Began:
  //     rec.state = NSGestureRecognizerStateBegan;
  //     break;
  //   case GestureState::Changed:
  //     rec.state = NSGestureRecognizerStateChanged;
  //     break;
  //   case GestureState::Canceled:
  //     rec.state = NSGestureRecognizerStateCancelled;
  //     break;
  //   case GestureState::Ended:
  //     rec.state = NSGestureRecognizerStateEnded;
  //     break;
  // }
}

RehaxFluxeIEventListener::RehaxFluxeIEventListener() {}

void RehaxFluxeIEventListener::onMouseDown(::fluxe::MouseDownEvent event) {
  callbacks->mouseDown(event.left, event.top);
}

void RehaxFluxeIEventListener::onMouseUp(::fluxe::MouseUpEvent event) {
  callbacks->mouseUp(event.left, event.top);
}

void RehaxFluxeIEventListener::onMouseMove(::fluxe::MouseMoveEvent event) {
  callbacks->mouseMove(event.left, event.top);
}

//void RehaxFluxeIEventListener::onMouseEnter(::fluxe::MouseEnterEvent event) {
////  mouseEnter(event.left, event.top);
//}
//
//void RehaxFluxeIEventListener::onMouseExit(::fluxe::MouseExitEvent event) {
////  mouseExit(event.left, event.top);
//}
