#pragma once

namespace rehax::ui {

enum class VectorLineCap {
  Butt,
  Square,
  Round,
};

enum class VectorLineJoin {
  Miter,
  Round,
  Bevel,
};


struct GradientStop {
  ui::Color color;
  float offset;
};

struct Gradient {
  std::vector<GradientStop> stops;
};

struct FilterDef {
  int type;
  float blurRadius;
};

struct Filters {
  std::vector<FilterDef> defs;
};

}
