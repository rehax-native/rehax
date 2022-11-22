
class MouseHandler : public rehaxUtils::Object<MouseHandler> {

public:
  RHX_EXPORT static std::string ClassName();
  RHX_EXPORT virtual std::string instanceClassName();
  RHX_EXPORT virtual std::string description();
  RHX_EXPORT static ObjectPointer<MouseHandler> Create();
  RHX_EXPORT ~MouseHandler();

  RHX_EXPORT void setup(std::function<void(rehax::ui::MouseEvent&)> mouseHandler);

  std::function<void(MouseEvent&)> handler;
};
