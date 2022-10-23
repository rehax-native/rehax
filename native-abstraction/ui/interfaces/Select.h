
class Select : public View {

public:
  RHX_EXPORT static ObjectPointer<Select> Create();
  RHX_EXPORT static ObjectPointer<Select> CreateWithoutCreatingNativeView();
  RHX_EXPORT static std::string ClassName();

  RHX_EXPORT virtual std::string instanceClassName() override;
  RHX_EXPORT virtual std::string description() override;

  RHX_EXPORT virtual void createNativeView() override;

  RHX_EXPORT void setOptions(std::vector<SelectOption> options);
  RHX_EXPORT void setOptions(rehax::ui::DefaultValue);
  RHX_EXPORT std::vector<SelectOption> getOptions();

  RHX_EXPORT void setValue(std::string value);
  RHX_EXPORT void setValue(rehax::ui::DefaultValue);
  RHX_EXPORT std::string getValue();

  RHX_EXPORT void setOnValueChange(std::function<void(SelectOption)> onValueChange);
  RHX_EXPORT void setOnValueChange(rehax::ui::DefaultValue);

private:
  std::vector<SelectOption> options;
};
