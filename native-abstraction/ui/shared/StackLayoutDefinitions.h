#pragma once

namespace rehax::ui {

enum class StackLayoutDirection {
  Vertical,
  Horizontal,
};

struct StackLayoutOptions {
  StackLayoutDirection direction = StackLayoutDirection::Vertical;
  float spacing = 0;
};

}
