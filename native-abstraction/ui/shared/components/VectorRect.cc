
ObjectPointer<VectorRect> VectorRect::Create() {
  auto ptr = Object<VectorRect>::Create();
  ptr->createNativeView();
  return ptr;
}

ObjectPointer<VectorRect> VectorRect::CreateWithoutCreatingNativeView() {
  auto ptr = Object<VectorRect>::Create();
  return ptr;
}

std::string VectorRect::ClassName() {
  return "VectorRect";
}

std::string VectorRect::instanceClassName() {
  return VectorRect::ClassName();
}
