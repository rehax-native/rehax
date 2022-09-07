
ObjectPointer<TextInput> TextInput::Create() {
  auto ptr = Object<TextInput>::Create();
  ptr->createNativeView();
  return ptr;
}

ObjectPointer<TextInput> TextInput::CreateWithoutCreatingNativeView() {
  auto ptr = Object<TextInput>::Create();
  return ptr;
}

std::string TextInput::ClassName() {
  return "TextInput";
}

std::string TextInput::instanceClassName() {
  return TextInput::ClassName();
}

void TextInput::setValue(rehax::ui::DefaultValue) {
  setValue("");
}

void TextInput::setOnValueChange(rehax::ui::DefaultValue) {
  setOnValueChange([] (std::string) {});
}

void TextInput::setOnFocus(rehax::ui::DefaultValue) {
  setOnFocus([] () {});
}

void TextInput::setOnBlur(rehax::ui::DefaultValue) {
  setOnBlur([] () {});
}

void TextInput::setOnSubmit(rehax::ui::DefaultValue) {
  setOnSubmit([] () {});
}
