
ObjectPointer<StackLayout> StackLayout::Create() {
  auto ptr = Object<StackLayout>::Create();
  return ptr;
}

std::string StackLayout::ClassName() {
  return "StackLayout";
}

std::string StackLayout::instanceClassName() {
  return StackLayout::ClassName();
}

StackLayout::StackLayout()
:isHorizontal(false), spacing(0.0)
{}

StackLayout::StackLayout(StackLayoutOptions options)
:isHorizontal(options.direction == StackLayoutDirection::Horizontal), spacing(options.spacing)
{}

void StackLayout::setOptions(StackLayoutOptions options) {
  isHorizontal = options.direction == StackLayoutDirection::Horizontal;
    spacing = options.spacing;
}

StackLayout::~StackLayout() {
  removeLayout(nullptr);
}
