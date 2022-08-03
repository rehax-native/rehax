
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
}

void View::addView(ObjectPointer<View> view, ObjectPointer<View> beforeView) {
  this->addContainerView(view, beforeView);
  addNativeView(view->nativeView, beforeView->nativeView);
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
}

void View::addContainerView(rehaxUtils::ObjectPointer<View> view, rehaxUtils::ObjectPointer<View> beforeView) {
  view->increaseReferenceCount();
  view->removeContainerFromParent();
  view->parent = getThisPointer();
  auto it = std::find(children.begin(), children.end(), beforeView.get());
  children.insert(it, view.get());
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

void View::setLayout(rehaxUtils::ObjectPointer<ILayout> layout) {
  if (_layout.hasPointer()) {
    _layout->removeLayout(this);
  }
  this->_layout = layout;
  _layout->layoutContainer(nativeView);
}

void View::layout() {
  _layout->layoutContainer(nativeView);
}
