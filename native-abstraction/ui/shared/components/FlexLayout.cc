
ObjectPointer<FlexLayout> FlexLayout::Create() {
  auto ptr = Object<FlexLayout>::Create();
  return ptr;
}

std::string FlexLayout::ClassName() {
  return "FlexLayout";
}

std::string FlexLayout::instanceClassName() {
  return FlexLayout::ClassName();
}

FlexLayout::FlexLayout() {}

FlexLayout::~FlexLayout() {
  removeLayout(nullptr);
}

void FlexLayout::setOptions(FlexLayoutOptions flexLayoutOptions) {
  isHorizontal = flexLayoutOptions.direction == FlexLayoutDirection::Column || flexLayoutOptions.direction == FlexLayoutDirection::ColumnReverse;
  isReverse = flexLayoutOptions.direction == FlexLayoutDirection::RowReverse || flexLayoutOptions.direction == FlexLayoutDirection::ColumnReverse;
  justifyContent = flexLayoutOptions.justifyContent;
  alignItems = flexLayoutOptions.alignItems;
}