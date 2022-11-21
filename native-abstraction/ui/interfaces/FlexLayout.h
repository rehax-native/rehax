class View;

class FlexLayout : public ILayout
{
public:
  RHX_EXPORT static std::string ClassName();
  RHX_EXPORT static ObjectPointer<FlexLayout> Create();

  RHX_EXPORT virtual std::string instanceClassName();
  RHX_EXPORT virtual std::string description();

  RHX_EXPORT FlexLayout();
  RHX_EXPORT ~FlexLayout();

  RHX_EXPORT void setOptions(FlexLayoutOptions flexLayoutOptions);
  RHX_EXPORT void setOptions(rehax::ui::DefaultValue);

  RHX_EXPORT void layoutContainer(View * view);
  RHX_EXPORT void removeLayout(View * view);
  RHX_EXPORT void onViewAdded(View * view, View * addedView);
  RHX_EXPORT void onViewRemoved(View * view, View * removedView);

private:
  std::vector<FlexItem> items;

  bool isHorizontal = false;
  bool isReverse = false;
  FlexJustifyContent justifyContent = FlexJustifyContent::FlexStart;
  FlexAlignItems alignItems = FlexAlignItems::FlexStart;
  float gap = 0;

  void * nativeInfo = nullptr;
};
