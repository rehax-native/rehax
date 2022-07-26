#pragma once

#include <memory>
#include <set>
#include "../lib/common.h"
#include <iostream>
#include <rehaxUtils/pointers/Object.h>

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

class RefCountedPointer : public rehaxUtils::Object<RefCountedPointer> {

public:
  template <typename View>
  using Ptr = rehaxUtils::ObjectPointer<View>;

  void addContainerView(rehaxUtils::ObjectPointer<RefCountedPointer> view) {
    view->increaseReferenceCount();
    view->removeContainerFromParent();
    view->parent = getThisPointer();
    children.insert(view.get());
  }

  void addContainerView(rehaxUtils::ObjectPointer<RefCountedPointer> view, rehaxUtils::ObjectPointer<RefCountedPointer> beforeView) {
    view->increaseReferenceCount();
    view->removeContainerFromParent();
    view->parent = getThisPointer();
    auto it = children.find(beforeView.get());
    children.insert(it, view.get());
  }

  void removeContainerFromParent() {
    if (parent.isValid()) {
      parent->children.erase(this);
      parent = rehaxUtils::WeakObjectPointer<RefCountedPointer>();
      decreaseReferenceCount();
    }
  }

  void removeContainerView(rehaxUtils::ObjectPointer<RefCountedPointer> view) {
    if (children.find(view.get()) != children.end()) {
      children.erase(view.get());
      view->parent = rehaxUtils::WeakObjectPointer<RefCountedPointer>();
      view->decreaseReferenceCount();
    }
  }

  rehaxUtils::WeakObjectPointer<RefCountedPointer> getParent() {
    return parent;
  }

  std::set<RefCountedPointer *> children;
  rehaxUtils::WeakObjectPointer<RefCountedPointer> parent = rehaxUtils::WeakObjectPointer<RefCountedPointer>();
};

}
}
