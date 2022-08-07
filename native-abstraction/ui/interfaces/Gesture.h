
class Gesture : public rehaxUtils::Object<Gesture> {

public:
  RHX_EXPORT static std::string ClassName();
  RHX_EXPORT virtual std::string instanceClassName();
  RHX_EXPORT virtual std::string description();
  RHX_EXPORT static ObjectPointer<Gesture> Create();
  RHX_EXPORT ~Gesture();

  RHX_EXPORT void setup(std::function<void(void)> action, std::function<void(float, float)> onMouseDown, std::function<void(float, float)> onMouseUp, std::function<void(float, float)> onMouseMove);
  RHX_EXPORT void setState(GestureState state);

  void * native = nullptr;
};
