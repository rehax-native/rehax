
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