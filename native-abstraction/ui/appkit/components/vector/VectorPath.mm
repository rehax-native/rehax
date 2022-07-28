#include <vector>
#include <iostream>
#include "../../../style.h"
#include "./VectorPath.h"
#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import "Shared.h"

using namespace rehax::ui::appkit::impl;

template <typename Container>
void VectorPath<Container>::createNativeView() {
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

template <typename Container>
void VectorPath<Container>::beginPath() {
  CALayer * layer = (__bridge CALayer *) this->nativeView;
  
  CAShapeLayer * fillLayer = (CAShapeLayer *) layer.sublayers[0].mask;
  CAShapeLayer * strokeLayer = (CAShapeLayer *) layer.sublayers[1].mask;
  
  CGPathRef path = CGPathCreateMutable();
  fillLayer.path = path;
  
  path = CGPathCreateMutable();
  strokeLayer.path = path;
}

template <typename Container>
void VectorPath<Container>::pathHorizontalTo(float x) {
  CALayer * layer = (__bridge CALayer *) this->nativeView;
  
  CGMutablePathRef path = getPathAtIndex(layer, 0);
  CGPoint p = CGPathGetCurrentPoint(path);
  CGPathAddLineToPoint(path, nullptr, x, p.y);
  
  path = getPathAtIndex(layer, 1);
  p = CGPathGetCurrentPoint(path);
  CGPathAddLineToPoint(path, nullptr, x, p.y);
}

template <typename Container>
void VectorPath<Container>::pathVerticalTo(float y) {
  CALayer * layer = (__bridge CALayer *) this->nativeView;
  CGMutablePathRef path = getPathAtIndex(layer, 0);
  
  CGPoint p = CGPathGetCurrentPoint(path);
  CGPathAddLineToPoint(path, nullptr, p.x, y);
  
  path = getPathAtIndex(layer, 1);
  p = CGPathGetCurrentPoint(path);
  CGPathAddLineToPoint(path, nullptr, p.x, y);
}

template <typename Container>
void VectorPath<Container>::pathMoveTo(float x, float y) {
  CALayer * layer = (__bridge CALayer *) this->nativeView;
  CGMutablePathRef path = getPathAtIndex(layer, 0);
  CGPathMoveToPoint(path, nullptr, x, y);
  
  path = getPathAtIndex(layer, 1);
  CGPathMoveToPoint(path, nullptr, x, y);
}

template <typename Container>
void VectorPath<Container>::pathMoveBy(float x, float y) {
  CALayer * layer = (__bridge CALayer *) this->nativeView;
  CGMutablePathRef path = getPathAtIndex(layer, 0);
  
  CGPoint p = CGPathGetCurrentPoint(path);
  CGPathMoveToPoint(path, nullptr, p.x + x, p.y + y);
  
  path = getPathAtIndex(layer, 1);
  p = CGPathGetCurrentPoint(path);
  CGPathMoveToPoint(path, nullptr, p.x + x, p.y + y);
}

template <typename Container>
void VectorPath<Container>::pathLineTo(float x, float y) {
  CALayer * layer = (__bridge CALayer *) this->nativeView;
  CGMutablePathRef path = getPathAtIndex(layer, 0);
  CGPathAddLineToPoint(path, nullptr, x, y);
  
  path = getPathAtIndex(layer, 1);
  CGPathAddLineToPoint(path, nullptr, x, y);
}

template <typename Container>
void VectorPath<Container>::pathArc(float rx, float ry, float xAxisRotation, int largeArcFlag, int sweepFlag, float endX, float endY) {
  CALayer * layer = (__bridge CALayer *) this->nativeView;
  CGMutablePathRef path1 = getPathAtIndex(layer, 0);
  CGMutablePathRef path2 = getPathAtIndex(layer, 1);
  
  CGPoint p = CGPathGetCurrentPoint(path1);
  
  double const px = p.x;
  double const py = p.y;
  double const cx = endX;
  double const cy = endY;
  
  const double TAU = M_PI * 2.0;
  
  const double sinphi = sin(xAxisRotation * TAU / 360);
  const double cosphi = cos(xAxisRotation * TAU / 360);
  
  const double pxp = cosphi * (px - cx) / 2 + sinphi * (py - cy) / 2;
  const double pyp = -sinphi * (px - cx) / 2 + cosphi * (py - cy) / 2;
  
  if (pxp == 0 && pyp == 0) {
    return;
  }
  
  rx = abs(rx);
  ry = abs(ry);
  
  const double lambda = (CGFloat) (pow(pxp, 2) / pow(rx, 2) + pow(pyp, 2) / pow(ry, 2));
  
  if (lambda > 1) {
    rx *= sqrt(lambda);
    ry *= sqrt(lambda);
  }
  
  const double rxsq =  pow(rx, 2);
  const double rysq =  pow(ry, 2);
  const double pxpsq =  pow(pxp, 2);
  const double pypsq =  pow(pyp, 2);
  
  double radicant = (rxsq * rysq) - (rxsq * pypsq) - (rysq * pxpsq);
  
  if (radicant < 0) {
    radicant = 0;
  }
  
  radicant /= (rxsq * pypsq) + (rysq * pxpsq);
  radicant = sqrt(radicant) * (largeArcFlag == sweepFlag ? -1 : 1);
  
  const double centerxp = radicant * rx / ry * pyp;
  const double centeryp = radicant * -ry / rx * pxp;
  
  const double centerx = cosphi * centerxp - sinphi * centeryp + (px + cx) / 2;
  const double centery = sinphi * centerxp + cosphi * centeryp + (py + cy) / 2;
  
  const double vx1 = (pxp - centerxp) / rx;
  const double vy1 = (pyp - centeryp) / ry;
  const double vx2 = (-pxp - centerxp) / rx;
  const double vy2 = (-pyp - centeryp) / ry;
  
  double ang1 = vectorAngle(1, 0, vx1, vy1);
  double ang2 = vectorAngle(vx1, vy1, vx2, vy2);
  
  if (sweepFlag == 0 && ang2 > 0) {
    ang2 -= TAU;
  }
  
  if (sweepFlag == 1 && ang2 < 0) {
    ang2 += TAU;
  }
  
  const int segments = (int) MAX(ceil(abs(ang2) / (TAU / 4.0)), 1.0);
  
  ang2 /= segments;
  
  for (int i = 0; i < segments; i++) {
    
    const double a = 4.0 / 3.0 * tan(ang2 / 4.0);
    
    const double x1 = cos(ang1);
    const double y1 = sin(ang1);
    const double x2 = cos(ang1 + ang2);
    const double y2 = sin(ang1 + ang2);
    
    CGPoint p1 = mapToEllipse(x1 - y1 * a, y1 + x1 * a, rx, ry, cosphi, sinphi, centerx, centery);
    CGPoint p2 = mapToEllipse(x2 + y2 * a, y2 - x2 * a, rx, ry, cosphi, sinphi, centerx, centery);
    CGPoint p = mapToEllipse(x2, y2, rx, ry, cosphi, sinphi, centerx, centery);
    
    CGPathAddCurveToPoint(path1, nullptr, p1.x, p1.y, p2.x, p2.y, p.x, p.y);
    CGPathAddCurveToPoint(path2, nullptr, p1.x, p1.y, p2.x, p2.y, p.x, p.y);
    
    ang1 += ang2;
  }
}

template <typename Container>
void VectorPath<Container>::pathCubicBezier(float x1, float y1, float x2, float y2, float x, float y) {
  CALayer * layer = (__bridge CALayer *) this->nativeView;
  CGMutablePathRef path = getPathAtIndex(layer, 0);
  CGPathAddCurveToPoint(path, nullptr, x1, y1, x2, y2, x, y);
  
  path = getPathAtIndex(layer, 1);
  CGPathAddCurveToPoint(path, nullptr, x1, y1, x2, y2, x, y);
}

template <typename Container>
void VectorPath<Container>::pathQuadraticBezier(float x1, float y1, float x, float y) {
  CALayer * layer = (__bridge CALayer *) this->nativeView;
  CGMutablePathRef path1 = getPathAtIndex(layer, 0);
  CGMutablePathRef path2 = getPathAtIndex(layer, 1);
  CGPoint p = CGPathGetCurrentPoint(path1);
  
  CGPoint p1 = CGPointMake(p.x + (x1 - p.x) * 2.0 / 3.0, p.y + (y1 - p.y) * 2.0 / 3.0);
  CGPoint p2 = CGPointMake(p1.x + (x - p.x) / 3.0, p1.y + (y - p.y) / 3.0);
  
  CGPathAddCurveToPoint(path1, nullptr, p1.x, p1.y, p2.x, p2.y, x, y);
  CGPathAddCurveToPoint(path2, nullptr, p1.x, p1.y, p2.x, p2.y, x, y);
}

template <typename Container>
void VectorPath<Container>::pathClose() {
  CALayer * layer = (__bridge CALayer *) this->nativeView;
  CGMutablePathRef path1 = getPathAtIndex(layer, 0);
  CGMutablePathRef path2 = getPathAtIndex(layer, 1);
  CGPathCloseSubpath(path1);
  CGPathCloseSubpath(path2);
}

template <typename Container>
void VectorPath<Container>::endPath() {
  CAShapeLayer * layer = (__bridge CAShapeLayer *) this->nativeView;
  [layer setNeedsDisplay];
}
