
ObjectPointer<VectorContainer> VectorContainer::Create() {
  auto ptr = Object<VectorContainer>::Create();
  ptr->createNativeView();
  return ptr;
}

ObjectPointer<VectorContainer> VectorContainer::CreateWithoutCreatingNativeView() {
  auto ptr = Object<VectorContainer>::Create();
  return ptr;
}

std::string VectorContainer::ClassName() {
  return "VectorContainer";
}

std::string VectorContainer::instanceClassName() {
  return VectorContainer::ClassName();
}
