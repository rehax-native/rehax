
std::string Gesture::ClassName() {
  return "Gesture";
}

std::string Gesture::instanceClassName() {
  return Gesture::ClassName();
}

ObjectPointer<Gesture> Gesture::Create() {
  auto ptr = rehaxUtils::Object<Gesture>::Create();
  return ptr;
}
