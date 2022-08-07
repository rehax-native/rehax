
class View;

class ILayout : public rehaxUtils::Object<ILayout> {
public:

  virtual void layoutContainer(void * nativeView) = 0;
  virtual void removeLayout(void * nativeView) = 0;
  virtual void onViewAdded(void * nativeView, void * addedNativeView) = 0;
  virtual void onViewRemoved(void * nativeView, void * removedNativeView) = 0;

  friend class View;

protected:
  rehaxUtils::WeakObjectPointer<View> containerView;
};
