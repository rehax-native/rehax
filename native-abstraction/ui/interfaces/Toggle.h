
class Toggle : public View {

public:
  RHX_EXPORT static ObjectPointer<Toggle> Create();
  RHX_EXPORT static ObjectPointer<Toggle> CreateWithoutCreatingNativeView();
  RHX_EXPORT static std::string ClassName();

  RHX_EXPORT virtual std::string instanceClassName() override;
  RHX_EXPORT virtual std::string description() override;

  RHX_EXPORT virtual void createNativeView() override;

  RHX_EXPORT void setValue(bool value);
  RHX_EXPORT void setValue(rehax::ui::DefaultValue);
  RHX_EXPORT bool getValue();

  RHX_EXPORT void setOnValueChange(std::function<void(bool)> onValueChange);
  RHX_EXPORT void setOnValueChange(rehax::ui::DefaultValue);

private:
};
