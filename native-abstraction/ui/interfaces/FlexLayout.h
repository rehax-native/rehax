
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

  RHX_EXPORT void layoutContainer(void * nativeView);
  RHX_EXPORT void removeLayout(void * nativeView);
  RHX_EXPORT void onViewAdded(void * nativeView, void * addedNativeView);
  RHX_EXPORT void onViewRemoved(void * nativeView, void * removedNativeView);

private:
  std::vector<FlexItem> items;

  bool isHorizontal = false;
  bool isReverse = false;
  FlexJustifyContent justifyContent = FlexJustifyContent::FlexStart;
  FlexAlignItems alignItems = FlexAlignItems::FlexStart;

  void * nativeInfo = nullptr;
};
