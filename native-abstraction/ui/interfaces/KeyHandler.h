
class KeyHandler : public rehaxUtils::Object<KeyHandler> {

public:
  RHX_EXPORT static std::string ClassName();
  RHX_EXPORT virtual std::string instanceClassName();
  RHX_EXPORT virtual std::string description();
  RHX_EXPORT static ObjectPointer<KeyHandler> Create();
  RHX_EXPORT ~KeyHandler();

  RHX_EXPORT void setup(std::function<void(rehax::ui::KeyEvent&)> keyHandler);

  std::function<void(KeyEvent&)> handler;
};
