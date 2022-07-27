#include "StackLayout.h"
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

using namespace rehax::ui::appkit::impl;

StackLayout::StackLayout()
:isHorizontal(false), spacing(0.0)
{}

StackLayout::StackLayout(StackLayoutOptions options)
:isHorizontal(options.direction == StackLayoutDirection_Horizontal), spacing(options.spacing)
{}

StackLayout::~StackLayout() {
  removeLayout(nullptr);
}

void StackLayout::layoutContainer(void * container) {
  NSView * view = (__bridge NSView *) container;
  NSView * prevView = NULL;
  
  removeLayout(container);
  
  NSMutableArray * constraintsArray = [NSMutableArray array];
  nativeInfo = (void*) CFBridgingRetain(constraintsArray);

  auto minProp = isHorizontal ? NSLayoutAttributeLeft : NSLayoutAttributeTop;
  auto maxProp = isHorizontal ? NSLayoutAttributeRight : NSLayoutAttributeBottom;

  auto crossPropMin = isHorizontal ? NSLayoutAttributeTop : NSLayoutAttributeLeft;
//  auto crossPropMax = isHorizontal ? NSLayoutAttributeBottom : NSLayoutAttributeRight;
  auto crossPropSize = isHorizontal ? NSLayoutAttributeHeight : NSLayoutAttributeWidth;
  
  NSLayoutConstraint * constraint;

  if (view.subviews.count > 0) {
    constraint = [NSLayoutConstraint constraintWithItem:view attribute:minProp relatedBy:NSLayoutRelationEqual toItem:view.subviews[0] attribute:minProp multiplier:1.0 constant:-spacing];
    constraint.identifier = @"Stack main pos min";
    [view addConstraint:constraint];
    [constraintsArray addObject:constraint];
    prevView = view.subviews[0];
    
    constraint = [NSLayoutConstraint constraintWithItem:view attribute:crossPropMin relatedBy:NSLayoutRelationEqual toItem:view.subviews[0] attribute:crossPropMin multiplier:1.0 constant:-spacing];
    constraint.identifier = @"Stack cross pos min";
    [view addConstraint:constraint];
    [constraintsArray addObject:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:view.subviews[0] attribute:crossPropSize relatedBy:NSLayoutRelationLessThanOrEqual toItem:view attribute:crossPropSize multiplier:1.0 constant:-2.0 * spacing];
    constraint.identifier = @"Stack cross max size";
    [view addConstraint:constraint];
    [constraintsArray addObject:constraint];
  }

  for (int i = 1; i < view.subviews.count; i++) {
    NSView * subView = view.subviews[i];

    constraint = [NSLayoutConstraint constraintWithItem:prevView attribute:maxProp relatedBy:NSLayoutRelationEqual toItem:subView attribute:minProp multiplier:1.0 constant:-spacing];
    constraint.identifier = @"Stack between children";
    [view addConstraint:constraint];
    [constraintsArray addObject:constraint];

    prevView = subView;

    constraint = [NSLayoutConstraint constraintWithItem:view attribute:crossPropMin relatedBy:NSLayoutRelationEqual toItem:subView attribute:crossPropMin multiplier:1.0 constant:-spacing];
    constraint.identifier = @"Stack cross pos min";
    [view addConstraint:constraint];
    [constraintsArray addObject:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:subView attribute:crossPropSize relatedBy:NSLayoutRelationLessThanOrEqual toItem:view attribute:crossPropSize multiplier:1.0 constant:-2.0 * spacing];
    constraint.identifier = @"Stack cross max size";
    [view addConstraint:constraint];
    [constraintsArray addObject:constraint];
  }
  
  if (prevView) {
    constraint = [NSLayoutConstraint constraintWithItem:prevView attribute:maxProp relatedBy:NSLayoutRelationLessThanOrEqual toItem:view attribute:maxProp multiplier:1.0 constant:-spacing];
    constraint.identifier = @"Stack max";
    [view addConstraint:constraint];
    [constraintsArray addObject:constraint];
  }
}

void StackLayout::removeLayout(void * container) {
  if (nativeInfo != nullptr)
  {
    NSArray<NSLayoutConstraint*> * constraints = (NSArray<NSLayoutConstraint*> *) CFBridgingRelease(nativeInfo);

//    NSLog(@"Removing %lu constraints", constraints.count);
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
