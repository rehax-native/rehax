#include "VectorElement.h"
#include "../../../base.h"
#include <iostream>
#include "./FluxeVectorElement.h"

namespace rehax::ui::fluxe::impl {

#include "../../../shared/components/VectorElement.cc"

void VectorElement::removeFromNativeParent() {
  auto view = static_cast<FluxeVectorElement *>(this->nativeView);
  view->removeFromParent();
}

void VectorElement::setLineWidth(float width) {
  auto view = static_cast<FluxeVectorElement *>(this->nativeView);
  view->lineWidth = width;
  view->setNeedsRerender(true);
}

void VectorElement::setLineCap(VectorLineCap capsStyle) {
  auto view = static_cast<FluxeVectorElement *>(this->nativeView);
  view->lineCap = capsStyle;
  view->setNeedsRerender(true);
}

void VectorElement::setLineJoin(VectorLineJoin joinStyle) {
  auto view = static_cast<FluxeVectorElement *>(this->nativeView);
  view->lineJoin = joinStyle;
  view->setNeedsRerender(true);
}

void VectorElement::setFillColor(ui::Color color) {
  auto view = static_cast<FluxeVectorElement *>(this->nativeView);
  view->fillColor = color;
  view->setNeedsRerender(true);
}

void VectorElement::setStrokeColor(ui::Color color) {
  auto view = static_cast<FluxeVectorElement *>(this->nativeView);
  view->strokeColor = color;
  view->setNeedsRerender(true);
}

void VectorElement::setFillGradient(Gradient gradient) {
  auto view = static_cast<FluxeVectorElement *>(this->nativeView);
  view->fillGradient = gradient;
  view->setNeedsRerender(true);
}

void VectorElement::setStrokeGradient(Gradient gradient) {
  auto view = static_cast<FluxeVectorElement *>(this->nativeView);
  view->strokeGradient = gradient;
  view->setNeedsRerender(true);
}

void VectorElement::setFilters(Filters filters) {
  auto view = static_cast<FluxeVectorElement *>(this->nativeView);
  view->filters = filters;
  view->setNeedsRerender(true);
}


}
