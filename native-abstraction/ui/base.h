#pragma once

#include <memory>
#include <set>
#include "../lib/common.h"

namespace rehax {

namespace ui {

class RawPtr {
public:
  template <typename View>
  using Ptr = View *;

  void addContainerView(RawPtr * view)
  {
    view->removeContainerFromParent();
    view->parent = this;
    children.insert(view);
  }

  void removeContainerFromParent()
  {
    if (parent != nullptr) {
      parent->children.erase(this);
      parent = nullptr;
    }
  }

  std::set<RawPtr *> children;
  RawPtr * parent = nullptr;
};

}

}
