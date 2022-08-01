#import "View.h"
#include "../../../base.h"
#include "../layouts/StackLayout.h"
// #include "Gesture.h"

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "FlippedView.h"
#include "Gesture.h"

namespace rehax::ui::appkit::impl {

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

rehax::ui::appkit::impl::View::View()
:layout(rehaxUtils::Object<StackLayout>::Create())
{}

rehax::ui::appkit::impl::View::~View() {}

void View::createNativeView() {
  NSView * view = [FlippedView new];
  nativeView = (void *) CFBridgingRetain(view);
}

void View::destroyNativeView() {
  if (nativeView != nullptr) {
    CFBridgingRelease(nativeView);
    nativeView = nullptr;
  }
}

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

std::set<View *> View::getChildren() {
  return children;
}

std::string View::instanceClassName() {
  return View::ClassName();
}

std::string View::description() {
  std::ostringstream stringStream;
  stringStream << instanceClassName() << "/NSView (Appkit) " << this;
  return stringStream.str();
}

void View::addNativeView(void * child) {
  NSView * view = (__bridge NSView *) nativeView;
  NSView * childView = (__bridge NSView *) child;
  [childView setFrame:view.bounds];
  childView.translatesAutoresizingMaskIntoConstraints = NO;
  [view addSubview:childView];

  layout->onViewAdded(nativeView, child);
}

void View::addNativeView(void * child, void * beforeChild) {
  NSView * view = (__bridge NSView *) nativeView;
  NSView * childView = (__bridge NSView *) child;
  NSView * beforeChildView = (__bridge NSView *) beforeChild;
  [childView setFrame:view.bounds];
  childView.translatesAutoresizingMaskIntoConstraints = NO;
  [view addSubview:childView positioned:NSWindowBelow relativeTo:beforeChildView];

  layout->onViewAdded(nativeView, child);
}

void View::removeNativeView(void * child) {
  NSView * childView = (__bridge NSView *) child;
  [childView removeFromSuperview];

  layout->onViewRemoved(nativeView, child);
}

void View::removeFromNativeParent() {
  NSView * view = (__bridge NSView *) nativeView;
  [view removeFromSuperview];
    
  auto parent = (View *) this->getParent().get();
  parent->layout->onViewRemoved(parent->nativeView, nativeView);
}

void View::addContainerView(rehaxUtils::ObjectPointer<View> view) {
  view->increaseReferenceCount();
  view->removeContainerFromParent();
  view->parent = getThisPointer();
  children.insert(view.get());
}

void View::addContainerView(rehaxUtils::ObjectPointer<View> view, rehaxUtils::ObjectPointer<View> beforeView) {
  view->increaseReferenceCount();
  view->removeContainerFromParent();
  view->parent = getThisPointer();
  auto it = children.find(beforeView.get());
  children.insert(it, view.get());
}

void View::removeContainerFromParent() {
  if (parent.isValid()) {
    parent->children.erase(this);
    parent = rehaxUtils::WeakObjectPointer<View>();
    decreaseReferenceCount();
  }
}

void View::removeContainerView(rehaxUtils::ObjectPointer<View> view) {
  if (children.find(view.get()) != children.end()) {
    children.erase(view.get());
    view->parent = rehaxUtils::WeakObjectPointer<View>();
    view->decreaseReferenceCount();
  }
}

rehaxUtils::WeakObjectPointer<View> View::getParent() {
  return parent;
}

void View::setWidthFill() {
  NSView * view = (__bridge NSView *) nativeView;
  AppKitNativeViewRemoveAllConstraintsWidthId(view, @"hx_width");

  NSLayoutConstraint * constraint;

  constraint = [NSLayoutConstraint constraintWithItem:[view superview] attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
  constraint.identifier = @"hx_width";
  constraint.priority = 100;
  [[view superview] addConstraint:constraint];

  constraint = [NSLayoutConstraint constraintWithItem:[view superview] attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
  constraint.identifier = @"hx_width";
  constraint.priority = 100;
  [[view superview] addConstraint:constraint];
}

void View::setHeightFill() {
  NSView * view = (__bridge NSView *) nativeView;
  AppKitNativeViewRemoveAllConstraintsWidthId(view, @"hx_height");

  NSLayoutConstraint * constraint;

  constraint = [NSLayoutConstraint constraintWithItem:[view superview] attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
  constraint.identifier = @"hx_height";
  constraint.priority = 100;
  [[view superview] addConstraint:constraint];

  constraint = [NSLayoutConstraint constraintWithItem:[view superview] attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
  constraint.identifier = @"hx_height";
  constraint.priority = 100;
  [[view superview] addConstraint:constraint];
}

void View::setWidthNatural() {
  NSView * view = (__bridge NSView *) nativeView;
  AppKitNativeViewRemoveAllConstraintsWidthId(view, @"hx_width");
}

void View::setHeightNatural() {
  NSView * view = (__bridge NSView *) nativeView;
  AppKitNativeViewRemoveAllConstraintsWidthId(view, @"hx_height");
}

void View::setWidthFixed(float width) {
  NSView * view = (__bridge NSView *) nativeView;
  AppKitNativeViewRemoveAllConstraintsWidthId(view, @"hx_width");

  NSLayoutConstraint * constraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:width];
  constraint.identifier = @"hx_width";
  constraint.priority = 100;
  [view addConstraint:constraint];
}

void View::setHeightFixed(float height) {
  NSView * view = (__bridge NSView *) nativeView;
  AppKitNativeViewRemoveAllConstraintsWidthId(view, @"hx_height");

  NSLayoutConstraint * constraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:height];
  constraint.identifier = @"hx_height";
  constraint.priority = 100;
  [view addConstraint:constraint];
}

void View::setWidthPercentage(float percentage) {
  NSView * view = (__bridge NSView *) nativeView;
  AppKitNativeViewRemoveAllConstraintsWidthId(view, @"hx_width");

  NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:[view superview] attribute:NSLayoutAttributeWidth multiplier:percentage / 100.0 constant:0];
  constraint.identifier = @"hx_width";
  constraint.priority = 100;
  [[view superview] addConstraint:constraint];
}

void View::setHeightPercentage(float percentage) {
  NSView * view = (__bridge NSView *) nativeView;
  AppKitNativeViewRemoveAllConstraintsWidthId(view, @"hx_height");

  NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:[view superview] attribute:NSLayoutAttributeHeight multiplier:percentage / 100.0 constant:0];
  constraint.identifier = @"hx_height";
  constraint.priority = 100;
  [[view superview] addConstraint:constraint];
}

void View::setLayout(rehaxUtils::ObjectPointer<ILayout> layout) {
  this->layout = layout;
  layout->layoutContainer(nativeView);
}

void View::setVerticalPositionNatural(ObjectPointer<View> previousView) {
  NSView * view = (__bridge NSView *) nativeView;
  AppKitNativeViewRemoveAllConstraintsWidthId(view, @"hx_pos_vert");
  auto previousNativeView = previousView.get() != nullptr ? previousView->getNativeView() : nullptr;

  if (view.superview == NULL) {
    return;
  }

  if (previousView == NULL) {
    NSLayoutConstraint * constraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:view.superview attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    constraint.identifier = @"hx_pos_vert";
    constraint.priority = 100;
    [view.superview addConstraint:constraint];
  } else {
    NSView * prev = (__bridge NSView *) previousNativeView;
    NSLayoutConstraint * constraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:prev attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    constraint.identifier = @"hx_pos_vert";
    constraint.priority = 100;
    [view.superview addConstraint:constraint];
  }
}

void View::setHorizontalPositionNatural(ObjectPointer<View> previousView) {
  NSView * view = (__bridge NSView *) nativeView;
  AppKitNativeViewRemoveAllConstraintsWidthId(view, @"hx_pos_horiz");
  auto previousNativeView = previousView.get() != nullptr ? previousView->getNativeView() : nullptr;

  if (view.superview == NULL) {
    return;
  }

  if (previousView == NULL) {
    NSLayoutConstraint * constraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:view.superview attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    constraint.identifier = @"hx_pos_horiz";
    constraint.priority = 100;
    [view.superview addConstraint:constraint];
  } else {
    NSView * prev = (__bridge NSView *) previousNativeView;
    NSLayoutConstraint * constraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:prev attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    constraint.identifier = @"hx_pos_horiz";
    constraint.priority = 100;
    [view.superview addConstraint:constraint];
  }
}

void View::setVerticalPositionFixed(float y) {
  NSView * view = (__bridge NSView *) nativeView;
  AppKitNativeViewRemoveAllConstraintsWidthId(view, @"hx_pos_vert");

  NSLayoutConstraint * constraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:view.superview attribute:NSLayoutAttributeTop multiplier:1.0 constant:y];
  constraint.identifier = @"hx_pos_vert";
  constraint.priority = 100;
  [view.superview addConstraint:constraint];
}

void View::setHorizontalPositionFixed(float x) {
  NSView * view = (__bridge NSView *) nativeView;
  AppKitNativeViewRemoveAllConstraintsWidthId(view, @"hx_pos_horiz");

  NSLayoutConstraint * constraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:view.superview attribute:NSLayoutAttributeLeft multiplier:1.0 constant:x];
  constraint.identifier = @"hx_pos_horiz";
  constraint.priority = 100;
  [view.superview addConstraint:constraint];
}

// void View::setBackgroundColor(rehax::ui::Color color)
// {
//   NSView * view = (__bridge NSView *) nativeView;
//   // [view setWantsLayer:true];
//   // [view setLayer:[CALayer layer]];
//   NSColor *col = [NSColor colorWithDeviceRed:color.r/255.0 green:color.g/255.0 blue:color.b/255.0 alpha:color.a];
//   [view.layer setBackgroundColor:[col CGColor]];
// }

void View::setOpacity(float opacity) {
  NSView * view = (__bridge NSView *) nativeView;
  [view setAlphaValue:opacity];
}

void View::addGesture(ObjectPointer<Gesture> gesture) {
  NSView * view = (__bridge NSView *) nativeView;
  NSGestureRecognizer * rec = (__bridge NSGestureRecognizer *) gesture->native;

  gesture->increaseReferenceCount();
  gestures.insert(gesture.get());

  [view addGestureRecognizer:rec];
}

void View::removeGesture(ObjectPointer<Gesture> gesture) {
  NSView * view = (__bridge NSView *) nativeView;
  NSGestureRecognizer * rec = (__bridge NSGestureRecognizer *) gesture->native;
  [view removeGestureRecognizer:rec];
    
  auto it = gestures.find(gesture.get());
  if (it != gestures.end()) {
    gestures.erase(it);
    gesture->decreaseReferenceCount();
  }
}

}
