#include "KeyHandler.h"
#import <Cocoa/Cocoa.h>

using namespace rehax::ui::appkit::impl;

#include "../../../shared/components/KeyHandler.cc"

std::string KeyHandler::description() {
  return "KeyHandler/AppKit";
}

KeyHandler::~KeyHandler() {
}

