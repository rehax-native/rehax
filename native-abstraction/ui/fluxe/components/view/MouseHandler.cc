#include "MouseHandler.h"

using namespace rehax::ui::fluxe::impl;

#include "../../../shared/components/MouseHandler.cc"

MouseHandler::~MouseHandler() {
//  if (native != nullptr) {
//    auto eventListener = static_cast<GestureCallbackContainer *>(native);
//    delete eventListener;
//    native = nullptr;
//  }
}

std::string MouseHandler::description() {
  return "MouseHandler/fluxe";
}

RehaxFluxeMouseListener::RehaxFluxeMouseListener(ObjectPointer<MouseHandler> handler)
:handler(handler.get())
{}

void RehaxFluxeMouseListener::onMouseDown(::fluxe::MouseDownEvent & event) {
  MouseEvent mouseEvent {
    .propagates = true,
    .isDown = true,
    .x = event.left,
    .y = event.top,
  };
  handler->handler(mouseEvent);
  if (!mouseEvent.propagates) {
    event.stopPropagation();
  }
}

void RehaxFluxeMouseListener::onMouseUp(::fluxe::MouseUpEvent & event) {
  MouseEvent mouseEvent {
    .propagates = true,
    .isUp = true,
    .x = event.left,
    .y = event.top,
  };
  handler->handler(mouseEvent);
  if (!mouseEvent.propagates) {
    event.stopPropagation();
  }
}

void RehaxFluxeMouseListener::onMouseMove(::fluxe::MouseMoveEvent & event) {
  MouseEvent mouseEvent {
    .propagates = true,
    .isMove = true,
    .x = event.left,
    .y = event.top,
  };
  handler->handler(mouseEvent);
  if (!mouseEvent.propagates) {
    event.stopPropagation();
  }
}

void RehaxFluxeMouseListener::onMouseEnter(::fluxe::MouseEnterEvent event) {
  MouseEvent mouseEvent {
    .propagates = true,
    .isEnter = true,
    .x = event.left,
    .y = event.top,
  };
  handler->handler(mouseEvent);
  if (!mouseEvent.propagates) {
    event.stopPropagation();
  }
}

void RehaxFluxeMouseListener::onMouseExit(::fluxe::MouseExitEvent event) {
  MouseEvent mouseEvent {
    .propagates = true,
    .isExit = true,
    .x = event.left,
    .y = event.top,
  };
  handler->handler(mouseEvent);
  if (!mouseEvent.propagates) {
    event.stopPropagation();
  }
}

//void RehaxFluxeMouseListener::onMouseDown(::fluxe::MouseDownEvent & event) {
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

// bool RehaxFluxeMouseListener::isHandlingMouseboardCommand(ShellMouseboardCommand command) {
//   return true;
// }

// void RehaxFluxeMouseListener::onMouseboardCommand(ShellMouseboardCommand command) {
//   handler->handler({
//     .isMouseDown = true, // TODO
//     .mouse = command.commandMouse,
//   });
// }

// void RehaxFluxeMouseListener::onTextInput(std::string text) {
//   std::cout << "a" << std::endl;
// }

// void RehaxFluxeMouseListener::onMouseboardMoveAction(ShellMouseboardMoveInstruction event) {
//   std::cout << "b" << std::endl;
// //  handler->handler({
// //    .isMouseDown = event.isDown,
// //    .mouse = event.,
// //  });
// }


//void RehaxFluxeIEventListener::onMouseEnter(::fluxe::MouseEnterEvent event) {
////  mouseEnter(event.left, event.top);
//}
//
//void RehaxFluxeIEventListener::onMouseExit(::fluxe::MouseExitEvent event) {
////  mouseExit(event.left, event.top);
//}
