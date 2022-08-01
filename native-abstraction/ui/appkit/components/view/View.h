#pragma once

#include <sstream>
#include <set>
#include "../../../../lib/common.h"
#include <rehaxUtils/pointers/Object.h>
#include "../layouts/ILayout.h"

namespace rehax::ui::appkit::impl {

using namespace rehaxUtils;

class Gesture;

class View : public rehaxUtils::Object<View> {

public:

  RHX_EXPORT static ObjectPointer<View> Create();
  RHX_EXPORT static ObjectPointer<View> CreateWithoutCreatingNativeView();
  RHX_EXPORT static std::string ClassName();

  RHX_EXPORT View();
  RHX_EXPORT virtual ~View();

  RHX_EXPORT virtual std::string instanceClassName();
  RHX_EXPORT virtual std::string description();

  RHX_EXPORT void addView(ObjectPointer<View> view);
  RHX_EXPORT void addView(ObjectPointer<View> view, ObjectPointer<View> beforeView);
  RHX_EXPORT void removeView(ObjectPointer<View> view);
  RHX_EXPORT void removeFromParent();
  RHX_EXPORT std::set<View *> getChildren();
  RHX_EXPORT rehaxUtils::WeakObjectPointer<View> getParent();

  RHX_EXPORT void addContainerView(rehaxUtils::ObjectPointer<View> view);
  RHX_EXPORT void addContainerView(rehaxUtils::ObjectPointer<View> view, rehaxUtils::ObjectPointer<View> beforeView);
  RHX_EXPORT void removeContainerFromParent();
  RHX_EXPORT void removeContainerView(rehaxUtils::ObjectPointer<View> view);

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

  RHX_EXPORT void setVerticalPositionNatural(ObjectPointer<View> previousNativeView);
  RHX_EXPORT void setHorizontalPositionNatural(ObjectPointer<View> previousNativeView);
  RHX_EXPORT void setVerticalPositionFixed(float x);
  RHX_EXPORT void setHorizontalPositionFixed(float y);

  RHX_EXPORT void setLayout(rehaxUtils::ObjectPointer<ILayout> layout);

  // Styling
  // RHX_EXPORT void setBackgroundColor(rehax::ui::Color color);
  RHX_EXPORT void setOpacity(float opacity);

  // Gesture
  RHX_EXPORT void addGesture(ObjectPointer<Gesture> Gesture);
  RHX_EXPORT void removeGesture(ObjectPointer<Gesture> Gesture);

protected:
  void * nativeView = nullptr;
  rehaxUtils::ObjectPointer<ILayout> layout;
  std::set<View *> children;
  rehaxUtils::WeakObjectPointer<View> parent = rehaxUtils::WeakObjectPointer<View>();
  std::set<Gesture *> gestures;
};

}
