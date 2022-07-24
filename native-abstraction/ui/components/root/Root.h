#pragma once

#include "../view/View.h"
#include <functional>

namespace rehax {

class Root : public View
{
public:
  RHX_EXPORT static std::shared_ptr<Root> Create();
  RHX_EXPORT static std::shared_ptr<Root> CreateWithExistingPlatformView(void * platformView);
  RHX_EXPORT Root();

  RHX_EXPORT virtual void createNativeView() override;
  RHX_EXPORT virtual void addView(std::shared_ptr<View> child) override;
  RHX_EXPORT void initialize(std::function<void(void)> onReady);

};

}
