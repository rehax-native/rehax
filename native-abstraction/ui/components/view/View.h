#pragma once

#include "../../base.h"
#include "../../style.h"

namespace rehax {

namespace ui {

class Gesture;

// struct Position
// {
//   float x;
//   float y;
//   RHX_EXPORT static Position create(float x, float y);
// };

// struct Size
// {
//   float width;
//   float height;
//   RHX_EXPORT static Size create(float width, float height);
// };

// struct Frame
// {
//   Position position;
//   Size size;
//   RHX_EXPORT static Frame create(Position position, Size size);
// };

template <typename ViewBase>
class View : public ViewBase
{
public:

  RHX_EXPORT static typename ViewBase::PtrType Create();
  // RHX_EXPORT static ViewBase::PtrType CreateWithoutCreatingNativeView();
  RHX_EXPORT View();
  RHX_EXPORT virtual ~View();

  // RHX_EXPORT virtual void createNativeView();
  // RHX_EXPORT virtual void destroyNativeView();
  // RHX_EXPORT void setNativeViewRaw(void * nativeView);

  // // Layouting
  // RHX_EXPORT void setWidthFill();
  // RHX_EXPORT void setHeightFill();
  // RHX_EXPORT virtual void setWidthNatural();
  // RHX_EXPORT virtual void setHeightNatural();
  // RHX_EXPORT void setWidthFixed(float width);
  // RHX_EXPORT void setHeightFixed(float height);
  // RHX_EXPORT void setWidthPercentage(float percent);
  // RHX_EXPORT void setHeightPercentage(float percent);

  // RHX_EXPORT virtual void setVerticalPositionNatural(ViewBase::PtrType previousView);
  // RHX_EXPORT virtual void setHorizontalPositionNatural(ViewBase::PtrType previousView);
  // RHX_EXPORT void setVerticalPositionFixed(float x);
  // RHX_EXPORT void setHorizontalPositionFixed(float y);

  // // Styling
  // RHX_EXPORT void setBackgroundColor(Color color);
  // RHX_EXPORT void setTextColor(Color color);
  // RHX_EXPORT void setOpacity(float opacity);

  // RHX_EXPORT void addGesture(Gesture Gesture);
};

template <typename ViewBase>
class ILayout {
public:
  virtual ~ILayout();
  virtual void layoutContainer(typename ViewBase::PtrType container) = 0;
};

}

}

#include "View.mm"