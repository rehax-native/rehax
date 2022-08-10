
ObjectPointer<View> View::Create() {
  auto ptr = rehaxUtils::Object<View>::Create();
  ptr->createNativeView();
  return ptr;
}

ObjectPointer<View> View::CreateWithoutCreatingNativeView() {
  auto ptr = rehaxUtils::Object<View>::Create();
  return ptr;
}

std::string View::ClassName() {
  return "View";
}

View::View()
:_layout(rehaxUtils::Object<StackLayout>::Create())
{}

View::~View() {}

void View::setNativeViewRaw(void * view) {
  nativeView = view;
}

void * View::getNativeView() {
  return nativeView;
}

void View::addView(ObjectPointer<View> view) {
  this->addContainerView(view);
  addNativeView(view->nativeView);
  view->setWidth(view->width);
  view->setHeight(view->height);
}

void View::addView(ObjectPointer<View> view, ObjectPointer<View> beforeView) {
  if (!beforeView.hasPointer()) {
    addView(view);
    return;
  }
  this->addContainerView(view, beforeView);
  addNativeView(view->nativeView, beforeView->nativeView);
  view->setWidth(view->width);
  view->setHeight(view->height);
}

void View::removeView(ObjectPointer<View> view) {
  this->removeContainerView(view);
  removeNativeView(view->nativeView);
}

void View::removeFromParent() {
  this->removeContainerFromParent();
  removeFromNativeParent();
}

std::vector<View *> View::getChildren() {
  return children;
}

std::string View::instanceClassName() {
  return View::ClassName();
}

void View::addContainerView(rehaxUtils::ObjectPointer<View> view) {
  view->increaseReferenceCount();
  view->removeContainerFromParent();
  view->parent = getThisPointer();
  children.push_back(view.get());
  // view->setWidth(view->width);
  // view->setHeight(view->height);
}

void View::addContainerView(rehaxUtils::ObjectPointer<View> view, rehaxUtils::ObjectPointer<View> beforeView) {
  view->increaseReferenceCount();
  view->removeContainerFromParent();
  view->parent = getThisPointer();
  auto it = std::find(children.begin(), children.end(), beforeView.get());
  children.insert(it, view.get());
  // view->setWidth(view->width);
  // view->setHeight(view->height);
}

void View::removeContainerFromParent() {
  if (parent.isValid()) {
    auto it = std::find(parent->children.begin(), parent->children.end(), this);
    parent->children.erase(it);
    parent = rehaxUtils::WeakObjectPointer<View>();
    decreaseReferenceCount();
  }
}

void View::removeContainerView(rehaxUtils::ObjectPointer<View> view) {
  auto it = std::find(children.begin(), children.end(), view.get());
  if (it != children.end()) {
    children.erase(it);
    view->parent = rehaxUtils::WeakObjectPointer<View>();
    view->decreaseReferenceCount();
  }
}

rehaxUtils::WeakObjectPointer<View> View::getParent() {
  return parent;
}

rehaxUtils::WeakObjectPointer<View> View::getFirstChild() {
  if (children.size() > 0) {
    return rehaxUtils::WeakObjectPointer<View>(children[0]);
  }
  return rehaxUtils::WeakObjectPointer<View>();
}

rehaxUtils::WeakObjectPointer<View> View::getNextSibling() {
  auto parent = getParent();
  if (!parent.isValid()) {
    return rehaxUtils::WeakObjectPointer<View>();
  }
  auto children = parent->getChildren();
  auto it = std::find(children.begin(), children.end(), this);
  it++;
  if (it == children.end()) {
    return rehaxUtils::WeakObjectPointer<View>();
  }
  auto nextSibling = *it;
  return nextSibling;
}

void View::setLayout(rehaxUtils::ObjectPointer<ILayout> layout) {
  if (_layout.hasPointer()) {
    _layout->removeLayout(this);
  }
  this->_layout = layout;
  layout->containerView = getThisPointer();
  _layout->layoutContainer(nativeView);
}

void View::layout() {
  _layout->layoutContainer(nativeView);
}

void View::setWidth(Length width) {
  this->width = width;
  if (auto * p = std::get_if<LengthTypes::Natural>(&width)) {
    setWidthNatural();
  } else if (auto * p = std::get_if<LengthTypes::Fixed>(&width)) {
    setWidthFixed(p->length);
  } else if (auto * p = std::get_if<LengthTypes::Fill>(&width)) {
    setWidthFill();
  } else if (auto * p = std::get_if<LengthTypes::Percentage>(&width)) {
    setWidthPercentage(p->percent);
  }
}

void View::setHeight(Length height) {
  this->height = height;
  if (auto * p = std::get_if<LengthTypes::Natural>(&height)) {
    setHeightNatural();
  } else if (auto * p = std::get_if<LengthTypes::Fixed>(&height)) {
    setHeightFixed(p->length);
  } else if (auto * p = std::get_if<LengthTypes::Fill>(&height)) {
    setHeightFill();
  } else if (auto * p = std::get_if<LengthTypes::Percentage>(&height)) {
    setHeightPercentage(p->percent);
  }
}

void View::setLayout(rehax::ui::DefaultValue) {
  setLayout(rehaxUtils::Object<StackLayout>::Create());
}

void View::setBackgroundColor(rehax::ui::DefaultValue) {
  setBackgroundColor(rehax::ui::Color::RGBA(0, 0, 0, 0));
}
