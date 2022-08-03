#include "VectorElement.h"
#include "../../../base.h"
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#include <iostream>
#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import "Shared.h"

namespace rehax::ui::appkit::impl {

#include "../../../shared/components/VectorElement.cc"

void VectorElement::setLineWidth(float width) {
  CALayer * layer = (__bridge CALayer *) this->nativeView;
  CAShapeLayer * shapeLayer = getShapeAtIndex(layer, 1);
  shapeLayer.lineWidth = width;
}

void VectorElement::setLineCap(VectorLineCap capsStyle) {
  CALayer * layer = (__bridge CALayer *) this->nativeView;
  CAShapeLayer * shapeLayer = getShapeAtIndex(layer, 1);
  switch(capsStyle) {
    case VectorLineCap::Butt:
      shapeLayer.lineCap = kCALineCapButt;
      break;
    case VectorLineCap::Square:
      shapeLayer.lineCap = kCALineCapSquare;
      break;
    case VectorLineCap::Round:
      shapeLayer.lineCap = kCALineCapRound;
      break;
  }
}

void VectorElement::setLineJoin(VectorLineJoin joinStyle) {
  CALayer * layer = (__bridge CALayer *) this->nativeView;
  CAShapeLayer * shapeLayer = getShapeAtIndex(layer, 1);
  switch(joinStyle) {
    case VectorLineJoin::Miter:
      shapeLayer.lineJoin = kCALineJoinMiter;
      break;
    case VectorLineJoin::Round:
      shapeLayer.lineJoin = kCALineJoinRound;
      break;
    case VectorLineJoin::Bevel:
      shapeLayer.lineJoin = kCALineJoinBevel;
      break;
  }
}

void VectorElement::setFillColor(ui::Color color) {
  CALayer * layer = (__bridge CALayer *) this->nativeView;
  CAGradientLayer * fillLayer = (CAGradientLayer *) layer.sublayers[0];
  fillLayer.colors = @[
    (__bridge id) [NSColor colorWithRed:color.r green:color.g blue:color.b alpha:color.a].CGColor,
    (__bridge id) [NSColor colorWithRed:color.r green:color.g blue:color.b alpha:color.a].CGColor,
  ];
  fillLayer.frame = layer.bounds;
}

void VectorElement::setStrokeColor(ui::Color color) {
  CALayer * layer = (__bridge CALayer *) this->nativeView;
  CAGradientLayer * strokeLayer = (CAGradientLayer *) layer.sublayers[1];
  strokeLayer.colors = @[
    (__bridge id) [NSColor colorWithRed:color.r green:color.g blue:color.b alpha:color.a].CGColor,
    (__bridge id) [NSColor colorWithRed:color.r green:color.g blue:color.b alpha:color.a].CGColor,
  ];
}

void VectorElement::setFillGradient(Gradient gradient) {
  CALayer * layer = (__bridge CALayer *) this->nativeView;
  CAGradientLayer * fillLayer = (CAGradientLayer *) layer.sublayers[0];
  NSMutableArray * colorArr = [NSMutableArray array];
  NSMutableArray * locationArr = [NSMutableArray array];
  for (auto stop : gradient.stops) {
    [colorArr addObject:(__bridge id) [NSColor colorWithRed:stop.color.r green:stop.color.g blue:stop.color.b alpha:stop.color.a].CGColor];
    [locationArr addObject:[NSNumber numberWithFloat:stop.offset]];
  }
  fillLayer.startPoint = CGPointMake(0.02, 0);
  fillLayer.endPoint = CGPointMake(0.15, 0);
  
  fillLayer.colors = [NSArray arrayWithArray:colorArr];
  fillLayer.locations = [NSArray arrayWithArray:locationArr];
  fillLayer.frame = layer.bounds;
}

void VectorElement::setStrokeGradient(Gradient gradient) {
  CALayer * layer = (__bridge CALayer *) this->nativeView;
  CAGradientLayer * strokeLayer = (CAGradientLayer *) layer.sublayers[1];
  NSMutableArray * colorArr = [NSMutableArray array];
  NSMutableArray * locationArr = [NSMutableArray array];
  for (auto stop : gradient.stops) {
    [colorArr addObject:(__bridge id) [NSColor colorWithRed:stop.color.r green:stop.color.g blue:stop.color.b alpha:stop.color.a].CGColor];
    [locationArr addObject:[NSNumber numberWithFloat:stop.offset]];
  }
  strokeLayer.startPoint = CGPointMake(0.02, 0);
  strokeLayer.endPoint = CGPointMake(0.15, 0);
  
  strokeLayer.colors = [NSArray arrayWithArray:colorArr];
  strokeLayer.locations = [NSArray arrayWithArray:locationArr];
  strokeLayer.frame = layer.bounds;
}

void VectorElement::setFilters(Filters filters) {
  CALayer * layer = (__bridge CALayer *) this->nativeView;
//    CIFilter * filter = [CIGau]
//    filter.radius = 10;
  
  NSMutableArray * array = [NSMutableArray new];
  for (auto & filter : filters.defs) {
    if (filter.type == 0) {
      CIFilter * _blurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
      [_blurFilter setDefaults];
      [_blurFilter setValue:[NSNumber numberWithFloat:filter.blurRadius] forKey:@"inputRadius"];
      [array addObject:_blurFilter];
    }
  }
  
  layer.filters = array;
}


}
