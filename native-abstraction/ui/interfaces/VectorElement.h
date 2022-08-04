
// This shouldn't be instantiated. It's the base for the the different vector elements
class VectorElement : public View {

public:
  RHX_EXPORT static std::string ClassName();

  RHX_EXPORT void setLineWidth(float width);
  RHX_EXPORT void setLineCap(VectorLineCap capsStyle);
  RHX_EXPORT void setLineJoin(VectorLineJoin joinStyle);

  RHX_EXPORT void setFillColor(ui::Color color);
  RHX_EXPORT void setStrokeColor(ui::Color color);

  RHX_EXPORT void setFillGradient(Gradient gradient);
  RHX_EXPORT void setStrokeGradient(Gradient gradient);
  
  RHX_EXPORT void setFilters(Filters filters);

protected:
};