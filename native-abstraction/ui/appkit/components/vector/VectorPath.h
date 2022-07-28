#pragma once

#include <vector>
#include <iostream>
#include "../../../style.h"
#include "./VectorElement.h"

namespace rehax::ui::appkit::impl {

template <typename Container>
class VectorPath : public VectorElement<Container> {

public:
  static typename Container::template Ptr<VectorPath<Container>> Create() {
    auto ptr = new VectorPath<Container>();
    ptr->createNativeView();
    return ptr;
  }

  static typename Container::template Ptr<VectorPath<Container>> CreateWithoutCreatingNativeView() {
    auto ptr = new VectorPath<Container>();
    return ptr;
  }

  virtual std::string viewName() override {
    return "VectorPath";
  }

  virtual std::string description() override {
    std::ostringstream stringStream;
    stringStream << viewName() << "/CALayer (Appkit) " << this;
    return stringStream.str();
  }

  RHX_EXPORT virtual void createNativeView() override;

  RHX_EXPORT void beginPath();
  RHX_EXPORT void pathHorizontalTo(float x);
  RHX_EXPORT void pathVerticalTo(float y);
  RHX_EXPORT void pathMoveTo(float x, float y);
  RHX_EXPORT void pathMoveBy(float x, float y);
  RHX_EXPORT void pathLineTo(float x, float y);
  RHX_EXPORT void pathArc(float rx, float ry, float xAxisRotation, int largeArcFlag, int sweepFlag, float x, float y);
  RHX_EXPORT void pathCubicBezier(float x1, float y1, float x2, float y2, float x, float y);
  RHX_EXPORT void pathQuadraticBezier(float x1, float y1, float x, float y);
  RHX_EXPORT void pathClose();
  RHX_EXPORT void endPath();

};

}
