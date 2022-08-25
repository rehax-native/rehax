
// Allows implementations to define additional data
#ifndef ADDITIONAL_TEXT_DEFS
#define ADDITIONAL_TEXT_DEFS
#endif

class Text : public View {

public:
  RHX_EXPORT static ObjectPointer<Text> Create();
  RHX_EXPORT static ObjectPointer<Text> CreateWithoutCreatingNativeView();
  RHX_EXPORT static std::string ClassName();

  RHX_EXPORT virtual std::string instanceClassName() override;
  RHX_EXPORT virtual std::string description() override;

  RHX_EXPORT virtual void createNativeView() override;

  RHX_EXPORT void setText(std::string text);
  RHX_EXPORT void setText(rehax::ui::DefaultValue);
  RHX_EXPORT std::string getText();

  RHX_EXPORT void setTextColor(::rehax::ui::Color color);
  RHX_EXPORT void setTextColor(::rehax::ui::DefaultValue);
  RHX_EXPORT void setFontSize(float size);
  RHX_EXPORT void setFontSize(rehax::ui::DefaultValue);
  RHX_EXPORT void setFontFamilies(std::vector<std::string> fontFamilies);
  RHX_EXPORT void setFontFamilies(rehax::ui::DefaultValue);
  RHX_EXPORT void setItalic(bool italic);
  RHX_EXPORT void setUnderlined(bool underlined);
  RHX_EXPORT void setStrikeThrough(bool strikeThrough);

  RHX_EXPORT virtual void addNativeView(void * child) override;
  RHX_EXPORT virtual void addNativeView(void * child, void * beforeChild) override;
  RHX_EXPORT virtual void addView(ObjectPointer<View> view) override;
  RHX_EXPORT virtual void addView(ObjectPointer<View> view, ObjectPointer<View> beforeView) override;

  RHX_EXPORT virtual void layout() override;
  RHX_EXPORT virtual void setLayout(rehaxUtils::ObjectPointer<ILayout> layout) override;

  ADDITIONAL_TEXT_DEFS
};
