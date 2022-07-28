#include "Shared.h"

namespace rehax::ui::appkit::impl {

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

double vectorAngle(double ux, double uy, double vx, double vy)
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

CGPoint mapToEllipse(double x, double y, double rx, double ry, double cosphi, double sinphi, double centerx, double centery)
{
  x *= rx;
  y *= ry;
  
  const double xp = cosphi * x - sinphi * y;
  const double yp = sinphi * x + cosphi * y;
  
  return CGPointMake((CGFloat)(xp + centerx), (CGFloat)(yp + centery));
}

}
