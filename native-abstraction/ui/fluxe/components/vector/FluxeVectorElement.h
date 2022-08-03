#pragma once

#include "../../../fluxe/fluxe/views/View.h"

namespace rehax::ui::fluxe::impl {

class FluxeVectorElement : public ::fluxe::View {
public:
  float lineWidth = 0;
  VectorLineCap lineCap = VectorLineCap::Butt;
  VectorLineJoin lineJoin = VectorLineJoin::Miter;
  ui::Color fillColor = Color::RGBA(0, 0, 0, 0);
  ui::Color strokeColor = Color::RGBA(0, 0, 0, 0);
  Gradient fillGradient = {};
  Gradient strokeGradient = {};
  Filters filters = {};
};

}
