#pragma once

#include "../lib/common.h"

namespace rehax {
namespace ui {

// Colors are 0.0 - 1.0
struct Color {
  float r;
  float g;
  float b;
  float a;
  RHX_EXPORT static Color RGBA(float r, float g, float b, float a);
};

}
}
