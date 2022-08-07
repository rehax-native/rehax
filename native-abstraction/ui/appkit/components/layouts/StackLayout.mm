#include "StackLayout.h"
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

using namespace rehax::ui::appkit::impl;

#include "../../../shared/components/StackLayout.cc"

std::string StackLayout::description() {
  std::ostringstream stringStream;
  stringStream << instanceClassName() << "/NSLayoutConstraints (Appkit) " << this;
  return stringStream.str();
}

void StackLayout::layoutContainer(void * container) {
  const NSView * view = (__bridge NSView *) container;
  NSView * prevView = NULL;

  // NSLog(@"### Stack layout %@", view);
  
  removeLayout(container);
  
  NSMutableArray * constraintsArray = [NSMutableArray array];
  nativeInfo = (void*) CFBridgingRetain(constraintsArray);

  const auto minProp = isHorizontal ? NSLayoutAttributeLeft : NSLayoutAttributeTop;
  const auto maxProp = isHorizontal ? NSLayoutAttributeRight : NSLayoutAttributeBottom;

  const auto crossPropMin = isHorizontal ? NSLayoutAttributeTop : NSLayoutAttributeLeft;
  const auto crossPropMax = isHorizontal ? NSLayoutAttributeBottom : NSLayoutAttributeRight;
  const auto crossPropSize = isHorizontal ? NSLayoutAttributeHeight : NSLayoutAttributeWidth;
  
  NSLayoutConstraint * constraint;

  for (int i = 0; i < view.subviews.count; i++) {
    NSView * subView = view.subviews[i];

    constraint = [NSLayoutConstraint constraintWithItem:view attribute:crossPropMin relatedBy:NSLayoutRelationEqual toItem:subView attribute:crossPropMin multiplier:1.0 constant:-spacing];
    constraint.identifier = @"Stack cross pos min";
    // constraint.priority = 900;
    [view addConstraint:constraint];
    [constraintsArray addObject:constraint];
    // NSLog(@"%d left to parent left %d", i, crossPropMin == NSLayoutAttributeLeft);

    if (prevView != NULL) {
      constraint = [NSLayoutConstraint constraintWithItem:prevView attribute:maxProp relatedBy:NSLayoutRelationEqual toItem:subView attribute:minProp multiplier:1.0 constant:-spacing];
      constraint.identifier = @"Stack between children";
      // constraint.priority = 900;
      [view addConstraint:constraint];
      [constraintsArray addObject:constraint];
      // NSLog(@"%d bottom to next top %d %d", i, minProp == NSLayoutAttributeTop, maxProp == NSLayoutAttributeBottom);
    } else {
      constraint = [NSLayoutConstraint constraintWithItem:view attribute:minProp relatedBy:NSLayoutRelationEqual toItem:subView attribute:minProp multiplier:1.0 constant:-spacing];
      constraint.identifier = @"Stack main pos min";
      // constraint.priority = 800;
      [view addConstraint:constraint];
      [constraintsArray addObject:constraint];
      // NSLog(@"%d top to parent top %d", i, minProp == NSLayoutAttributeTop);
    }

    prevView = subView;

    constraint = [NSLayoutConstraint constraintWithItem:view attribute:crossPropMax relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:subView attribute:crossPropMax multiplier:1.0 constant:-spacing];
    constraint.identifier = @"Stack cross pos max";
    constraint.priority = 800;
    [view addConstraint:constraint];
    [constraintsArray addObject:constraint];
    // NSLog(@"%d size %d", i, crossPropMax == NSLayoutAttributeRight);

    constraint = [NSLayoutConstraint constraintWithItem:view attribute:crossPropMax relatedBy:NSLayoutRelationEqual toItem:subView attribute:crossPropMax multiplier:1.0 constant:-spacing];
    constraint.identifier = @"Stack cross pos max eq";
    constraint.priority = 200;
    [view addConstraint:constraint];
    [constraintsArray addObject:constraint];
    // NSLog(@"%d size %d", i, crossPropMax == NSLayoutAttributeRight);
  }
  
  if (prevView) {
    if (view.subviews.count > 1) {
      constraint = [NSLayoutConstraint constraintWithItem:view attribute:maxProp relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:prevView attribute:maxProp multiplier:1.0 constant:-spacing];
      constraint.identifier = @"Stack max";
      constraint.priority = 800;
      [view addConstraint:constraint];
      [constraintsArray addObject:constraint];
      // NSLog(@"max %d", maxProp == NSLayoutAttributeBottom);
    } else {
      constraint = [NSLayoutConstraint constraintWithItem:view attribute:maxProp relatedBy:NSLayoutRelationEqual toItem:prevView attribute:maxProp multiplier:1.0 constant:-spacing];
      constraint.identifier = @"Stack max";
      constraint.priority = 800;
      [view addConstraint:constraint];
      [constraintsArray addObject:constraint];
      // NSLog(@"max %d", maxProp == NSLayoutAttributeBottom);
    }
  }
}

void StackLayout::removeLayout(void * container) {
  if (nativeInfo != nullptr)
  {
    NSArray<NSLayoutConstraint*> * constraints = (NSArray<NSLayoutConstraint*> *) CFBridgingRelease(nativeInfo);

  //  NSLog(@"Removing %lu constraints", constraints.count);
    for (NSLayoutConstraint* constraint in constraints)
    {
      NSView * first = constraint.firstItem;
      NSView * second = constraint.secondItem;
      [first removeConstraint:constraint];
      [second removeConstraint:constraint];
      constraint.active = NO;
    }

    nativeInfo = NULL;
  }
}

void StackLayout::onViewAdded(void * nativeView, void * addedNativeView) {
  // TODO: Instead of relayouting everything, we should just make the necessary updates
  layoutContainer(nativeView);
}

void StackLayout::onViewRemoved(void * nativeView, void * removedNativeView) {
  // TODO: Instead of relayouting everything, we should just make the necessary updates
  layoutContainer(nativeView);
}
