#pragma once

#include <functional>
#include "./View.h"
#include "../../../shared/GestureDefinitions.h"
#include "../../../fluxe/fluxe/events/IEventListener.h"

namespace rehax::ui::fluxe::impl {

#include "../../../interfaces/Gesture.h"

struct GestureCallbackContainer {
  std::function<void(void)> action;
  std::function<void(float, float)> mouseDown;
  std::function<void(float, float)> mouseUp;
  std::function<void(float, float)> mouseMove;
};

class RehaxFluxeIEventListener : public ::fluxe::IEventListener {
public:
  RehaxFluxeIEventListener();
//   virtual ~IEventListener() = default;
  virtual void onMouseDown(::fluxe::MouseDownEvent event);
  virtual void onMouseUp(::fluxe::MouseUpEvent event);
  virtual void onMouseMove(::fluxe::MouseMoveEvent event);
//   virtual void onMouseEnter(::fluxe::MouseEnterEvent event);
//   virtual void onMouseExit(::fluxe::MouseExitEvent event);

//   virtual bool isFocusable();
//   virtual void didGainFocus();
//   virtual void didLoseFocus();

//   virtual void onTextInput(std::string text);
//   virtual void onKeyboardMoveAction(ShellKeyboardMoveInstruction event);

  GestureCallbackContainer * callbacks;
};


}
