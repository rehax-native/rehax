#pragma once
#include <iostream>

namespace rehax::ui {

struct MouseEvent {
  bool propagates = true;
  bool isDown = false;
  bool isUp = false;
  bool isMove = false;
  bool isEnter = false;
  bool isExit = false;
  float x, y;
};

}
