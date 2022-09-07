
class TextInput : public View {

public:
  RHX_EXPORT static ObjectPointer<TextInput> Create();
  RHX_EXPORT static ObjectPointer<TextInput> CreateWithoutCreatingNativeView();
  RHX_EXPORT static std::string ClassName();

  RHX_EXPORT virtual std::string instanceClassName() override;
  RHX_EXPORT virtual std::string description() override;

  RHX_EXPORT virtual void createNativeView() override;

  RHX_EXPORT void focus();
  RHX_EXPORT void setOnFocus(std::function<void(void)> onFocus);
  RHX_EXPORT void setOnFocus(rehax::ui::DefaultValue);
  RHX_EXPORT void setOnBlur(std::function<void(void)> onBlur);
  RHX_EXPORT void setOnBlur(rehax::ui::DefaultValue);
  RHX_EXPORT void setOnSubmit(std::function<void(void)> onSubmit);
  RHX_EXPORT void setOnSubmit(rehax::ui::DefaultValue);

  RHX_EXPORT void setValue(std::string value);
  RHX_EXPORT void setValue(rehax::ui::DefaultValue);
  RHX_EXPORT std::string getValue();

  RHX_EXPORT void setOnValueChange(std::function<void(std::string)> onValueChange);
  RHX_EXPORT void setOnValueChange(rehax::ui::DefaultValue);

  RHX_EXPORT void setPlaceholder(std::string placeholder);
  RHX_EXPORT void setPlaceholder(rehax::ui::DefaultValue);

  RHX_EXPORT void setTextAlignment(TextAlignment alignment);
  RHX_EXPORT void setTextAlignment(rehax::ui::DefaultValue);
  RHX_EXPORT void setTextColor(rehax::ui::Color color);
  RHX_EXPORT void setTextColor(rehax::ui::DefaultValue);
  RHX_EXPORT void setFontSize(float size);
  RHX_EXPORT void setFontSize(rehax::ui::DefaultValue);
  RHX_EXPORT void setFontFamilies(std::vector<std::string> fontFamilies);
  RHX_EXPORT void setFontFamilies(rehax::ui::DefaultValue);
  RHX_EXPORT virtual void addNativeView(void * child) override;
  RHX_EXPORT virtual void addNativeView(void * child, void * beforeChild) override;

};
