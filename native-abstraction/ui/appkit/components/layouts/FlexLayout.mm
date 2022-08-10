#include "FlexLayout.h"
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <objc/runtime.h>
#import "../view/BaseView.h"

using namespace rehax::ui::appkit::impl;
using namespace rehax::ui;

#include "../../../shared/components/FlexLayout.cc"

std::string FlexLayout::description() {
  std::ostringstream stringStream;
  stringStream << instanceClassName() << "/NSLayoutConstraints (Appkit) " << this;
  return stringStream.str();
}


// @interface FlexViewLayouter : ViewLayouter
// {
//     @public
//     bool isHorizontal;
//     FlexJustifyContent justifyContent;
//     FlexAlignItems alignItems;
// }
// @end

// @implementation FlexViewLayouter

// - (float)crossPosition:(NSView*)view availableLength:(float)length
// {
//     NSSize intrinsicSize = [view intrinsicContentSize];
//     CGSize boundsSize = view.bounds.size;
//     if (intrinsicSize.width >= 0) {
//       boundsSize.width = intrinsicSize.width;
//     }
//     if (intrinsicSize.height >= 0) {
//       boundsSize.height = intrinsicSize.height;
//     }
    
//   if (alignItems == FlexAlignItems::Center) {
//     float viewLength = isHorizontal ? boundsSize.height : boundsSize.width;
//     return (length - viewLength) / 2.0f;
//   }
//   if (alignItems == FlexAlignItems::FlexEnd) {
//     float viewLength = isHorizontal ? boundsSize.height : boundsSize.width;
//     return length - viewLength;
//   }
//   return 0;
// }

// - (float)crossSize:(NSView*)view availableLength:(float)length
// {
//   if (alignItems == FlexAlignItems::Stretch) {
//     return length;
//   }
//     NSSize intrinsicSize = [view intrinsicContentSize];
//     CGSize boundsSize = view.bounds.size;
//     if (intrinsicSize.width > 0) {
//       boundsSize.width = intrinsicSize.width;
//     }
//     if (intrinsicSize.height > 0) {
//       boundsSize.height = intrinsicSize.height;
//     }
//   float viewLength = isHorizontal ? boundsSize.height : boundsSize.width;
//   return viewLength;
// }

// - (void)layout:(NSView*)view
// {
//   float availableWidth = view.bounds.size.width;
//   float availableHeight = view.bounds.size.height;
    
//   float availableLengthMain = isHorizontal ? availableWidth : availableHeight;
//   float availableLengthCross = isHorizontal ? availableHeight : availableWidth;
//     NSLog(@"Flex %f %f", availableLengthMain, availableLengthCross);
    
//   float posMain = 0;
//   for (NSView * subview in view.subviews) {
      
//     NSSize intrinsicSize = [subview intrinsicContentSize];
//     CGSize boundsSize = subview.bounds.size;
//     if (intrinsicSize.width >= 0) {
//       boundsSize.width = intrinsicSize.width;
//     }
//     if (intrinsicSize.height >= 0) {
//       boundsSize.height = intrinsicSize.height;
//     }
    
//     if (isHorizontal) {
//       subview.frame = CGRectMake(posMain, [self crossPosition:subview availableLength:availableLengthCross], boundsSize.width, [self crossSize:subview availableLength:availableLengthCross]);
//       posMain += boundsSize.width;
//     } else {
//       subview.frame = CGRectMake([self crossPosition:subview availableLength:availableLengthCross], posMain, [self crossSize:subview availableLength:availableLengthCross], boundsSize.height);
//       posMain += boundsSize.height;
//     }
//     NSLog(@"Flex view size %@ %f %f", subview, subview.frame.size.width, subview.frame.size.height);
//   }

//   float adjustMainPositionBy = 0;
//   if (justifyContent == FlexJustifyContent::FlexEnd) {
//     adjustMainPositionBy = availableLengthMain - posMain;
//   } else if (justifyContent == FlexJustifyContent::Center) {
//     adjustMainPositionBy = (availableLengthMain - posMain) / 2.0f;
//   }
    
//   if (adjustMainPositionBy != 0) {
//     for (NSView * subview in view.subviews) {
//       if (isHorizontal) {
//         subview.frame = NSMakeRect(subview.frame.origin.x + adjustMainPositionBy, subview.frame.origin.y, subview.frame.size.width, subview.frame.size.height);
//       } else {
//         subview.frame = NSMakeRect(subview.frame.origin.x, subview.frame.origin.y + adjustMainPositionBy, subview.frame.size.width, subview.frame.size.height);
//       }
//     }
//   }
// }

// @end

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
    
  // if (nativeInfo != nullptr) {
  //   FlexViewLayouter * layouter = (FlexViewLayouter * ) nativeInfo;
  //   layouter->isHorizontal = isHorizontal;
  //   layouter->alignItems = alignItems;
  //   layouter->justifyContent = justifyContent;
  //   [view setNeedsLayout:true];
  // } else if ([view respondsToSelector:@selector(setLayouter:)]) {
  //   FlexViewLayouter * layouter = [FlexViewLayouter new];
  //   layouter->isHorizontal = isHorizontal;
  //   layouter->alignItems = alignItems;
  //   layouter->justifyContent = justifyContent;
  //   [view performSelector:@selector(setLayouter:) withObject:layouter];
  //   nativeInfo = (void*) CFBridgingRetain(layouter);
  //   [view setNeedsLayout:true];
  // }
  // return;
  
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
    constraint.priority = 800;
    [view addConstraint:constraint];
    [constraintsArray addObject:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:view.subviews[0] attribute:std::get<0>(itemProps) relatedBy:NSLayoutRelationLessThanOrEqual toItem:view attribute:std::get<0>(itemProps) multiplier:1.0 constant:-2.0 * spacing];
    constraint.identifier = @"Flex cross size max";
    constraint.priority = 800;
    [view addConstraint:constraint];
    [constraintsArray addObject:constraint];

    if (std::get<2>(itemProps)) {
      constraint = [NSLayoutConstraint constraintWithItem:view.subviews[0] attribute:std::get<3>(itemProps) relatedBy:NSLayoutRelationEqual toItem:view attribute:std::get<3>(itemProps) multiplier:1.0 constant:-2.0 * spacing];
      constraint.identifier = @"Flex cross axis max";
      constraint.priority = 800;
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
    constraint.priority = 800;
    [view addConstraint:constraint];
    [constraintsArray addObject:constraint];

    prevView = subView;

    constraint = [NSLayoutConstraint constraintWithItem:view attribute:std::get<1>(itemProps) relatedBy:NSLayoutRelationEqual toItem:subView attribute:std::get<1>(itemProps) multiplier:1.0 constant:-spacing];
    constraint.identifier = @"Flex cross axis min";
    constraint.priority = 800;
    [view addConstraint:constraint];
    [constraintsArray addObject:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:subView attribute:std::get<0>(itemProps) relatedBy:NSLayoutRelationLessThanOrEqual toItem:view attribute:std::get<0>(itemProps) multiplier:1.0 constant:-2.0 * spacing];
    constraint.identifier = @"Flex cross size max";
    constraint.priority = 800;
    [view addConstraint:constraint];
    [constraintsArray addObject:constraint];

    if (std::get<2>(itemProps)) {
      constraint = [NSLayoutConstraint constraintWithItem:subView attribute:std::get<3>(itemProps) relatedBy:NSLayoutRelationEqual toItem:view attribute:std::get<3>(itemProps) multiplier:1.0 constant:-2.0 * spacing];
      constraint.identifier = @"Flex cross axis max";
      constraint.priority = 800;
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
        constraint.priority = 800;
        [view addConstraint:constraint];
        [constraintsArray addObject:constraint];
      }
      prevFlexView = subView;
      prevFlex = item.flexGrow;
    }
  }

  // We want to always be as least as big as to contain all children
  // These are supposed to do this, but they cause some weirdness
  // if (view.subviews.count > 0) {
  //   auto subView = view.subviews[0];
  //   constraint = [NSLayoutConstraint constraintWithItem:subView attribute:minProp relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:view attribute:minProp multiplier:1.0 constant:0];
  //   constraint.identifier = @"Flex always enclose children";
  //   constraint.priority = 1000;
  //   [view addConstraint:constraint];
  //   [constraintsArray addObject:constraint];

  //   subView = view.subviews[view.subviews.count - 1];
  //   constraint = [NSLayoutConstraint constraintWithItem:subView attribute:maxProp relatedBy:NSLayoutRelationLessThanOrEqual toItem:view attribute:maxProp multiplier:1.0 constant:0];
  //   constraint.identifier = @"Flex always enclose children";
  //   constraint.priority = 1000;
  //   [view addConstraint:constraint];
  //   [constraintsArray addObject:constraint];
  // }

  if ((justifyContent == FlexJustifyContent::FlexStart || totalFlex > 0.0) && view.subviews.count > 0) {
    auto subView = view.subviews[0];
    constraint = [NSLayoutConstraint constraintWithItem:view attribute:minProp relatedBy:NSLayoutRelationEqual toItem:subView attribute:minProp multiplier:1.0 constant:-spacing];
    constraint.identifier = @"Flex main axis justify start";
    constraint.priority = 800;
    [view addConstraint:constraint];
    [constraintsArray addObject:constraint];
  }

  if ((justifyContent == FlexJustifyContent::FlexEnd || totalFlex > 0.0) && view.subviews.count > 0) {
    auto subView = view.subviews[view.subviews.count - 1];
    constraint = [NSLayoutConstraint constraintWithItem:view attribute:maxProp relatedBy:NSLayoutRelationEqual toItem:subView attribute:maxProp multiplier:1.0 constant:-spacing];
    constraint.identifier = @"Flex main axis justify end";
    constraint.priority = 800;
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

    NSView * firstView = view.subviews[0];
    NSView * lastView = view.subviews[view.subviews.count - 1];

     int middleIndex = (int) view.subviews.count / 2.0;
     auto subView = view.subviews[middleIndex];
     auto centerProp = isHorizontal ? NSLayoutAttributeCenterX : NSLayoutAttributeCenterY;

     if ((view.subviews.count) % 2 == 0) {
       auto sideProp = isHorizontal ? NSLayoutAttributeLeft : NSLayoutAttributeTop;
       constraint = [NSLayoutConstraint constraintWithItem:view attribute:centerProp relatedBy:NSLayoutRelationEqual toItem:subView attribute:sideProp multiplier:1.0 constant:0];
     } else {
       constraint = [NSLayoutConstraint constraintWithItem:view attribute:centerProp relatedBy:NSLayoutRelationEqual toItem:subView attribute:centerProp multiplier:1.0 constant:0];
     }
     constraint.identifier = @"Flex main axis justify center";
     constraint.priority = 1000;
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
