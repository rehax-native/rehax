#pragma once

#include "../lib/common.h"

namespace rehax {

namespace ui {

struct Color
{
  float r;
  float g;
  float b;
  float a;
  RHX_EXPORT static Color create(float r, float g, float b, float a);
};

}

}
