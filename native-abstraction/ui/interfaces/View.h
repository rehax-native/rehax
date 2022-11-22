using namespace rehaxUtils;

class Gesture;
class KeyHandler;
class MouseHandler;

class View : public Object<View> {

public:

  RHX_EXPORT static ObjectPointer<View> Create();
  RHX_EXPORT static ObjectPointer<View> CreateWithoutCreatingNativeView();
  RHX_EXPORT static std::string ClassName();

  RHX_EXPORT static rehax::ui::Color DefaultBackgroundColor();

  RHX_EXPORT View();
  RHX_EXPORT virtual ~View();

  RHX_EXPORT virtual std::string instanceClassName();
  RHX_EXPORT virtual std::string description();

  RHX_EXPORT virtual void addView(ObjectPointer<View> view);
  RHX_EXPORT virtual void addView(ObjectPointer<View> view, ObjectPointer<View> beforeView);
  RHX_EXPORT virtual void removeView(ObjectPointer<View> view);
  RHX_EXPORT void removeFromParent();
  RHX_EXPORT std::vector<View *> getChildren();
  RHX_EXPORT rehaxUtils::WeakObjectPointer<View> getFirstChild();
  RHX_EXPORT rehaxUtils::WeakObjectPointer<View> getNextSibling();
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
  RHX_EXPORT virtual void removeFromNativeParent();

  // Layouting
  RHX_EXPORT void setHorizontalPosition(rehax::ui::Length left);
  RHX_EXPORT void setVerticalPosition(rehax::ui::Length top);
  RHX_EXPORT void setHorizontalPosition(rehax::ui::DefaultValue);
  RHX_EXPORT void setVerticalPosition(rehax::ui::DefaultValue);
  RHX_EXPORT rehax::ui::Length getHorizontalPosition();
  RHX_EXPORT rehax::ui::Length getVerticalPosition();

  RHX_EXPORT void setWidth(rehax::ui::Length width);
  RHX_EXPORT void setHeight(rehax::ui::Length height);
  RHX_EXPORT void setWidth(rehax::ui::DefaultValue);
  RHX_EXPORT void setHeight(rehax::ui::DefaultValue);
  RHX_EXPORT rehax::ui::Length getWidth();
  RHX_EXPORT rehax::ui::Length getHeight();

  RHX_EXPORT void setVerticalPositionNatural(ObjectPointer<View> previousView);
  RHX_EXPORT void setHorizontalPositionNatural(ObjectPointer<View> previousView);
  RHX_EXPORT void setVerticalPositionFixed(float x);
  RHX_EXPORT void setHorizontalPositionFixed(float y);

  RHX_EXPORT virtual void layout();
  RHX_EXPORT virtual void setLayout(rehaxUtils::ObjectPointer<ILayout> layout);
  RHX_EXPORT void setLayout(rehax::ui::DefaultValue);

  // Styling
  RHX_EXPORT void setBackgroundColor(rehax::ui::Color color);
  RHX_EXPORT void setBackgroundColor(rehax::ui::DefaultValue);
  RHX_EXPORT void setOpacity(float opacity);
  RHX_EXPORT void setOpacity(rehax::ui::DefaultValue);

  // Gesture
  RHX_EXPORT void addGesture(ObjectPointer<Gesture> gesture);
  RHX_EXPORT void removeGesture(ObjectPointer<Gesture> gesture);

  RHX_EXPORT void addMouseHandler(ObjectPointer<MouseHandler> mouseHandler);
  RHX_EXPORT void removeMouseHandler(ObjectPointer<MouseHandler> mouseHandler);

  RHX_EXPORT void addKeyHandler(ObjectPointer<KeyHandler> keyHandler);
  RHX_EXPORT void removeKeyHandler(ObjectPointer<KeyHandler> keyHandler);

protected:
  void * nativeView = nullptr;
  rehaxUtils::ObjectPointer<ILayout> _layout;
  std::vector<View *> children;
  rehaxUtils::WeakObjectPointer<View> parent = rehaxUtils::WeakObjectPointer<View>();
  std::set<Gesture *> gestures;
  rehax::ui::Length verticalPosition;
  rehax::ui::Length horizontalPosition;
  rehax::ui::Length width;
  rehax::ui::Length height;


  RHX_EXPORT virtual void setWidthNatural();
  RHX_EXPORT virtual void setHeightNatural();
  RHX_EXPORT void setWidthFill();
  RHX_EXPORT void setHeightFill();
  RHX_EXPORT void setWidthFixed(float width);
  RHX_EXPORT void setHeightFixed(float height);
  RHX_EXPORT void setWidthPercentage(float percent);
  RHX_EXPORT void setHeightPercentage(float percent);
};
