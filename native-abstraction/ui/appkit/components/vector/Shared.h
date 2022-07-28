#pragma once

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

namespace rehax::ui::appkit::impl {

CAShapeLayer * getShapeAtIndex(CALayer * layer, int index);
CGMutablePathRef getPathAtIndex(CALayer * layer, int index);
double vectorAngle(double ux, double uy, double vx, double vy);
CGPoint mapToEllipse(double x, double y, double rx, double ry, double cosphi, double sinphi, double centerx, double centery);

}
