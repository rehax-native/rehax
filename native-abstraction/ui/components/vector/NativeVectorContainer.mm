#include "NativeVectorContainer.h"
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

CAShapeLayer * getShapeAtIndex(CALayer * layer, int index)
{
  CAGradientLayer * gradientLayer = (CAGradientLayer *) layer.sublayers[index];
  CAShapeLayer * shapeLayer = (CAShapeLayer *) gradientLayer.mask;
  return shapeLayer;
}

CGMutablePathRef getPathAtIndex(CALayer * layer, int index)
{
  CAShapeLayer * shapeLayer = getShapeAtIndex(layer, index);
  CGMutablePathRef path = (CGMutablePathRef) shapeLayer.path;
  return path;
}

void NativeVectorContainer::createFragment() {
  NativeView::createFragment();
  NSView * view = (__bridge NSView *) nativeView;
  view.layer = [CALayer layer];
  view.layer.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
}

void NativeVectorContainer::addView(NativeView *child)
{
  NSView * view = (__bridge NSView *) nativeView;
  CALayer * childView = (__bridge CALayer *) child->nativeView;
  childView.frame = view.layer.bounds;
  [view.layer addSublayer:childView];
}


void NativeVectorElement::setWidthNatural()
{}

void NativeVectorElement::setHeightNatural()
{}

void NativeVectorElement::setVerticalPositionNatural(NativeView *previousView)
{}

void NativeVectorElement::setHorizontalPositionNatural(NativeView *previousView)
{}

void NativeVectorElement::setLineWidth(float width)
{
  CALayer * layer = (__bridge CALayer *) nativeView;
  CAShapeLayer * shapeLayer = getShapeAtIndex(layer, 1);
  shapeLayer.lineWidth = width;
}

void NativeVectorElement::setLineCap(int capsStyle)
{
  CALayer * layer = (__bridge CALayer *) nativeView;
  CAShapeLayer * shapeLayer = getShapeAtIndex(layer, 1);
  switch(capsStyle) {
    case 0:
      shapeLayer.lineCap = kCALineCapButt;
      break;
    case 1:
      shapeLayer.lineCap = kCALineCapSquare;
      break;
    case 2:
      shapeLayer.lineCap = kCALineCapRound;
      break;
  }
}

void NativeVectorElement::setLineJoin(int joinStyle)
{
  CALayer * layer = (__bridge CALayer *) nativeView;
  CAShapeLayer * shapeLayer = getShapeAtIndex(layer, 1);
  switch(joinStyle) {
    case 0:
      shapeLayer.lineJoin = kCALineJoinMiter;
      break;
    case 1:
      shapeLayer.lineJoin = kCALineJoinRound;
      break;
    case 2:
      shapeLayer.lineJoin = kCALineJoinBevel;
      break;
  }
}

void NativeVectorElement::setStrokeColor(NativeColor color)
{
  CALayer * layer = (__bridge CALayer *) nativeView;
  CAGradientLayer * strokeLayer = (CAGradientLayer *) layer.sublayers[1];
  strokeLayer.colors = @[
    (__bridge id) [NSColor colorWithRed:color.r/255.0 green:color.g/255.0 blue:color.b/255.0 alpha:color.a].CGColor,
    (__bridge id) [NSColor colorWithRed:color.r/255.0 green:color.g/255.0 blue:color.b/255.0 alpha:color.a].CGColor,
  ];
}

void NativeVectorElement::setFillColor(NativeColor color)
{
  CALayer * layer = (__bridge CALayer *) nativeView;
  CAGradientLayer * fillLayer = (CAGradientLayer *) layer.sublayers[0];
  fillLayer.colors = @[
    (__bridge id) [NSColor colorWithRed:color.r/255.0 green:color.g/255.0 blue:color.b/255.0 alpha:color.a].CGColor,
    (__bridge id) [NSColor colorWithRed:color.r/255.0 green:color.g/255.0 blue:color.b/255.0 alpha:color.a].CGColor,
  ];
  fillLayer.frame = layer.bounds;
}

void NativeVectorElement::setFillGradient(NativeGradient gradient)
{
  CALayer * layer = (__bridge CALayer *) nativeView;
  CAGradientLayer * fillLayer = (CAGradientLayer *) layer.sublayers[0];
  NSMutableArray * colorArr = [NSMutableArray array];
  NSMutableArray * locationArr = [NSMutableArray array];
  for (auto stop : gradient.stops) {
    [colorArr addObject:(__bridge id) [NSColor colorWithRed:stop.color.r/255.0 green:stop.color.g/255.0 blue:stop.color.b/255.0 alpha:stop.color.a].CGColor];
    [locationArr addObject:[NSNumber numberWithFloat:stop.offset]];
  }
  fillLayer.startPoint = CGPointMake(0.02, 0);
  fillLayer.endPoint = CGPointMake(0.15, 0);
  
  fillLayer.colors = [NSArray arrayWithArray:colorArr];
  fillLayer.locations = [NSArray arrayWithArray:locationArr];
  fillLayer.frame = layer.bounds;
}

void NativeVectorElement::setStrokeGradient(NativeGradient gradient)
{
  CALayer * layer = (__bridge CALayer *) nativeView;
  CAGradientLayer * strokeLayer = (CAGradientLayer *) layer.sublayers[1];
  NSMutableArray * colorArr = [NSMutableArray array];
  NSMutableArray * locationArr = [NSMutableArray array];
  for (auto stop : gradient.stops) {
    [colorArr addObject:(__bridge id) [NSColor colorWithRed:stop.color.r/255.0 green:stop.color.g/255.0 blue:stop.color.b/255.0 alpha:stop.color.a].CGColor];
    [locationArr addObject:[NSNumber numberWithFloat:stop.offset]];
  }
  strokeLayer.startPoint = CGPointMake(0.02, 0);
  strokeLayer.endPoint = CGPointMake(0.15, 0);
  
  strokeLayer.colors = [NSArray arrayWithArray:colorArr];
  strokeLayer.locations = [NSArray arrayWithArray:locationArr];
  strokeLayer.frame = layer.bounds;
}

void NativeVectorElement::setFilters(NativeFilters filters)
{
  CALayer * layer = (__bridge CALayer *) nativeView;
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

void NativeVectorCircle::createFragment()
{
  CALayer * layer = [CALayer layer];
  layer.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
  
  CAGradientLayer * fillGradientLayer = [CAGradientLayer layer];
  fillGradientLayer.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
  
  CGPathRef path = CGPathCreateWithEllipseInRect(CGRectMake(5, 5, 90.0, 90.0), nullptr);
  CAShapeLayer * fillLayer = [CAShapeLayer layer];
  fillLayer.path = path;
  fillLayer.fillColor = [NSColor whiteColor].CGColor;
  
  fillLayer.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
  fillGradientLayer.mask = fillLayer;
  
  CAGradientLayer * strokeGradientLayer = [CAGradientLayer layer];
  strokeGradientLayer.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
  
  path = CGPathCreateWithEllipseInRect(CGRectMake(5, 5, 90.0, 90.0), nullptr);
  CAShapeLayer * strokeLayer = [CAShapeLayer layer];
  strokeLayer.path = path;
  strokeLayer.fillColor = [NSColor clearColor].CGColor;
  strokeLayer.strokeColor = [NSColor whiteColor].CGColor;
  
  strokeLayer.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
  strokeGradientLayer.mask = strokeLayer;
  
  [layer addSublayer:fillGradientLayer];
  [layer addSublayer:strokeGradientLayer];
  
  nativeView = (__bridge void *) layer;
}

void NativeVectorCircle::setCenterX(float cx)
{}

void NativeVectorCircle::setCenterY(float cy)
{}

void NativeVectorCircle::setRadius(float r)
{}


void NativeVectorPath::createFragment()
{
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
  
  nativeView = (__bridge void *) layer;
}

void NativeVectorPath::beginPath()
{
  CALayer * layer = (__bridge CALayer *) nativeView;
  
  CAShapeLayer * fillLayer = (CAShapeLayer *) layer.sublayers[0].mask;
  CAShapeLayer * strokeLayer = (CAShapeLayer *) layer.sublayers[1].mask;
  
  CGPathRef path = CGPathCreateMutable();
  fillLayer.path = path;
  
  path = CGPathCreateMutable();
  strokeLayer.path = path;
}

void NativeVectorPath::pathHorizontalTo(float x)
{
  CALayer * layer = (__bridge CALayer *) nativeView;
  
  CGMutablePathRef path = getPathAtIndex(layer, 0);
  CGPoint p = CGPathGetCurrentPoint(path);
  CGPathAddLineToPoint(path, nullptr, x, p.y);
  
  path = getPathAtIndex(layer, 1);
  p = CGPathGetCurrentPoint(path);
  CGPathAddLineToPoint(path, nullptr, x, p.y);
}

void NativeVectorPath::pathVerticalTo(float y)
{
  CALayer * layer = (__bridge CALayer *) nativeView;
  CGMutablePathRef path = getPathAtIndex(layer, 0);
  
  CGPoint p = CGPathGetCurrentPoint(path);
  CGPathAddLineToPoint(path, nullptr, p.x, y);
  
  path = getPathAtIndex(layer, 1);
  p = CGPathGetCurrentPoint(path);
  CGPathAddLineToPoint(path, nullptr, p.x, y);
}

void NativeVectorPath::pathMoveTo(float x, float y)
{
  CALayer * layer = (__bridge CALayer *) nativeView;
  CGMutablePathRef path = getPathAtIndex(layer, 0);
  CGPathMoveToPoint(path, nullptr, x, y);
  
  path = getPathAtIndex(layer, 1);
  CGPathMoveToPoint(path, nullptr, x, y);
}

void NativeVectorPath::pathMoveBy(float x, float y)
{
  CALayer * layer = (__bridge CALayer *) nativeView;
  CGMutablePathRef path = getPathAtIndex(layer, 0);
  
  CGPoint p = CGPathGetCurrentPoint(path);
  CGPathMoveToPoint(path, nullptr, p.x + x, p.y + y);
  
  path = getPathAtIndex(layer, 1);
  p = CGPathGetCurrentPoint(path);
  CGPathMoveToPoint(path, nullptr, p.x + x, p.y + y);
}

void NativeVectorPath::pathLineTo(float x, float y)
{
  CALayer * layer = (__bridge CALayer *) nativeView;
  CGMutablePathRef path = getPathAtIndex(layer, 0);
  CGPathAddLineToPoint(path, nullptr, x, y);
  
  path = getPathAtIndex(layer, 1);
  CGPathAddLineToPoint(path, nullptr, x, y);
}

static double vectorAngle(double ux, double uy, double vx, double vy)
{
  const double sign = (ux * vy - uy * vx < 0) ? -1 : 1;
  const double umag = sqrt(ux * ux + uy * uy);
  const double vmag = sqrt(ux * ux + uy * uy);
  const double dot = ux * vx + uy * vy;
  
  double div = dot / (umag * vmag);
  
  if (div > 1) {
    div = 1;
  }
  
  if (div < -1) {
    div = -1;
  }
  
  return sign * acos(div);
}

static CGPoint mapToEllipse(double x, double y, double rx, double ry, double cosphi, double sinphi, double centerx, double centery)
{
  x *= rx;
  y *= ry;
  
  const double xp = cosphi * x - sinphi * y;
  const double yp = sinphi * x + cosphi * y;
  
  return CGPointMake((CGFloat)(xp + centerx), (CGFloat)(yp + centery));
}

void NativeVectorPath::pathArc(float rx, float ry, float xAxisRotation, int largeArcFlag, int sweepFlag, float endX, float endY)
{
  CALayer * layer = (__bridge CALayer *) nativeView;
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

void NativeVectorPath::pathCubicBezier(float x1, float y1, float x2, float y2, float x, float y)
{
  CALayer * layer = (__bridge CALayer *) nativeView;
  CGMutablePathRef path = getPathAtIndex(layer, 0);
  CGPathAddCurveToPoint(path, nullptr, x1, y1, x2, y2, x, y);
  
  path = getPathAtIndex(layer, 1);
  CGPathAddCurveToPoint(path, nullptr, x1, y1, x2, y2, x, y);
}

void NativeVectorPath::pathQuadraticBezier(float x1, float y1, float x, float y)
{
  CALayer * layer = (__bridge CALayer *) nativeView;
  CGMutablePathRef path1 = getPathAtIndex(layer, 0);
  CGMutablePathRef path2 = getPathAtIndex(layer, 1);
  CGPoint p = CGPathGetCurrentPoint(path1);
  
  CGPoint p1 = CGPointMake(p.x + (x1 - p.x) * 2.0 / 3.0, p.y + (y1 - p.y) * 2.0 / 3.0);
  CGPoint p2 = CGPointMake(p1.x + (x - p.x) / 3.0, p1.y + (y - p.y) / 3.0);
  
  CGPathAddCurveToPoint(path1, nullptr, p1.x, p1.y, p2.x, p2.y, x, y);
  CGPathAddCurveToPoint(path2, nullptr, p1.x, p1.y, p2.x, p2.y, x, y);
}

void NativeVectorPath::pathClose()
{
  CALayer * layer = (__bridge CALayer *) nativeView;
  CGMutablePathRef path1 = getPathAtIndex(layer, 0);
  CGMutablePathRef path2 = getPathAtIndex(layer, 1);
  CGPathCloseSubpath(path1);
  CGPathCloseSubpath(path2);
}

void NativeVectorPath::endPath()
{
  CAShapeLayer * layer = (__bridge CAShapeLayer *) nativeView;
  [layer setNeedsDisplay];
}
