#include "FlexLayout.h"
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

rehax::FlexLayout::FlexLayout()
{}

rehax::FlexLayout::~FlexLayout()
{
  cleanUp(nullptr);
}

void rehax::FlexLayout::clearItems()
{
  items.clear();
}

void rehax::FlexLayout::addItem(FlexItem item)
{
  items.push_back(item);
}

void rehax::FlexLayout::setOptions(FlexLayoutOptions flexLayoutOptions) {
  isHorizontal = flexLayoutOptions.direction == FlexDirection_Column || flexLayoutOptions.direction == FlexDirection_ColumnReverse;
  isReverse = flexLayoutOptions.direction == FlexDirection_RowReverse || flexLayoutOptions.direction == FlexDirection_ColumnReverse;
  justifyContent = flexLayoutOptions.justifyContent;
  alignItems = flexLayoutOptions.alignItems;
}

std::tuple<NSLayoutAttribute, NSLayoutAttribute, bool, NSLayoutAttribute> flexLayoutAttributeForAlign(bool isHorizontal, int alignment)
{
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
    if (alignment == AlignFlexStart) {
      propMin = NSLayoutAttributeLeft;
    } else if (alignment == AlignFlexEnd) {
      propMin = NSLayoutAttributeRight;
    } else if (alignment == AlignCenter) {
      propMin = NSLayoutAttributeCenterX;
    } else if (alignment == AlignStretch) {
      propMin = NSLayoutAttributeLeft;
      propMax = NSLayoutAttributeRight;
      hasTwo = true;
    }
  } else {
    if (alignment == AlignFlexStart) {
      propMin = NSLayoutAttributeTop;
    } else if (alignment == AlignFlexEnd) {
      propMin = NSLayoutAttributeBottom;
    } else if (alignment == AlignCenter) {
      propMin = NSLayoutAttributeCenterY;
    } else if (alignment == AlignStretch) {
      propMin = NSLayoutAttributeTop;
      propMax = NSLayoutAttributeBottom;
      hasTwo = true;
    }
  }
  
  return std::tuple<NSLayoutAttribute, NSLayoutAttribute, bool, NSLayoutAttribute>(propSize, propMin, hasTwo, propMax);
}

void rehax::FlexLayout::layoutContainer(std::shared_ptr<View> container)
{
  NSView * view = (__bridge NSView *) container->nativeView;
  
  cleanUp(nullptr);
  
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
    if (items.size() > 0 && items[0].alignSelf >= 0) {
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
    if (items.size() > i && items[i].alignSelf >= 0) {
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

  if ((justifyContent == FlexJustifyContent_FlexStart || totalFlex > 0.0) && view.subviews.count > 0) {
    auto subView = view.subviews[0];
    constraint = [NSLayoutConstraint constraintWithItem:view attribute:minProp relatedBy:NSLayoutRelationEqual toItem:subView attribute:minProp multiplier:1.0 constant:-spacing];
    constraint.identifier = @"Flex main axis justify start";
    [view addConstraint:constraint];
    [constraintsArray addObject:constraint];
  }

  if ((justifyContent == FlexJustifyContent_FlexEnd || totalFlex > 0.0) && view.subviews.count > 0) {
    auto subView = view.subviews[view.subviews.count - 1];
    constraint = [NSLayoutConstraint constraintWithItem:view attribute:maxProp relatedBy:NSLayoutRelationEqual toItem:subView attribute:maxProp multiplier:1.0 constant:-spacing];
    constraint.identifier = @"Flex main axis justify end";
    [view addConstraint:constraint];
    [constraintsArray addObject:constraint];
  }

  if (justifyContent == FlexJustifyContent_Center && totalFlex == 0.0 && view.subviews.count > 0) {
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

void rehax::FlexLayout::cleanUp(std::shared_ptr<View> container)
{
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
