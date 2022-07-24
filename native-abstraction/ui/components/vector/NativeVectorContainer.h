#pragma once

#include <functional>
#include <vector>
#include "../../view/cpp/NativeView.h"

struct NativeGradientStop {
  NativeColor color;
  float offset;
};

struct NativeGradient {
  std::vector<NativeGradientStop> stops;

  void addStop(NativeColor color, float offset)
  {
    stops.push_back({ color, offset });
  }
};

struct NativeFilterDef {
  int type;
  float blurRadius;

  void setType(int type)
  {
    this->type = type;
  }

  void setBlurRadius(float blurRadius)
  {
    this->blurRadius = blurRadius;
  }
};

struct NativeFilters {
  std::vector<NativeFilterDef> defs;

  void addBlurFilter(float blurRadius)
  {
    defs.push_back({ 0, blurRadius });
  }
};

class NativeVectorContainer : public NativeView
{
public:
  RHX_EXPORT void createFragment() override;
  RHX_EXPORT virtual void addView(NativeView *child) override;
};

class NativeVectorElement : public NativeView
{
public:

  RHX_EXPORT void setLineWidth(float width);
  RHX_EXPORT void setLineCap(int capsStyle);
  RHX_EXPORT void setLineJoin(int joinStyle);

  RHX_EXPORT void setFillColor(NativeColor color);
  RHX_EXPORT void setStrokeColor(NativeColor color);

  RHX_EXPORT void setFillGradient(NativeGradient gradient);
  RHX_EXPORT void setStrokeGradient(NativeGradient gradient);
  
  RHX_EXPORT void setFilters(NativeFilters filters);

  RHX_EXPORT virtual void setWidthNatural() override;
  RHX_EXPORT virtual void setHeightNatural() override;
  RHX_EXPORT virtual void setVerticalPositionNatural(NativeView *previousView) override;
  RHX_EXPORT virtual void setHorizontalPositionNatural(NativeView *previousView) override;

};

class NativeVectorCircle : public NativeVectorElement
{
public:
  RHX_EXPORT void createFragment() override;

  RHX_EXPORT void setCenterX(float cx);
  RHX_EXPORT void setCenterY(float cy);
  RHX_EXPORT void setRadius(float r);
};

class NativeVectorPath : public NativeVectorElement
{
public:
  RHX_EXPORT void createFragment() override;

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
