#pragma once
#include <iostream>

namespace rehax::ui {

struct KeyEvent {
  bool isKeyDown;
  std::string key;
};

}
