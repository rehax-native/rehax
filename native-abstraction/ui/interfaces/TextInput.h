
class TextInput : public View {

public:
  RHX_EXPORT static ObjectPointer<TextInput> Create();
  RHX_EXPORT static ObjectPointer<TextInput> CreateWithoutCreatingNativeView();
  RHX_EXPORT static std::string ClassName();

  RHX_EXPORT virtual std::string instanceClassName() override;
  RHX_EXPORT virtual std::string description() override;

  RHX_EXPORT virtual void createNativeView() override;

  RHX_EXPORT void setValue(std::string value);
  RHX_EXPORT std::string getValue();

  RHX_EXPORT void setOnValueChange(std::function<void(void)> onValueChange);

  RHX_EXPORT void setPlaceholder(std::string placeholder);

  RHX_EXPORT void setTextAlignment(TextAlignment alignment);
  RHX_EXPORT void setTextColor(rehax::ui::Color color);
  RHX_EXPORT void setFontSize(float size);
  RHX_EXPORT void setFontFamilies(std::vector<std::string> fontFamilies);
  RHX_EXPORT virtual void addNativeView(void * child) override;
  RHX_EXPORT virtual void addNativeView(void * child, void * beforeChild) override;

};
