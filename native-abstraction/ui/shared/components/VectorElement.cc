
std::string VectorElement::ClassName() {
  return "VectorElement";
}

void VectorElement::setLineWidth(rehax::ui::DefaultValue) {
  setLineWidth(0);
}

void VectorElement::setLineCap(rehax::ui::DefaultValue) {
  setLineCap(VectorLineCap::Butt);
}

void VectorElement::setLineJoin(rehax::ui::DefaultValue) {
  setLineJoin(VectorLineJoin::Miter);
}

void VectorElement::setFillColor(rehax::ui::DefaultValue) {
  setFillColor(rehax::ui::Color::RGBA(0,0,0,0));
}

void VectorElement::setStrokeColor(rehax::ui::DefaultValue) {
  setStrokeColor(rehax::ui::Color::RGBA(0,0,0,0));
}

void VectorElement::setFillGradient(rehax::ui::DefaultValue) {
  setFillGradient(Gradient{});
}

void VectorElement::setStrokeGradient(rehax::ui::DefaultValue) {
  setStrokeGradient(Gradient{});
}

void VectorElement::setFilters(rehax::ui::DefaultValue) {
  setFilters(Filters{});
}
