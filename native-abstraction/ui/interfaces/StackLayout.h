
class View;

class StackLayout : public ILayout {
public:
  RHX_EXPORT static std::string ClassName();
  RHX_EXPORT static ObjectPointer<StackLayout> Create();

  RHX_EXPORT virtual std::string instanceClassName();
  RHX_EXPORT virtual std::string description();

  RHX_EXPORT StackLayout();
  RHX_EXPORT StackLayout(StackLayoutOptions options);
  RHX_EXPORT ~StackLayout();

  RHX_EXPORT void setOptions(StackLayoutOptions options);
  RHX_EXPORT void setOptions(rehax::ui::DefaultValue);

  RHX_EXPORT void layoutContainer(View * view);
  RHX_EXPORT void removeLayout(View * view);
  RHX_EXPORT void onViewAdded(View * view, View * addedView);
  RHX_EXPORT void onViewRemoved(View * view, View * removedView);

private:
  float spacing = 0.0;
  bool isHorizontal = false;
  void * nativeInfo = nullptr;
};
