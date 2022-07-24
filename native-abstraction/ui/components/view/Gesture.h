#pragma once

#include <functional>
#include "./View.h"

namespace rehax {

enum GestureState {
  GestureState_Possible,
  GestureState_Recognized,
  GestureState_Began,
  GestureState_Changed,
  GestureState_Canceled,
  GestureState_Ended,
};

class Gesture {

public:
  void setup(std::function<void(void)> action, std::function<void(float, float)> onMouseDown, std::function<void(float, float)> onMouseUp, std::function<void(float, float)> onMouseMove);
  void setState(GestureState state);
  void destroy();

  void * native;
};

}
