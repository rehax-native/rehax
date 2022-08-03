
class VectorPath : public VectorElement {

public:
  RHX_EXPORT static ObjectPointer<VectorPath> Create();
  RHX_EXPORT static ObjectPointer<VectorPath> CreateWithoutCreatingNativeView();
  RHX_EXPORT static std::string ClassName();

  RHX_EXPORT virtual std::string instanceClassName() override;
  RHX_EXPORT virtual std::string description() override;

  RHX_EXPORT virtual void createNativeView() override;

  RHX_EXPORT void beginPath();
  RHX_EXPORT void pathHorizontalTo(float x);
  RHX_EXPORT void pathVerticalTo(float y);
  RHX_EXPORT void pathMoveTo(float x, float y);
  RHX_EXPORT void pathMoveBy(float x, float y);
  RHX_EXPORT void pathLineTo(float x, float y);
  RHX_EXPORT void pathArc(float rx, float ry, float xAxisRotation, int largeArcFlag, int sweepFlag, float x, float y);
  RHX_EXPORT void pathCubicBezier(float x1, float y1, float x2, float y2, float x, float y);
  RHX_EXPORT void pathQuadraticBezier(float x1, float y1, float x, float y);
  RHX_EXPORT void pathClose();
  RHX_EXPORT void endPath();

};
