
class VectorRect : public VectorElement {

public:

  RHX_EXPORT static ObjectPointer<VectorRect> Create();
  RHX_EXPORT static ObjectPointer<VectorRect> CreateWithoutCreatingNativeView();
  RHX_EXPORT static std::string ClassName();

  RHX_EXPORT virtual std::string instanceClassName() override;
  RHX_EXPORT virtual std::string description() override;

  RHX_EXPORT virtual void createNativeView() override;

  RHX_EXPORT void setSize(rehax::ui::Size size);

};
