
ObjectPointer<Select> Select::Create() {
  auto ptr = Object<Select>::Create();
  ptr->createNativeView();
  return ptr;
}

ObjectPointer<Select> Select::CreateWithoutCreatingNativeView() {
  auto ptr = Object<Select>::Create();
  return ptr;
}

std::string Select::ClassName() {
  return "Select";
}

std::string Select::instanceClassName() {
  return Select::ClassName();
}

void Select::setOptions(rehax::ui::DefaultValue) {
  setOptions(std::vector<SelectOption> {});
}

void Select::setOnValueChange(rehax::ui::DefaultValue) {
  setOnValueChange([] (SelectOption) {});
}

void Select::setValue(rehax::ui::DefaultValue) {
  setValue("");
}
