#pragma once

#include <sstream>
#include "../../../../lib/common.h"

namespace rehax::ui::appkit::impl {

template <typename Container>
class View : public Container {

public:

  using PtrType = typename Container::template Ptr<View<Container>>;
  static PtrType Create() {
    auto ptr = new View<Container>();
    ptr->createNativeView();
    return ptr;
  }

  static PtrType CreateWithoutCreatingNativeView() {
    auto ptr = new View<Container>();
    return ptr;
  }

  void addView(PtrType view) {
    this->addContainerView(view);
    addNativeView(view->nativeView);
  }

  void addView(PtrType view, PtrType beforeView) {
    this->addContainerView(view, beforeView);
    addNativeView(view->nativeView, beforeView->nativeView);
  }

  void removeView(PtrType view) {
    this->removeContainerView(view);
    removeNativeView(view->nativeView);
  }

  void removeFromParent() {
    this->removeContainerFromParent();
    removeFromNativeParent();
  }

  virtual std::string viewName() {
    return "View";
  }

  virtual std::string description() {
    std::ostringstream stringStream;
    stringStream << viewName() << "/NSView (Appkit) " << this;
    return stringStream.str();
  }

  RHX_EXPORT View();
  RHX_EXPORT virtual ~View();

  // Platform view
  RHX_EXPORT virtual void createNativeView();
  RHX_EXPORT virtual void destroyNativeView();
  RHX_EXPORT void setNativeViewRaw(void * nativeView);
  RHX_EXPORT void * getNativeView();


  RHX_EXPORT virtual void addNativeView(void * child);
  RHX_EXPORT virtual void addNativeView(void * child, void * beforeChild);
  RHX_EXPORT void removeNativeView(void * child);
  RHX_EXPORT void removeFromNativeParent();

  // Layouting
  RHX_EXPORT void setWidthFill();
  RHX_EXPORT void setHeightFill();
  RHX_EXPORT virtual void setWidthNatural();
  RHX_EXPORT virtual void setHeightNatural();
  RHX_EXPORT void setWidthFixed(float width);
  RHX_EXPORT void setHeightFixed(float height);
  RHX_EXPORT void setWidthPercentage(float percent);
  RHX_EXPORT void setHeightPercentage(float percent);

  RHX_EXPORT void setVerticalPositionNatural(PtrType previousNativeView) {
    setNativeVerticalPositionNatural(previousNativeView->getNativeView());
  }

  RHX_EXPORT void setHorizontalPositionNatural(PtrType previousNativeView) {
    setNativeHorizontalPositionNatural(previousNativeView->getNativeView());
  }

  RHX_EXPORT virtual void setNativeVerticalPositionNatural(void * previousNativeView);
  RHX_EXPORT virtual void setNativeHorizontalPositionNatural(void * previousNativeView);
  RHX_EXPORT void setVerticalPositionFixed(float x);
  RHX_EXPORT void setHorizontalPositionFixed(float y);

  // Styling
  // RHX_EXPORT void setBackgroundColor(rehax::ui::Color color);
  RHX_EXPORT void setOpacity(float opacity);

  // Gesture
//   RHX_EXPORT void addGesture(Gesture Gesture);
//   RHX_EXPORT void removeGesture(Gesture Gesture);

protected:
  void * nativeView = nullptr;
};

}
