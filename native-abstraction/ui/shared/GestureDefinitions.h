#pragma once

namespace rehax::ui {

enum class GestureState {
  Possible,
  Recognized,
  Began,
  Changed,
  Canceled,
  Ended,
};

}
