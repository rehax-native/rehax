#pragma once

#include <vector>
#include <iostream>
#include "../../../style.h"
#include "../view/View.h"

namespace rehax::ui::appkit::impl {

class VectorContainer : public View {

public:
  RHX_EXPORT static ObjectPointer<VectorContainer> Create();
  RHX_EXPORT static ObjectPointer<VectorContainer> CreateWithoutCreatingNativeView();
  RHX_EXPORT static std::string ClassName();

  RHX_EXPORT virtual std::string instanceClassName() override;
  RHX_EXPORT virtual std::string description() override;

  RHX_EXPORT virtual void createNativeView() override;

  RHX_EXPORT virtual void addNativeView(void * child) override;
  RHX_EXPORT virtual void addNativeView(void * child, void * beforeChild) override;

};

}
