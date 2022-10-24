#import "View.h"
#include "../../../base.h"
#include "../layouts/StackLayout.h"
#include "Gesture.h"
#include "KeyHandler.h"

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "BaseView.h"

namespace rehax::ui::appkit::impl {

#include "../../../shared/components/View.cc"

void View::createNativeView() {
  NSView * view = [BaseView new];
  // static int idCounter = 0;
  // view.accessibilityIdentifier = [NSString stringWithFormat:@"View %d", idCounter++];
  nativeView = (void *) CFBridgingRetain(view);
}

void View::destroyNativeView() {
  if (nativeView != nullptr) {
    CFBridgingRelease(nativeView);
    nativeView = nullptr;
  }
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
}

void View::addNativeView(void * child, void * beforeChild) {
  NSView * view = (__bridge NSView *) nativeView;
  NSView * childView = (__bridge NSView *) child;
  NSView * beforeChildView = (__bridge NSView *) beforeChild;
  [childView setFrame:view.bounds];
  childView.translatesAutoresizingMaskIntoConstraints = NO;
  [view addSubview:childView positioned:NSWindowBelow relativeTo:beforeChildView];
}

void View::removeNativeView(void * child) {
  NSView * childView = (__bridge NSView *) child;
  [childView removeFromSuperview];
}

void View::removeFromNativeParent() {
  NSView * view = (__bridge NSView *) nativeView;
  [view removeFromSuperview];
    
  auto parent = (View *) this->getParent().get();
}

void View::setWidthFill() {
  NSView * view = (__bridge NSView *) nativeView;
  AppKitNativeViewRemoveAllConstraintsWidthId(view, @"rhx_width");

  if ([view superview] == nullptr) {
    return;
  }

  NSLayoutConstraint * constraint;

  constraint = [NSLayoutConstraint constraintWithItem:[view superview] attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
  constraint.identifier = @"rhx_width";
  // constraint.priority = 1000;
  [[view superview] addConstraint:constraint];

  constraint = [NSLayoutConstraint constraintWithItem:[view superview] attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
  constraint.identifier = @"rhx_width";
  // constraint.priority = 1000;
  [[view superview] addConstraint:constraint];
}

void View::setHeightFill() {
  NSView * view = (__bridge NSView *) nativeView;
  AppKitNativeViewRemoveAllConstraintsWidthId(view, @"rhx_height");

  if ([view superview] == nullptr) {
    return;
  }

  NSLayoutConstraint * constraint;

  constraint = [NSLayoutConstraint constraintWithItem:[view superview] attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
  constraint.identifier = @"rhx_height";
  // constraint.priority = 1000;
  [[view superview] addConstraint:constraint];

  constraint = [NSLayoutConstraint constraintWithItem:[view superview] attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
  constraint.identifier = @"rhx_height";
  // constraint.priority = 1000;
  [[view superview] addConstraint:constraint];
}

void View::setWidthNatural() {
  NSView * view = (__bridge NSView *) nativeView;
  AppKitNativeViewRemoveAllConstraintsWidthId(view, @"rhx_width");
}

void View::setHeightNatural() {
  NSView * view = (__bridge NSView *) nativeView;
  AppKitNativeViewRemoveAllConstraintsWidthId(view, @"rhx_height");
}

void View::setWidthFixed(float width) {
  NSView * view = (__bridge NSView *) nativeView;
  AppKitNativeViewRemoveAllConstraintsWidthId(view, @"rhx_width");

  NSLayoutConstraint * constraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:width];
  constraint.identifier = @"rhx_width";
  // constraint.priority = 1000;
  [view addConstraint:constraint];
}

void View::setHeightFixed(float height) {
  NSView * view = (__bridge NSView *) nativeView;
  AppKitNativeViewRemoveAllConstraintsWidthId(view, @"rhx_height");

  NSLayoutConstraint * constraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:height];
  constraint.identifier = @"rhx_height";
  // constraint.priority = 1000;
  [view addConstraint:constraint];
}

void View::setWidthPercentage(float percentage) {
  NSView * view = (__bridge NSView *) nativeView;
  AppKitNativeViewRemoveAllConstraintsWidthId(view, @"rhx_width");

  if ([view superview] == nullptr) {
    return;
  }

  NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:[view superview] attribute:NSLayoutAttributeWidth multiplier:percentage / 100.0 constant:0];
  constraint.identifier = @"rhx_width";
  // constraint.priority = 1000;
  [[view superview] addConstraint:constraint];
}

void View::setHeightPercentage(float percentage) {
  NSView * view = (__bridge NSView *) nativeView;
  AppKitNativeViewRemoveAllConstraintsWidthId(view, @"rhx_height");

  if ([view superview] == nullptr) {
    return;
  }

  NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:[view superview] attribute:NSLayoutAttributeHeight multiplier:percentage / 100.0 constant:0];
  constraint.identifier = @"rhx_height";
  // constraint.priority = 1000;
  [[view superview] addConstraint:constraint];
}

void View::setVerticalPositionNatural(ObjectPointer<View> previousView) {
  NSView * view = (__bridge NSView *) nativeView;
  AppKitNativeViewRemoveAllConstraintsWidthId(view, @"rhx_pos_vert");
  auto previousNativeView = previousView.get() != nullptr ? previousView->getNativeView() : nullptr;

  if ([view superview] == nullptr) {
    return;
  }

  if (previousView == NULL) {
    NSLayoutConstraint * constraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:view.superview attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    constraint.identifier = @"rhx_pos_vert";
    // constraint.priority = 1000;
    [view.superview addConstraint:constraint];
  } else {
    NSView * prev = (__bridge NSView *) previousNativeView;
    NSLayoutConstraint * constraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:prev attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    constraint.identifier = @"rhx_pos_vert";
    // constraint.priority = 1000;
    [view.superview addConstraint:constraint];
  }
}

void View::setHorizontalPositionNatural(ObjectPointer<View> previousView) {
  NSView * view = (__bridge NSView *) nativeView;
  AppKitNativeViewRemoveAllConstraintsWidthId(view, @"rhx_pos_horiz");
  auto previousNativeView = previousView.get() != nullptr ? previousView->getNativeView() : nullptr;

  if ([view superview] == nullptr) {
    return;
  }

  if (previousView == NULL) {
    NSLayoutConstraint * constraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:view.superview attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    constraint.identifier = @"rhx_pos_horiz";
    // constraint.priority = 1000;
    [view.superview addConstraint:constraint];
  } else {
    NSView * prev = (__bridge NSView *) previousNativeView;
    NSLayoutConstraint * constraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:prev attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    constraint.identifier = @"rhx_pos_horiz";
    // constraint.priority = 1000;
    [view.superview addConstraint:constraint];
  }
}

void View::setVerticalPositionFixed(float y) {
  NSView * view = (__bridge NSView *) nativeView;
  AppKitNativeViewRemoveAllConstraintsWidthId(view, @"rhx_pos_vert");

  if ([view superview] == nullptr) {
    return;
  }

  NSLayoutConstraint * constraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:view.superview attribute:NSLayoutAttributeTop multiplier:1.0 constant:y];
  constraint.identifier = @"rhx_pos_vert";
  // constraint.priority = 1000;
  [view.superview addConstraint:constraint];
}

void View::setHorizontalPositionFixed(float x) {
  NSView * view = (__bridge NSView *) nativeView;
  AppKitNativeViewRemoveAllConstraintsWidthId(view, @"rhx_pos_horiz");

  if ([view superview] == nullptr) {
    return;
  }

  NSLayoutConstraint * constraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:view.superview attribute:NSLayoutAttributeLeft multiplier:1.0 constant:x];
  constraint.identifier = @"rhx_pos_horiz";
  // constraint.priority = 1000;
  [view.superview addConstraint:constraint];
}

void View::setBackgroundColor(rehax::ui::Color color) {
  NSView * view = (__bridge NSView *) nativeView;
  [view setWantsLayer:true];
  NSColor *col = [NSColor colorWithDeviceRed:color.r green:color.g blue:color.b alpha:color.a];
  [view.layer setBackgroundColor:[col CGColor]];
}

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

void View::addKeyHandler(ObjectPointer<KeyHandler> keyHandler) {
  BaseView * view = (__bridge BaseView *) nativeView;
  view->keyHandlers.push_back(keyHandler->handler);
}

void View::removeKeyHandler(ObjectPointer<KeyHandler> keyHandler) {
//  BaseView * view = (__bridge BaseView *) nativeView;
//  view->keyDownHandlers.push_back(keyHandler.handler);
}

}
