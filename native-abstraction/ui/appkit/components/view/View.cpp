#import "View.h"
#include "../../../base.h"
// #include "Gesture.h"

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

using namespace rehax::ui::appkit::impl;

@interface FlippedView : NSView
- (BOOL)isFlipped;
@end

@implementation FlippedView
- (BOOL)isFlipped {
    return YES;
}
@end


template <typename Container>
rehax::ui::appkit::impl::View<Container>::View()
{}

template <typename Container>
rehax::ui::appkit::impl::View<Container>::~View()
{}

template <typename Container>
void View<Container>::createNativeView()
{
  NSView * view = [FlippedView new];
  nativeView = (void *) CFBridgingRetain(view);
}

template <typename Container>
void View<Container>::destroyNativeView()
{
  if (nativeView != nullptr) {
    CFBridgingRelease(nativeView);
    nativeView = nullptr;
  }
}

template <typename Container>
void View<Container>::setNativeViewRaw(void * view)
{
  nativeView = view;
}

template <typename Container>
void * View<Container>::getNativeView()
{
  return nativeView;
}

template <typename Container>
void View<Container>::addNativeView(void * child)
{
  NSView * view = (__bridge NSView *) nativeView;
  NSView * childView = (__bridge NSView *) child;
  [childView setFrame:view.bounds];
  childView.translatesAutoresizingMaskIntoConstraints = NO;
  [view addSubview:childView];
}

template <typename Container>
void View<Container>::removeNativeChild(void * child)
{
  NSView * view = (__bridge NSView *) nativeView;
  NSView * childView = (__bridge NSView *) child;
  [childView removeFromSuperview];
}

template <typename Container>
void View<Container>::removeFromNativeParent()
{
  NSView * view = (__bridge NSView *) nativeView;
  [view removeFromSuperview];
}

void AppKitNativeViewRemoveAllConstraintsWidthId(NSView * view, NSString * identifier)
{
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier == %@", identifier];
  NSArray *filteredArray = [[view constraints] filteredArrayUsingPredicate:predicate];

  for (id constraint in filteredArray)
  {
    [view removeConstraint:constraint];
  }

//   filteredArray = [[[view superview] constraints] filteredArrayUsingPredicate:predicate];
//   for (id constraint in filteredArray)
//   {
//     if ([constraint secondItem] == view)
//     {
//       // [[view superview] removeConstraint:constraint];
//     }
//   }
}

template <typename Container>
void View<Container>::setWidthFill()
{
  NSView * view = (__bridge NSView *) nativeView;
  AppKitNativeViewRemoveAllConstraintsWidthId(view, @"hx_width");

  NSLayoutConstraint * constraint;

  constraint = [NSLayoutConstraint constraintWithItem:[view superview] attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
  constraint.identifier = @"hx_width";
  [[view superview] addConstraint:constraint];

  constraint = [NSLayoutConstraint constraintWithItem:[view superview] attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
  constraint.identifier = @"hx_width";
  [[view superview] addConstraint:constraint];
}

template <typename Container>
void View<Container>::setHeightFill()
{
  NSView * view = (__bridge NSView *) nativeView;
  AppKitNativeViewRemoveAllConstraintsWidthId(view, @"hx_height");

  NSLayoutConstraint * constraint;

  constraint = [NSLayoutConstraint constraintWithItem:[view superview] attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
  constraint.identifier = @"hx_height";
  [[view superview] addConstraint:constraint];

  constraint = [NSLayoutConstraint constraintWithItem:[view superview] attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
  constraint.identifier = @"hx_height";
  [[view superview] addConstraint:constraint];
}

template <typename Container>
void View<Container>::setWidthNatural()
{
  NSView * view = (__bridge NSView *) nativeView;
  AppKitNativeViewRemoveAllConstraintsWidthId(view, @"hx_width");
}

template <typename Container>
void View<Container>::setHeightNatural()
{
  NSView * view = (__bridge NSView *) nativeView;
  AppKitNativeViewRemoveAllConstraintsWidthId(view, @"hx_height");
}

template <typename Container>
void View<Container>::setWidthFixed(float width)
{
  NSView * view = (__bridge NSView *) nativeView;
  AppKitNativeViewRemoveAllConstraintsWidthId(view, @"hx_width");

  NSLayoutConstraint * constraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:width];
  constraint.identifier = @"hx_width";
  [view addConstraint:constraint];
}

template <typename Container>
void View<Container>::setHeightFixed(float height)
{
  NSView * view = (__bridge NSView *) nativeView;
  AppKitNativeViewRemoveAllConstraintsWidthId(view, @"hx_height");

  NSLayoutConstraint * constraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:height];
  constraint.identifier = @"hx_height";
  [view addConstraint:constraint];
}

template <typename Container>
void View<Container>::setWidthPercentage(float percentage)
{
  NSView * view = (__bridge NSView *) nativeView;
  AppKitNativeViewRemoveAllConstraintsWidthId(view, @"hx_width");

  NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:[view superview] attribute:NSLayoutAttributeWidth multiplier:percentage / 100.0 constant:0];
  constraint.identifier = @"hx_width";
  [[view superview] addConstraint:constraint];
}

template <typename Container>
void View<Container>::setHeightPercentage(float percentage)
{
  NSView * view = (__bridge NSView *) nativeView;
  AppKitNativeViewRemoveAllConstraintsWidthId(view, @"hx_height");

  NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:[view superview] attribute:NSLayoutAttributeHeight multiplier:percentage / 100.0 constant:0];
  constraint.identifier = @"hx_height";
  [[view superview] addConstraint:constraint];
}

template <typename Container>
void View<Container>::setNativeVerticalPositionNatural(void * previousView)
{
  NSView * view = (__bridge NSView *) nativeView;
  AppKitNativeViewRemoveAllConstraintsWidthId(view, @"hx_pos_vert");

  if (view.superview == NULL) {
    return;
  }

  if (previousView == NULL) {
    NSLayoutConstraint * constraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:view.superview attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    constraint.identifier = @"hx_pos_vert";
    [view.superview addConstraint:constraint];
  } else {
    NSView * prev = (__bridge NSView *) nativeView;
    NSLayoutConstraint * constraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:prev attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    constraint.identifier = @"hx_pos_vert";
    [view.superview addConstraint:constraint];
  }
}

template <typename Container>
void View<Container>::setNativeHorizontalPositionNatural(void * previousView)
{
  NSView * view = (__bridge NSView *) nativeView;
  AppKitNativeViewRemoveAllConstraintsWidthId(view, @"hx_pos_horiz");

  if (view.superview == NULL) {
    return;
  }

  if (previousView == NULL) {
    NSLayoutConstraint * constraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:view.superview attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    constraint.identifier = @"hx_pos_horiz";
    [view.superview addConstraint:constraint];
  } else {
    NSView * prev = (__bridge NSView *) previousView;
    NSLayoutConstraint * constraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:prev attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    constraint.identifier = @"hx_pos_horiz";
    [view.superview addConstraint:constraint];
  }
}

template <typename Container>
void View<Container>::setVerticalPositionFixed(float y)
{
  NSView * view = (__bridge NSView *) nativeView;
  AppKitNativeViewRemoveAllConstraintsWidthId(view, @"hx_pos_vert");

  NSLayoutConstraint * constraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:view.superview attribute:NSLayoutAttributeTop multiplier:1.0 constant:y];
  constraint.identifier = @"hx_pos_vert";
  [view.superview addConstraint:constraint];
}

template <typename Container>
void View<Container>::setHorizontalPositionFixed(float x)
{
  NSView * view = (__bridge NSView *) nativeView;
  AppKitNativeViewRemoveAllConstraintsWidthId(view, @"hx_pos_horiz");

  NSLayoutConstraint * constraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:view.superview attribute:NSLayoutAttributeLeft multiplier:1.0 constant:x];
  constraint.identifier = @"hx_pos_horiz";
  [view.superview addConstraint:constraint];
}

// void View<Container>::setBackgroundColor(rehax::ui::Color color)
// {
//   NSView * view = (__bridge NSView *) nativeView;
//   // [view setWantsLayer:true];
//   // [view setLayer:[CALayer layer]];
//   NSColor *col = [NSColor colorWithDeviceRed:color.r/255.0 green:color.g/255.0 blue:color.b/255.0 alpha:color.a];
//   [view.layer setBackgroundColor:[col CGColor]];
// }

template <typename Container>
void View<Container>::setOpacity(float opacity)
{
  NSView * view = (__bridge NSView *) nativeView;
  [view setAlphaValue:opacity];
}

// void rehax::View<Container>::addGesture(rehax::Gesture nativeGesture)
// {
//   NSView * view = (__bridge NSView *) nativeView;
//   NSGestureRecognizer * rec = (__bridge NSGestureRecognizer *) nativeGesture.native;

//   [view addGestureRecognizer:rec];
// }

// void rehax::View<Container>::removeGesture(rehax::Gesture nativeGesture)
// {
//     // [ TODO ]
// //   NSView * view = (__bridge NSView *) nativeView;
// //   NSGestureRecognizer * rec = (__bridge NSGestureRecognizer *) nativeGesture.native;

// //   [view addGestureRecognizer:rec];
// }

template class rehax::ui::appkit::impl::View<rehax::ui::RawPtr>;