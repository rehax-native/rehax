
ObjectPointer<VectorPath> VectorPath::Create() {
  auto ptr = Object<VectorPath>::Create();
  ptr->createNativeView();
  return ptr;
}

ObjectPointer<VectorPath> VectorPath::CreateWithoutCreatingNativeView() {
  auto ptr = Object<VectorPath>::Create();
  return ptr;
}

std::string VectorPath::ClassName() {
  return "VectorPath";
}

std::string VectorPath::instanceClassName() {
  return VectorPath::ClassName();
}
