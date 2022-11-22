#include "MouseHandler.h"
#import <Cocoa/Cocoa.h>

using namespace rehax::ui::appkit::impl;

#include "../../../shared/components/MouseHandler.cc"

std::string MouseHandler::description() {
  return "MouseHandler/AppKit";
}

MouseHandler::~MouseHandler() {
}

