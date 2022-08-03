#include "VectorContainer.h"
#include "../../../base.h"
#include <iostream>

namespace rehax::ui::fluxe::impl {

//class FluxeVectorContainer : public fluxe::View {
//public:
//  // void measureLayout(LayoutConstraint constraints, PossibleLayoutSize parentSize) override;
//  void build(ObjectPointer<ViewBuilder> builder) override;
//
//};
//
//// void FluxeVectorContainer::measureLayout(LayoutConstraint constraints, PossibleLayoutSize parentSize) {
//
//// }
//
//void FluxeVectorContainer::build(ObjectPointer<ViewBuilder> builder) {
//
//}

#include "../../../shared/components/VectorContainer.cc"

std::string VectorContainer::description() {
  std::ostringstream stringStream;
  stringStream << instanceClassName() << "/fluxe " << this;
  return stringStream.str();
}

void VectorContainer::createNativeView() {
  View::createNativeView();
}

void VectorContainer::addNativeView(void * child) {
  View::addNativeView(child);
}

void VectorContainer::addNativeView(void * child, void * beforeView) {
  View::addNativeView(child, beforeView);
}

}
