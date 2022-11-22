
std::string MouseHandler::ClassName() {
  return "MouseHandler";
}

std::string MouseHandler::instanceClassName() {
  return MouseHandler::ClassName();
}

ObjectPointer<MouseHandler> MouseHandler::Create() {
  auto ptr = rehaxUtils::Object<MouseHandler>::Create();
  return ptr;
}

void MouseHandler::setup(std::function<void(rehax::ui::MouseEvent&)> mouseHandler) {
  this->handler = mouseHandler;
}
