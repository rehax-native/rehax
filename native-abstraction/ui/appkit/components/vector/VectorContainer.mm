#include "VectorContainer.h"
#include "../../../base.h"
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#include <iostream>

namespace rehax::ui::appkit::impl {

#include "../../../shared/components/VectorContainer.cc"

std::string VectorContainer::description() {
  std::ostringstream stringStream;
  stringStream << instanceClassName() << "/CALayer (Appkit) " << this;
  return stringStream.str();
}

void VectorContainer::createNativeView() {
  View::createNativeView();

  NSView * view = (__bridge NSView *) this->nativeView;
  view.layer = [CALayer layer];
  // view.layer.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
}

void VectorContainer::addNativeView(void * child) {
  NSView * view = (__bridge NSView *) this->nativeView;
  CALayer * childView = (__bridge CALayer *) child;
  childView.frame = view.layer.bounds;
  [view.layer addSublayer:childView];
}

void VectorContainer::addNativeView(void * child, void * beforeView) {
  NSView * view = (__bridge NSView *) this->nativeView;
  CALayer * childView = (__bridge CALayer *) child;
  childView.frame = view.layer.bounds;
  [view.layer addSublayer:childView]; // ??
}

}
