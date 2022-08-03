
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