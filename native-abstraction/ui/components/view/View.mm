#include "View.h"
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#include "Gesture.h"

@interface FlippedView : NSView
- (BOOL)isFlipped;
@end

@implementation FlippedView
- (BOOL)isFlipped {
    return YES;
}
@end

// rehax::Position rehax::Position::create(float x, float y)
// {
//   rehax::Position pos;
//   pos.x = x;
//   pos.y = y;
//   return pos;
// }

// rehax::Size rehax::Size::create(float width, float height)
// {
//   rehax::Size size;
//   size.width = width;
//   size.height = height;
//   return size;
// }

// rehax::Frame rehax::Frame::create(rehax::Position position, rehax::Size size)
// {
//   rehax::Frame frame;
//   frame.position = position;
//   frame.size = size;
//   return frame;
// }

rehax::ui::Color rehax::ui::Color::create(float r, float g, float b, float a)
{
  rehax::ui::Color color;
  color.r = r;
  color.g = g;
  color.b = b;
  color.a = a;
  return color;
}

template <typename ViewBase>
typename ViewBase::PtrType rehax::ui::View<ViewBase>::Create()
{
  auto view = ViewBase::Create();
  // view->createNativeView();
  return view;
}

template <typename ViewBase>
rehax::ui::View<ViewBase>::View()
{}

template <typename ViewBase>
rehax::ui::View<ViewBase>::~View()
{}

// std::shared_ptr<rehax::View> rehax::View::CreateWithoutCreatingNativeView()
// {
//   auto view = ViewBase::Create();
//   return view;
// }

// rehax::View::View()
// {}

// rehax::View::~View()
// {
//   destroyNativeView();
// }

// void rehax::View::createNativeView()
// {
//   NSView * view = [FlippedView new];
//   nativeView = (void *) CFBridgingRetain(view);
// }

// void rehax::View::destroyNativeView()
// {
//   if (nativeView != nullptr) {
//     CFBridgingRelease(nativeView);
//     nativeView = nullptr;
//   }
// }

// void rehax::View::setNativeViewRaw(void * view)
// {
//   nativeView = view;
// }

// void rehax::View::addView(std::shared_ptr<rehax::View> child)
// {
//   child->removeFromParent();
//   child->parent = shared_from_this();
//   children.push_back(child);

//   NSView * view = (__bridge NSView *) nativeView;
//   NSView * childView = (__bridge NSView *) child->nativeView;
//   [childView setFrame:view.bounds];
//   childView.translatesAutoresizingMaskIntoConstraints = NO;
//   [view addSubview:childView];
// }

// void rehax::View::removeView(std::shared_ptr<rehax::View> child)
// {
//   NSView * view = (__bridge NSView *) nativeView;
//   NSView * childView = (__bridge NSView *) child->nativeView;
//   [view removeView:childView];
//   children.erase(children.find(child));
// }

// void rehax::View::removeFromParent()
// {
//   NSView * view = (__bridge NSView *) nativeView;
//   [view removeFromSuperview];
// }

// void ViewRemoveAllConstraintsWidthId(NSView * view, NSString * identifier)
// {
//   NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier == %@", identifier];
//   NSArray *filteredArray = [[view constraints] filteredArrayUsingPredicate:predicate];

//   for (id constraint in filteredArray)
//   {
//     // NSLog(@"Remove constraint %@", constraint);
//     [view removeConstraint:constraint];
//   }

//   filteredArray = [[[view superview] constraints] filteredArrayUsingPredicate:predicate];
//   for (id constraint in filteredArray)
//   {
//     if ([constraint secondItem] == view)
//     {
//       // [[view superview] removeConstraint:constraint];
//     }
//   }
// }

// void rehax::View::setWidthFill()
// {
//   NSView * view = (__bridge NSView *) nativeView;
//   ViewRemoveAllConstraintsWidthId(view, @"hx_width");

//   NSLayoutConstraint * constraint;

//   constraint = [NSLayoutConstraint constraintWithItem:[view superview] attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
//   constraint.identifier = @"hx_width";
//   [[view superview] addConstraint:constraint];

//   constraint = [NSLayoutConstraint constraintWithItem:[view superview] attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
//   constraint.identifier = @"hx_width";
//   [[view superview] addConstraint:constraint];
// }

// void rehax::View::setHeightFill()
// {
//   NSView * view = (__bridge NSView *) nativeView;
//   ViewRemoveAllConstraintsWidthId(view, @"hx_height");

//   NSLayoutConstraint * constraint;

//   constraint = [NSLayoutConstraint constraintWithItem:[view superview] attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
//   constraint.identifier = @"hx_height";
//   [[view superview] addConstraint:constraint];

//   constraint = [NSLayoutConstraint constraintWithItem:[view superview] attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
//   constraint.identifier = @"hx_height";
//   [[view superview] addConstraint:constraint];
// }

// void rehax::View::setWidthNatural()
// {
//   NSView * view = (__bridge NSView *) nativeView;
//   ViewRemoveAllConstraintsWidthId(view, @"hx_width");
// }

// void rehax::View::setHeightNatural()
// {
//   NSView * view = (__bridge NSView *) nativeView;
//   ViewRemoveAllConstraintsWidthId(view, @"hx_height");
// }

// void rehax::View::setWidthFixed(float width)
// {
//   NSView * view = (__bridge NSView *) nativeView;
//   ViewRemoveAllConstraintsWidthId(view, @"hx_width");

//   NSLayoutConstraint * constraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:width];
//   constraint.identifier = @"hx_width";
//   [view addConstraint:constraint];
// }

// void rehax::View::setHeightFixed(float height)
// {
//   NSView * view = (__bridge NSView *) nativeView;
//   ViewRemoveAllConstraintsWidthId(view, @"hx_height");

//   NSLayoutConstraint * constraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:height];
//   constraint.identifier = @"hx_height";
//   [view addConstraint:constraint];
// }

// void rehax::View::setWidthPercentage(float percentage)
// {
//   NSView * view = (__bridge NSView *) nativeView;
//   ViewRemoveAllConstraintsWidthId(view, @"hx_width");

//   NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:[view superview] attribute:NSLayoutAttributeWidth multiplier:percentage / 100.0 constant:0];
//   constraint.identifier = @"hx_width";
//   [[view superview] addConstraint:constraint];
// }

// void rehax::View::setHeightPercentage(float percentage)
// {
//   NSView * view = (__bridge NSView *) nativeView;
//   ViewRemoveAllConstraintsWidthId(view, @"hx_height");

//   NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:[view superview] attribute:NSLayoutAttributeHeight multiplier:percentage / 100.0 constant:0];
//   constraint.identifier = @"hx_height";
//   [[view superview] addConstraint:constraint];
// }

// void rehax::View::setVerticalPositionNatural(std::shared_ptr<rehax::View> previousView)
// {
//   NSView * view = (__bridge NSView *) nativeView;
//   ViewRemoveAllConstraintsWidthId(view, @"hx_pos_vert");

//   if (view.superview == NULL) {
//     return;
//   }

//   if (previousView == NULL) {
//     NSLayoutConstraint * constraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:view.superview attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
//     constraint.identifier = @"hx_pos_vert";
//     [view.superview addConstraint:constraint];
//   } else {
//     NSView * prev = (__bridge NSView *) previousView->nativeView;
//     NSLayoutConstraint * constraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:prev attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
//     constraint.identifier = @"hx_pos_vert";
//     [view.superview addConstraint:constraint];
//   }
// }

// void rehax::View::setHorizontalPositionNatural(std::shared_ptr<rehax::View> previousView)
// {
//   NSView * view = (__bridge NSView *) nativeView;
//   ViewRemoveAllConstraintsWidthId(view, @"hx_pos_horiz");

//   if (view.superview == NULL) {
//     return;
//   }

//   if (previousView == NULL) {
//     NSLayoutConstraint * constraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:view.superview attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
//     constraint.identifier = @"hx_pos_horiz";
//     [view.superview addConstraint:constraint];
//   } else {
//     NSView * prev = (__bridge NSView *) previousView->nativeView;
//     NSLayoutConstraint * constraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:prev attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
//     constraint.identifier = @"hx_pos_horiz";
//     [view.superview addConstraint:constraint];
//   }
// }

// void rehax::View::setVerticalPositionFixed(float y)
// {
//   NSView * view = (__bridge NSView *) nativeView;
//   ViewRemoveAllConstraintsWidthId(view, @"hx_pos_vert");

//   NSLayoutConstraint * constraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:view.superview attribute:NSLayoutAttributeTop multiplier:1.0 constant:y];
//   constraint.identifier = @"hx_pos_vert";
//   [view.superview addConstraint:constraint];
// }

// void rehax::View::setHorizontalPositionFixed(float x)
// {
//   NSView * view = (__bridge NSView *) nativeView;
//   ViewRemoveAllConstraintsWidthId(view, @"hx_pos_horiz");

//   NSLayoutConstraint * constraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:view.superview attribute:NSLayoutAttributeLeft multiplier:1.0 constant:x];
//   constraint.identifier = @"hx_pos_horiz";
//   [view.superview addConstraint:constraint];
// }

// // void rehax::View::setHeightFill()
// // {
// //   NSView * view = (__bridge NSView *) nativeView;
// //   [view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];

// //   NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier == %@", @"hx_height"];
// //   NSArray *filteredArray = [[view constraints] filteredArrayUsingPredicate:predicate];
// //   NSLayoutConstraint * constraint;
// //   if (filteredArray.count > 0) {
// //     constraint = filteredArray[0];
// //     constraint.constant = height;
// //   } else {
// //     constraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:height];
// //     constraint.identifier = @"hx_height";
// //     [view addConstraint:constraint];
// //   }
// // }

// // void rehax::View::setWidthNull()
// // {
// //   NSView * view = (__bridge NSView *) nativeView;
// //   NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier == %@", @"hx_width"];
// //   NSArray *filteredArray = [[view constraints] filteredArrayUsingPredicate:predicate];
// //   NSLayoutConstraint * constraint;
// //   if (filteredArray.count > 0) {
// //     constraint = filteredArray[0];
// //     [view removeConstraint:constraint];
// //   }
// // }

// // void rehax::View::setHeightNull()
// // {
// //   NSView * view = (__bridge NSView *) nativeView;
// //   NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier == %@", @"hx_height"];
// //   NSArray *filteredArray = [[view constraints] filteredArrayUsingPredicate:predicate];
// //   NSLayoutConstraint * constraint;
// //   if (filteredArray.count > 0) {
// //     constraint = filteredArray[0];
// //     [view removeConstraint:constraint];
// //   }
// // }

// // void rehax::View::setX(float x)
// // {

// // }

// // void rehax::View::setY(float y)
// // {

// // }

// // void rehax::View::setPosition(rehax::Position position)
// // {
// //   NSView * view = (__bridge NSView *) nativeView;
// //   NSRect frame = [view frame];
// //   [view setFrame:NSMakeRect(position.x, position.y, frame.size.width, frame.size.height)];
// // }

// // rehax::Size rehax::View::getSize()
// // {
// //   NSView * view = (__bridge NSView *) nativeView;
// //   NSRect frame = [view frame];
// //   rehax::Size size;
// //   size.width = frame.size.width;
// //   size.height = frame.size.height;
// //   return size;
// // }

// // rehax::Position rehax::View::getPosition()
// // {
// //   NSView * view = (__bridge NSView *) nativeView;
// //   NSRect frame = [view frame];
// //   rehax::Position position;
// //   position.x = frame.origin.x;
// //   position.y = frame.origin.y;
// //   return position;
// // }

// void rehax::View::setBackgroundColor(rehax::Color color)
// {
//   NSView * view = (__bridge NSView *) nativeView;
//   // [view setWantsLayer:true];
//   // [view setLayer:[CALayer layer]];
//   NSColor *col = [NSColor colorWithDeviceRed:color.r/255.0 green:color.g/255.0 blue:color.b/255.0 alpha:color.a];
//   [view.layer setBackgroundColor:[col CGColor]];
//   // NSLog(@"Set Color %@", col);
// }

// void rehax::View::setTextColor(rehax::Color color)
// {
//   // NSView * view = (__bridge NSView *) nativeView;
//   // [view setTextColor:[NSColor colorWithRed:color.r green:color.g blue:color.b alpha:color.a]];
// }

// void rehax::View::setOpacity(float opacity)
// {
//   NSView * view = (__bridge NSView *) nativeView;
//   [view setAlphaValue:opacity];
// }

// void rehax::View::addGesture(rehax::Gesture nativeGesture)
// {
//   NSView * view = (__bridge NSView *) nativeView;
//   NSGestureRecognizer * rec = (__bridge NSGestureRecognizer *) nativeGesture.native;

//   [view addGestureRecognizer:rec];
// }

// rehax::ILayout::~ILayout()
// {}