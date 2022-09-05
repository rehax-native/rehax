#include <vector>
#include <iostream>
#include "../../../style.h"
#include "./VectorRect.h"
#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import "Shared.h"

using namespace rehax::ui::appkit::impl;

#include "../../../shared/components/VectorRect.cc"

std::string VectorRect::description() {
  std::ostringstream stringStream;
  stringStream << instanceClassName() << "/CALayer (Appkit) " << this;
  return stringStream.str();
}

void VectorRect::createNativeView() {
  CALayer * layer = [CALayer layer];
  layer.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
  
  CAGradientLayer * fillGradientLayer = [CAGradientLayer layer];
  fillGradientLayer.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
  CAGradientLayer * strokeGradientLayer = [CAGradientLayer layer];
  strokeGradientLayer.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
  
  CAShapeLayer * fillLayer = [CAShapeLayer layer];
  fillLayer.fillColor = [NSColor whiteColor].CGColor;
  fillLayer.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
  fillGradientLayer.mask = fillLayer;
  
  CAShapeLayer * strokeLayer = [CAShapeLayer layer];
  strokeLayer.fillColor = [NSColor clearColor].CGColor;
  strokeLayer.strokeColor = [NSColor whiteColor].CGColor;
  strokeLayer.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
  strokeGradientLayer.mask = strokeLayer;
  
  [layer addSublayer:fillGradientLayer];
  [layer addSublayer:strokeGradientLayer];
  
  this->nativeView = (__bridge void *) layer;
}

void VectorRect::setSize(rehax::ui::Size size) {
  CAShapeLayer * layer = (__bridge CAShapeLayer *) this->nativeView;

  CAShapeLayer * fillLayer = (CAShapeLayer *) layer.sublayers[0].mask;
  CAShapeLayer * strokeLayer = (CAShapeLayer *) layer.sublayers[1].mask;

  CGPathRef path = CGPathCreateWithRect(CGRectMake(0, 0, size.width, size.height), nil);

  fillLayer.path = path;
  strokeLayer.path = path;

  [layer setNeedsDisplay];
}
