#pragma once

#include <vector>
#include <iostream>
#include "../../../style.h"
#include "../view/View.h"

namespace rehax::ui::appkit::impl {

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

// This shouldn't be instantiated. It's the base for the the different vector elements
class VectorElement : public View {

public:
  RHX_EXPORT static std::string ClassName();

  RHX_EXPORT void setLineWidth(float width);
  RHX_EXPORT void setLineCap(VectorLineCap capsStyle);
  RHX_EXPORT void setLineJoin(VectorLineJoin joinStyle);

  RHX_EXPORT void setFillColor(ui::Color color);
  RHX_EXPORT void setStrokeColor(ui::Color color);

  RHX_EXPORT void setFillGradient(Gradient gradient);
  RHX_EXPORT void setStrokeGradient(Gradient gradient);
  
  RHX_EXPORT void setFilters(Filters filters);

};

}
