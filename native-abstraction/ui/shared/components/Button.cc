
ObjectPointer<Button> Button::Create() {
  auto ptr = Object<Button>::Create();
  ptr->createNativeView();
  return ptr;
}

ObjectPointer<Button> Button::CreateWithoutCreatingNativeView() {
  auto ptr = Object<Button>::Create();
  return ptr;
}

std::string Button::ClassName() {
  return "Button";
}

std::string Button::instanceClassName() {
  return Button::ClassName();
}
