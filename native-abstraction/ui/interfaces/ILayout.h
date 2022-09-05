
class View;

class ILayout : public rehaxUtils::Object<ILayout> {
public:

  static std::string ClassName();

  virtual void layoutContainer(View * view) = 0;
  virtual void removeLayout(View * view) = 0;
  virtual void onViewAdded(View * view, View * addedView) = 0;
  virtual void onViewRemoved(View * view, View * removedView) = 0;

  friend class View;

protected:
  rehaxUtils::WeakObjectPointer<View> containerView;
};
