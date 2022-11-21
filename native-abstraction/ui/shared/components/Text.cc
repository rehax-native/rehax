
ObjectPointer<Text> Text::Create() {
  auto ptr = Object<Text>::Create();
  ptr->createNativeView();
  return ptr;
}

ObjectPointer<Text> Text::CreateWithoutCreatingNativeView() {
  auto ptr = Object<Text>::Create();
  return ptr;
}

std::string Text::ClassName() {
  return "Text";
}

std::string Text::instanceClassName() {
  return Text::ClassName();
}

void Text::setText(rehax::ui::DefaultValue) {
  setText("");
}

void Text::setFontSize(rehax::ui::DefaultValue) {
  setFontSize(12);
}

void Text::setFontFamilies(rehax::ui::DefaultValue) {
  setFontFamilies(std::vector<std::string> {});
}
