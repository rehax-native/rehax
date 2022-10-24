#pragma once

#include <functional>
#include "./View.h"
#include "../../../shared/KeyHandlerDefinitions.h"
#include <fluxe/events/IEventListener.h>

namespace rehax::ui::fluxe::impl {

#include "../../../interfaces/KeyHandler.h"

class RehaxFluxeKeyListener : public ::fluxe::IEventListener {
public:
  RehaxFluxeKeyListener(ObjectPointer<KeyHandler> handler);
//   virtual ~IEventListener() = default;
//   virtual void onMouseDown(::fluxe::MouseDownEvent & event);
//   virtual void onMouseUp(::fluxe::MouseUpEvent & event);
//   virtual void onMouseMove(::fluxe::MouseMoveEvent & event);
//   virtual void onMouseEnter(::fluxe::MouseEnterEvent event);
//   virtual void onMouseExit(::fluxe::MouseExitEvent event);

//   virtual bool isFocusable();
//   virtual void didGainFocus();
//   virtual void didLoseFocus();

  virtual bool isHandlingKeyboardCommand(ShellKeyboardCommand command);
  virtual void onKeyboardCommand(ShellKeyboardCommand command);

  virtual void onTextInput(std::string text);
  virtual void onKeyboardMoveAction(ShellKeyboardMoveInstruction event);

  KeyHandler * handler;
};

}
