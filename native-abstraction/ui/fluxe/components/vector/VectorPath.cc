#include <vector>
#include <iostream>
#include "../../../style.h"
#include "./VectorPath.h"
#include "../../../fluxe/fluxe/views/View.h"
#include "./FluxeVectorElement.h"

using namespace rehax::ui::fluxe::impl;

#include "../../../shared/components/VectorPath.cc"

class VectorOperation : public Object<VectorOperation> {
public:
  virtual void draw(ObjectPointer<::fluxe::ViewBuilder> builder, SkPath * path) {}
};
//class BeginPath : public VectorOperation {
//public:
//  virtual void draw(ObjectPointer<::fluxe::ViewBuilder> builder, SkPath * path) override {
//      path = new SkPath();
//  }
//};
//class EndPath : public VectorOperation {
//public:
//  virtual void draw(ObjectPointer<::fluxe::ViewBuilder> builder, SkPath * path) override {
//      SkPaint paint; // todo
//      paint.setStyle(SkPaint::kFill_Style);
//      paint.setColor(::fluxe::Color::RGBA(1.0, 0, 0, 1).color);
//      builder->getCanvas()->drawPath(*path, paint);
//      delete path;
//      path = nullptr;
//  }
//};
class ClosePath : public VectorOperation {
public:
  virtual void draw(ObjectPointer<::fluxe::ViewBuilder> builder, SkPath * path) override {
    path->close();
  }
};
class LineTo : public VectorOperation {
public:
  float x, y;
  virtual void draw(ObjectPointer<::fluxe::ViewBuilder> builder, SkPath * path) override {
    path->lineTo(x, y);
  }
};
class MoveTo : public VectorOperation {
public:
  float x, y;
  virtual void draw(ObjectPointer<::fluxe::ViewBuilder> builder, SkPath * path) override {
    path->moveTo(x, y);
  }
};
class MoveBy : public VectorOperation {
public:
  float x, y;
  virtual void draw(ObjectPointer<::fluxe::ViewBuilder> builder, SkPath * path) override {
    path->rMoveTo(x, y);
  }
};
//class HorizontalTo : public VectorOperation {
//public:
//  float x;
//  virtual void draw(ObjectPointer<::fluxe::ViewBuilder> builder, SkPath * path) override {
//    path->rMoveTo(x, 0);
//  }
//};
class Arc : public VectorOperation {
public:
  float rx, ry, xAxisRotation, endX, endY;
  int largeArcFlag, sweepFlag;
    
  virtual void draw(ObjectPointer<::fluxe::ViewBuilder> builder, SkPath * path) override {
    path->arcTo(
      rx,
      ry,
      xAxisRotation,
      largeArcFlag > 0 ? SkPath::ArcSize::kLarge_ArcSize : SkPath::ArcSize::kSmall_ArcSize,
      sweepFlag > 0 ? SkPathDirection::kCW : SkPathDirection::kCW,
      endX,
      endY
    );
  }
};
class CubicBezier : public VectorOperation {
public:
  float x1, y1, x2, y2, x, y;
    
  virtual void draw(ObjectPointer<::fluxe::ViewBuilder> builder, SkPath * path) override {
    path->cubicTo(x1, y1, x2, y2, x, y);
  }
};
class QuadraticBezier : public VectorOperation {
public:
  float x1, y1, x, y;
    
  virtual void draw(ObjectPointer<::fluxe::ViewBuilder> builder, SkPath * path) override {
    path->quadTo(x1, y1, x, y);
  }
};


class FluxeVectorPath : public FluxeVectorElement {
public:
  // void measureLayout(LayoutConstraint constraints, PossibleLayoutSize parentSize) override;
  void build(ObjectPointer<::fluxe::ViewBuilder> builder) override;
  std::vector<ObjectPointer<VectorOperation>> operations;

};

void FluxeVectorPath::build(ObjectPointer<::fluxe::ViewBuilder> builder) {
  SkPath path;
  for (auto op : operations) {
    op->draw(builder, &path);
  }
  if (strokeColor.a > 0 || strokeGradient.stops.size() > 0) {
    SkPaint strokePaint;
    strokePaint.setStyle(SkPaint::kStroke_Style);
    strokePaint.setStrokeWidth(lineWidth);
    switch (lineCap) {
      case rehax::ui::VectorLineCap::Butt:
        strokePaint.setStrokeCap(SkPaint::kButt_Cap);
        break;
      case rehax::ui::VectorLineCap::Round:
        strokePaint.setStrokeCap(SkPaint::kRound_Cap);
        break;
      case rehax::ui::VectorLineCap::Square:
        strokePaint.setStrokeCap(SkPaint::kSquare_Cap);
        break;
    }
    switch (lineJoin) {
      case rehax::ui::VectorLineJoin::Miter:
        strokePaint.setStrokeJoin(SkPaint::kMiter_Join);
        break;
      case rehax::ui::VectorLineJoin::Round:
        strokePaint.setStrokeJoin(SkPaint::kRound_Join);
        break;
      case rehax::ui::VectorLineJoin::Bevel:
        strokePaint.setStrokeJoin(SkPaint::kBevel_Join);
        break;
    }
    if (strokeColor.a > 0) {
      strokePaint.setColor(::fluxe::Color::RGBA(strokeColor.r, strokeColor.g, strokeColor.b, strokeColor.a).color);
    }
    if (strokeGradient.stops.size() > 0) {
      std::vector<SkPoint> points { SkPoint::Make(0, 0), SkPoint::Make(0, 1) };
      std::vector<SkColor> colors;
      std::vector<SkScalar> positions;
      for (auto stop : strokeGradient.stops) {
        colors.push_back(::fluxe::Color::RGBA(stop.color.r, stop.color.g, stop.color.b, stop.color.a).color);
        positions.push_back(stop.offset);
      }
      auto shader = SkGradientShader::MakeLinear(points.data(), colors.data(), positions.data(), fillGradient.stops.size(), SkTileMode::kClamp, 0, nullptr);
      strokePaint.setShader(shader);
    }
      if (filters.defs.size() > 0) {
          auto imageFilter = sk_sp<SkImageFilter>();
          for (auto filter : filters.defs) {
              if (filter.type == 0) {
                  imageFilter = SkImageFilters::Blur(filter.blurRadius, filter.blurRadius, imageFilter);
              }
          }
          strokePaint.setImageFilter(imageFilter);
      }
    builder->getCanvas()->drawPath(path, strokePaint);
  }
  if (fillColor.a > 0 || fillGradient.stops.size() > 0) {
    SkPaint fillPaint;
    fillPaint.setStyle(SkPaint::kFill_Style);
    if (fillColor.a > 0) {
      fillPaint.setColor(::fluxe::Color::RGBA(fillColor.r, fillColor.g, fillColor.b, fillColor.a).color);
    }
    if (fillGradient.stops.size() > 0) {
      std::vector<SkPoint> points { SkPoint::Make(0, 0), SkPoint::Make(0, 1) };
      std::vector<SkColor> colors;
      std::vector<SkScalar> positions;
      for (auto stop : fillGradient.stops) {
        colors.push_back(::fluxe::Color::RGBA(stop.color.r, stop.color.g, stop.color.b, stop.color.a).color);
        positions.push_back(stop.offset);
      }
      auto shader = SkGradientShader::MakeLinear(points.data(), colors.data(), positions.data(), fillGradient.stops.size(), SkTileMode::kClamp, 0, nullptr);
      fillPaint.setShader(shader);
    }
      if (filters.defs.size() > 0) {
          auto imageFilter = sk_sp<SkImageFilter>();
          for (auto filter : filters.defs) {
              if (filter.type == 0) {
                  imageFilter = SkImageFilters::Blur(filter.blurRadius, filter.blurRadius, imageFilter);
              }
          }
          fillPaint.setImageFilter(imageFilter);
      }
    builder->getCanvas()->drawPath(path, fillPaint);
  }
    
  // ui::Color fillColor;
  // Gradient fillGradient;
  // Gradient strokeGradient;
  // Filters filters

}

std::string VectorPath::description() {
  std::ostringstream stringStream;
  stringStream << instanceClassName() << "/fluxe " << this;
  return stringStream.str();
}

void VectorPath::createNativeView() {
  auto view = ::rehaxUtils::Object<FluxeVectorPath>::Create();
  view->increaseReferenceCount();
  this->nativeView = view.get();
}

void VectorPath::beginPath() {
//  auto view = static_cast<FluxeVectorPath *>(this->nativeView);
//  view->operations.push_back(Object<BeginPath>::Create());
}

void VectorPath::pathHorizontalTo(float x) {
  // CALayer * layer = (__bridge CALayer *) this->nativeView;
  
  // CGMutablePathRef path = getPathAtIndex(layer, 0);
  // CGPoint p = CGPathGetCurrentPoint(path);
  // CGPathAddLineToPoint(path, nullptr, x, p.y);
  
  // path = getPathAtIndex(layer, 1);
  // p = CGPathGetCurrentPoint(path);
  // CGPathAddLineToPoint(path, nullptr, x, p.y);
}

void VectorPath::pathVerticalTo(float y) {
  // CALayer * layer = (__bridge CALayer *) this->nativeView;
  // CGMutablePathRef path = getPathAtIndex(layer, 0);
  
  // CGPoint p = CGPathGetCurrentPoint(path);
  // CGPathAddLineToPoint(path, nullptr, p.x, y);
  
  // path = getPathAtIndex(layer, 1);
  // p = CGPathGetCurrentPoint(path);
  // CGPathAddLineToPoint(path, nullptr, p.x, y);
}

void VectorPath::pathMoveTo(float x, float y) {
  auto view = static_cast<FluxeVectorPath *>(this->nativeView);
  auto op = Object<MoveTo>::Create();
  op->x = x;
  op->y = y;
  view->operations.push_back(op);
}

void VectorPath::pathMoveBy(float x, float y) {
  auto view = static_cast<FluxeVectorPath *>(this->nativeView);
  auto op = Object<MoveBy>::Create();
  op->x = x;
  op->y = y;
  view->operations.push_back(op);
}

void VectorPath::pathLineTo(float x, float y) {
  auto view = static_cast<FluxeVectorPath *>(this->nativeView);
  auto op = Object<LineTo>::Create();
  op->x = x;
  op->y = y;
  view->operations.push_back(op);
}

void VectorPath::pathArc(float rx, float ry, float xAxisRotation, int largeArcFlag, int sweepFlag, float endX, float endY) {
  auto view = static_cast<FluxeVectorPath *>(this->nativeView);
  auto op = Object<Arc>::Create();
  op->rx = rx;
  op->ry = ry;
  op->xAxisRotation = xAxisRotation;
  op->largeArcFlag = largeArcFlag;
  op->sweepFlag = sweepFlag;
  op->endX = endX;
  op->endY = endY;
  view->operations.push_back(op);
}

void VectorPath::pathCubicBezier(float x1, float y1, float x2, float y2, float x, float y) {
  auto view = static_cast<FluxeVectorPath *>(this->nativeView);
  auto op = Object<CubicBezier>::Create();
  op->x1 = x1;
  op->y1 = y1;
  op->x2 = x2;
  op->y2 = y2;
  op->x = x;
  op->y = y;
  view->operations.push_back(op);
}

void VectorPath::pathQuadraticBezier(float x1, float y1, float x, float y) {
  auto view = static_cast<FluxeVectorPath *>(this->nativeView);
  auto op = Object<QuadraticBezier>::Create();
  op->x1 = x1;
  op->y1 = y1;
  op->x = x;
  op->y = y;
  view->operations.push_back(op);
}

void VectorPath::pathClose() {
  auto view = static_cast<FluxeVectorPath *>(this->nativeView);
  view->operations.push_back(Object<ClosePath>::Create());
}

void VectorPath::endPath() {
//  auto view = static_cast<FluxeVectorPath *>(this->nativeView);
//  view->operations.push_back(Object<EndPath>::Create());
}
