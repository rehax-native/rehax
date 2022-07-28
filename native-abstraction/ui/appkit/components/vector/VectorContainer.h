#pragma once

#include <vector>
#include <iostream>
#include "../../../style.h"
#include "../view/View.h"

namespace rehax::ui::appkit::impl {

template <typename Container>
class VectorContainer : public View<Container> {

public:
  static typename Container::template Ptr<VectorContainer<Container>> Create() {
    auto ptr = new VectorContainer<Container>();
    ptr->createNativeView();
    return ptr;
  }

  static typename Container::template Ptr<VectorContainer<Container>> CreateWithoutCreatingNativeView() {
    auto ptr = new VectorContainer<Container>();
    return ptr;
  }

  virtual std::string viewName() override {
    return "VectorContainer";
  }

  virtual std::string description() override {
    std::ostringstream stringStream;
    stringStream << viewName() << "/CALayer (Appkit) " << this;
    return stringStream.str();
  }

  RHX_EXPORT virtual void createNativeView() override;

  RHX_EXPORT virtual void addNativeView(void * child) override;
  RHX_EXPORT virtual void addNativeView(void * child, void * beforeChild) override;

};

}
