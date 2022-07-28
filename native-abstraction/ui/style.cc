#include "style.h"

using namespace rehax::ui;

Color Color::RGBA(float r, float g, float b, float a) {
  Color color;
  color.r = r;
  color.g = g;
  color.b = b;
  color.a = a;
  return color;
}
