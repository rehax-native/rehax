#pragma once
#include <iostream>

namespace rehax::ui {

struct KeyEvent {
  bool propagates = true;
  bool isKeyDown;
  std::string key;
};

}
