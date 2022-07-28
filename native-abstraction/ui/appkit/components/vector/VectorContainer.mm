#include "VectorContainer.h"
#include "../../../base.h"
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#include <iostream>

namespace rehax::ui::appkit::impl {

template <typename Container>
void VectorContainer<Container>::createNativeView() {

  View<Container>::createNativeView();

  NSView * view = (__bridge NSView *) this->nativeView;
  view.layer = [CALayer layer];
  view.layer.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
}

template <typename Container>
void VectorContainer<Container>::addNativeView(void * child) {
  NSView * view = (__bridge NSView *) this->nativeView;
  CALayer * childView = (__bridge CALayer *) child;
  childView.frame = view.layer.bounds;
  [view.layer addSublayer:childView];
}

template <typename Container>
void VectorContainer<Container>::addNativeView(void * child, void * beforeView) {
  NSView * view = (__bridge NSView *) this->nativeView;
  CALayer * childView = (__bridge CALayer *) child;
  childView.frame = view.layer.bounds;
  [view.layer addSublayer:childView]; // ??
}

}
