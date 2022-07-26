#pragma once

#include <memory>
#include <set>
#include "../lib/common.h"
#include <iostream>

namespace rehax {
namespace ui {

class RawPtr {

public:
  template <typename View>
  using Ptr = View *;

  void addContainerView(RawPtr * view) {
    view->removeContainerFromParent();
    view->parent = this;
    children.insert(view);
  }

  void addContainerView(RawPtr * view, RawPtr * beforeView) {
    view->removeContainerFromParent();
    view->parent = this;
    auto it = children.find(beforeView);
    children.insert(it, view);
  }

  void removeContainerFromParent() {
    if (parent != nullptr) {
      parent->children.erase(this);
      parent = nullptr;
    }
  }

  void removeContainerView(RawPtr * view) {
    if (children.find(view) != children.end()) {
      children.erase(view);
      view->parent = nullptr;
    }
  }

  RawPtr * getParent() {
    return parent;
  }

  std::set<RawPtr *> children;
  RawPtr * parent = nullptr;
};

}
}
