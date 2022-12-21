
std::string KeyHandler::ClassName() {
  return "KeyHandler";
}

std::string KeyHandler::instanceClassName() {
  return KeyHandler::ClassName();
}

ObjectPointer<KeyHandler> KeyHandler::Create() {
  auto ptr = rehaxUtils::Object<KeyHandler>::Create();
  return ptr;
}

void KeyHandler::setup(std::function<void(rehax::ui::KeyEvent&)> keyHandler) {
  this->handler = keyHandler;
}
