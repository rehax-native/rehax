
ObjectPointer<Toggle> Toggle::Create() {
  auto ptr = Object<Toggle>::Create();
  ptr->createNativeView();
  return ptr;
}

ObjectPointer<Toggle> Toggle::CreateWithoutCreatingNativeView() {
  auto ptr = Object<Toggle>::Create();
  return ptr;
}

std::string Toggle::ClassName() {
  return "Toggle";
}

std::string Toggle::instanceClassName() {
  return Toggle::ClassName();
}

void Toggle::setOnValueChange(rehax::ui::DefaultValue) {
  setOnValueChange([] (bool) {});
}

void Toggle::setValue(rehax::ui::DefaultValue) {
  setValue(false);
}
