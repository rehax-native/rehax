#include "FlexLayout.h"
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

using namespace rehax::ui::appkit::impl;

ObjectPointer<FlexLayout> FlexLayout::Create() {
  auto ptr = Object<FlexLayout>::Create();
  return ptr;
}

std::string FlexLayout::ClassName() {
  return "FlexLayout";
}

std::string FlexLayout::instanceClassName() {
  return FlexLayout::ClassName();
}

std::string FlexLayout::description() {
  std::ostringstream stringStream;
  stringStream << instanceClassName() << "/NSLayoutConstraints (Appkit) " << this;
  return stringStream.str();
}

FlexLayout::FlexLayout() {}

FlexLayout::~FlexLayout() {
  removeLayout(nullptr);
}

void FlexLayout::setOptions(FlexLayoutOptions flexLayoutOptions) {
  isHorizontal = flexLayoutOptions.direction == FlexLayoutDirection::Column || flexLayoutOptions.direction == FlexLayoutDirection::ColumnReverse;
  isReverse = flexLayoutOptions.direction == FlexLayoutDirection::RowReverse || flexLayoutOptions.direction == FlexLayoutDirection::ColumnReverse;
  justifyContent = flexLayoutOptions.justifyContent;
  alignItems = flexLayoutOptions.alignItems;
}

std::tuple<NSLayoutAttribute, NSLayoutAttribute, bool, NSLayoutAttribute> flexLayoutAttributeForAlign(bool isHorizontal, FlexAlignItems alignment) {
  constexpr int AlignFlexStart = 0;
  constexpr int AlignFlexEnd = 1;
  constexpr int AlignCenter = 2;
  constexpr int AlignStretch = 3;
  
  auto propSize = NSLayoutAttributeHeight;
  auto propMin = NSLayoutAttributeTop;
  auto propMax = NSLayoutAttributeTop;
  bool hasTwo = false;
  
  if (isHorizontal) {
    propSize = NSLayoutAttributeWidth;
    if (alignment == FlexAlignItems::FlexStart) {
      propMin = NSLayoutAttributeLeft;
    } else if (alignment == FlexAlignItems::FlexEnd) {
      propMin = NSLayoutAttributeRight;
    } else if (alignment == FlexAlignItems::Center) {
      propMin = NSLayoutAttributeCenterX;
    } else if (alignment == FlexAlignItems::Stretch) {
      propMin = NSLayoutAttributeLeft;
      propMax = NSLayoutAttributeRight;
      hasTwo = true;
    }
  } else {
    if (alignment == FlexAlignItems::FlexStart) {
      propMin = NSLayoutAttributeTop;
    } else if (alignment == FlexAlignItems::FlexEnd) {
      propMin = NSLayoutAttributeBottom;
    } else if (alignment == FlexAlignItems::Center) {
      propMin = NSLayoutAttributeCenterY;
    } else if (alignment == FlexAlignItems::Stretch) {
      propMin = NSLayoutAttributeTop;
      propMax = NSLayoutAttributeBottom;
      hasTwo = true;
    }
  }
  
  return std::tuple<NSLayoutAttribute, NSLayoutAttribute, bool, NSLayoutAttribute>(propSize, propMin, hasTwo, propMax);
}

void FlexLayout::layoutContainer(void * nativeView) {
  NSView * view = (__bridge NSView *) nativeView;
  
  removeLayout(nativeView);
  
  NSMutableArray * constraintsArray = [NSMutableArray array];
  nativeInfo = (void*) CFBridgingRetain(constraintsArray);
  
  NSView * prevView = NULL;
  float spacing = 0.0;
  
  auto crossProps = flexLayoutAttributeForAlign(!isHorizontal, alignItems);

  auto minProp = isHorizontal ? NSLayoutAttributeLeft : NSLayoutAttributeTop;
  auto maxProp = isHorizontal ? NSLayoutAttributeRight : NSLayoutAttributeBottom;
  auto sizeProp = isHorizontal ? NSLayoutAttributeWidth : NSLayoutAttributeHeight;
  
  NSLayoutConstraint * constraint;

  float totalFlex = 0.0;
  NSView * prevFlexView = NULL;
  float prevFlex = 0.0;

  if (view.subviews.count > 0) {

    auto itemProps = crossProps;
    if (items.size() > 0) {
      itemProps = flexLayoutAttributeForAlign(!isHorizontal, items[0].alignSelf);
    }

    constraint = [NSLayoutConstraint constraintWithItem:view attribute:std::get<1>(itemProps) relatedBy:NSLayoutRelationEqual toItem:view.subviews[0] attribute:std::get<1>(itemProps) multiplier:1.0 constant:-spacing];
    constraint.identifier = @"Flex cross axis min";
    [view addConstraint:constraint];
    [constraintsArray addObject:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:view.subviews[0] attribute:std::get<0>(itemProps) relatedBy:NSLayoutRelationLessThanOrEqual toItem:view attribute:std::get<0>(itemProps) multiplier:1.0 constant:-2.0 * spacing];
    constraint.identifier = @"Flex cross size max";
    [view addConstraint:constraint];
    [constraintsArray addObject:constraint];

    if (std::get<2>(itemProps)) {
      constraint = [NSLayoutConstraint constraintWithItem:view.subviews[0] attribute:std::get<3>(itemProps) relatedBy:NSLayoutRelationEqual toItem:view attribute:std::get<3>(itemProps) multiplier:1.0 constant:-2.0 * spacing];
      constraint.identifier = @"Flex cross axis max";
      [view addConstraint:constraint];
      [constraintsArray addObject:constraint];
    }

    prevView = view.subviews[0];

    if (items.size() > 0 && items[0].hasFlexGrow) {
      totalFlex += items[0].flexGrow;
      prevFlexView = view.subviews[0];
      prevFlex = items[0].flexGrow;
    }
  }

  for (int i = 1; i < view.subviews.count; i++) {
    NSView * subView = view.subviews[i];
    auto itemProps = crossProps;
    if (items.size() > i) {
      itemProps = flexLayoutAttributeForAlign(!isHorizontal, items[i].alignSelf);
    }

    constraint = [NSLayoutConstraint constraintWithItem:prevView attribute:maxProp relatedBy:NSLayoutRelationEqual toItem:subView attribute:minProp multiplier:1.0 constant:-spacing];
    constraint.identifier = @"Flex main between children";
    [view addConstraint:constraint];
    [constraintsArray addObject:constraint];

    prevView = subView;

    constraint = [NSLayoutConstraint constraintWithItem:view attribute:std::get<1>(itemProps) relatedBy:NSLayoutRelationEqual toItem:subView attribute:std::get<1>(itemProps) multiplier:1.0 constant:-spacing];
    constraint.identifier = @"Flex cross axis min";
    [view addConstraint:constraint];
    [constraintsArray addObject:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:subView attribute:std::get<0>(itemProps) relatedBy:NSLayoutRelationLessThanOrEqual toItem:view attribute:std::get<0>(itemProps) multiplier:1.0 constant:-2.0 * spacing];
    constraint.identifier = @"Flex cross size max";
    [view addConstraint:constraint];
    [constraintsArray addObject:constraint];

    if (std::get<2>(itemProps)) {
      constraint = [NSLayoutConstraint constraintWithItem:subView attribute:std::get<3>(itemProps) relatedBy:NSLayoutRelationEqual toItem:view attribute:std::get<3>(itemProps) multiplier:1.0 constant:-2.0 * spacing];
      constraint.identifier = @"Flex cross axis max";
      [view addConstraint:constraint];
      [constraintsArray addObject:constraint];
    }

    if (items.size() > i && items[i].hasFlexGrow) {
      totalFlex += items[i].flexGrow;

      auto item = items[i];
      auto subView = view.subviews[i];
      if (prevFlexView) {
        float multiplier = item.flexGrow / prevFlex;
        auto constraint = [NSLayoutConstraint constraintWithItem:subView attribute:sizeProp relatedBy:NSLayoutRelationEqual toItem:prevFlexView attribute:sizeProp multiplier:multiplier constant:0.0];
        constraint.identifier = @"Flex grow";
        [view addConstraint:constraint];
        [constraintsArray addObject:constraint];
      }
      prevFlexView = subView;
      prevFlex = item.flexGrow;
    }
  }

  if ((justifyContent == FlexJustifyContent::FlexStart || totalFlex > 0.0) && view.subviews.count > 0) {
    auto subView = view.subviews[0];
    constraint = [NSLayoutConstraint constraintWithItem:view attribute:minProp relatedBy:NSLayoutRelationEqual toItem:subView attribute:minProp multiplier:1.0 constant:-spacing];
    constraint.identifier = @"Flex main axis justify start";
    [view addConstraint:constraint];
    [constraintsArray addObject:constraint];
  }

  if ((justifyContent == FlexJustifyContent::FlexEnd || totalFlex > 0.0) && view.subviews.count > 0) {
    auto subView = view.subviews[view.subviews.count - 1];
    constraint = [NSLayoutConstraint constraintWithItem:view attribute:maxProp relatedBy:NSLayoutRelationEqual toItem:subView attribute:maxProp multiplier:1.0 constant:-spacing];
    constraint.identifier = @"Flex main axis justify end";
    [view addConstraint:constraint];
    [constraintsArray addObject:constraint];
  }

  if (justifyContent == FlexJustifyContent::Center && totalFlex == 0.0 && view.subviews.count > 0) {
    // This isn't as easy with layout constraints
    // There are several ways:
    // * We could create two spacer views, on for the leading and one for the trailing edge, and make them equal size.
    //   This introduces two new views which we have to manage somehow.
    // * We put all views into a container view and align the center of the container to the center of the parent. This introduces another view again.
    // * We measure the childrens' sizes and create constraints accordingly. Not sure this will work with varying sizes of the children.

    // Since all these solutions aren't easy to implement, we make a compromise: We simply create a constraint that centers the middle child.
    // This will give wrong results in many cases

    int middleIndex = (int) view.subviews.count / 2.0;
    auto subView = view.subviews[middleIndex];

    auto centerProp = isHorizontal ? NSLayoutAttributeCenterX : NSLayoutAttributeCenterY;

    constraint = [NSLayoutConstraint constraintWithItem:view attribute:centerProp relatedBy:NSLayoutRelationEqual toItem:subView attribute:centerProp multiplier:1.0 constant:0];
    constraint.identifier = @"Flex main axis justify center";
    [view addConstraint:constraint];
    [constraintsArray addObject:constraint];
  }
  
//  NSLog(@"Added %lu constraints", constraintsArray.count);
}

void FlexLayout::removeLayout(void * container) {
  if (nativeInfo != nullptr)
  {
    NSArray<NSLayoutConstraint*> * constraints = (NSArray<NSLayoutConstraint*> *) CFBridgingRelease(nativeInfo);

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

void FlexLayout::onViewAdded(void * nativeView, void * addedNativeView) {
  // TODO: Instead of relayouting everything, we should just make the necessary updates
  layoutContainer(nativeView);
}

void FlexLayout::onViewRemoved(void * nativeView, void * removedNativeView) {
  // TODO: Instead of relayouting everything, we should just make the necessary updates
  layoutContainer(nativeView);
}
