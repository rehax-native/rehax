#pragma once

#include <vector>
#include <iostream>
#include "../../../style.h"
#include "../view/View.h"

namespace rehax::ui::appkit::impl {

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
template <typename Container>
class VectorElement : public View<Container> {

public:
  // static typename Container::template Ptr<VectorContainer<Container>> Create() {
  //   auto ptr = new VectorContainer<Container>();
  //   ptr->createNativeView();
  //   return ptr;
  // }

  // static typename Container::template Ptr<VectorContainer<Container>> CreateWithoutCreatingNativeView() {
  //   auto ptr = new VectorContainer<Container>();
  //   return ptr;
  // }

  // virtual std::string viewName() override {
  //   return "VectorContainer";
  // }

  // virtual std::string description() override {
  //   std::ostringstream stringStream;
  //   stringStream << viewName() << "/CALayer (Appkit) " << this;
  //   return stringStream.str();
  // }

  // RHX_EXPORT virtual void createNativeView() override;

  RHX_EXPORT void setLineWidth(float width);
  RHX_EXPORT void setLineCap(int capsStyle);
  RHX_EXPORT void setLineJoin(int joinStyle);

  RHX_EXPORT void setFillColor(ui::Color color);
  RHX_EXPORT void setStrokeColor(ui::Color color);

  RHX_EXPORT void setFillGradient(Gradient gradient);
  RHX_EXPORT void setStrokeGradient(Gradient gradient);
  
  RHX_EXPORT void setFilters(Filters filters);

};

}
