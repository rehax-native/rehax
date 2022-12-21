#include "KeyHandler.h"

using namespace rehax::ui::fluxe::impl;

#include "../../../shared/components/KeyHandler.cc"

KeyHandler::~KeyHandler() {
//  if (native != nullptr) {
//    auto eventListener = static_cast<GestureCallbackContainer *>(native);
//    delete eventListener;
//    native = nullptr;
//  }
}

std::string KeyHandler::description() {
  return "KeyHandler/fluxe";
}

RehaxFluxeKeyListener::RehaxFluxeKeyListener(ObjectPointer<KeyHandler> handler)
:handler(handler.get())
{}

//void RehaxFluxeKeyListener::onMouseDown(::fluxe::MouseDownEvent & event) {
//  callbacks->mouseDown(event.left, event.top);
//}
//
//void RehaxFluxeIEventListener::onMouseUp(::fluxe::MouseUpEvent & event) {
//  callbacks->mouseUp(event.left, event.top);
//}
//
//void RehaxFluxeIEventListener::onMouseMove(::fluxe::MouseMoveEvent & event) {
//  callbacks->mouseMove(event.left, event.top);
//}

bool RehaxFluxeKeyListener::isHandlingKeyboardCommand(ShellKeyboardCommand command) {
//  std::cout << "is" << std::endl;
  return true;
}

void RehaxFluxeKeyListener::onKeyboardCommand(ShellKeyboardCommand command) {
  rehax::ui::KeyEvent keyEvent {
    .propagates = true,
    .isKeyDown = true,
    .key = command.commandKey,
  };
  handler->handler(keyEvent);

  if (!keyEvent.propagates) {
    // TODO
//    command.
//    command.propagates = false;
  }
}

void RehaxFluxeKeyListener::onTextInput(std::string text) {
  rehax::ui::KeyEvent keyEvent {
    .propagates = true,
    .isKeyDown = true,
    .key = text,
  };
  handler->handler(keyEvent);

  if (!keyEvent.propagates) {
    // TODO
//    command.
//    command.propagates = false;
  }
}

void RehaxFluxeKeyListener::onKeyboardMoveAction(ShellKeyboardMoveInstruction event) {
  std::cout << "b" << std::endl;
//  handler->handler({
//    .isKeyDown = event.isDown,
//    .key = event.,
//  });
}


//void RehaxFluxeIEventListener::onMouseEnter(::fluxe::MouseEnterEvent event) {
////  mouseEnter(event.left, event.top);
//}
//
//void RehaxFluxeIEventListener::onMouseExit(::fluxe::MouseExitEvent event) {
////  mouseExit(event.left, event.top);
//}
