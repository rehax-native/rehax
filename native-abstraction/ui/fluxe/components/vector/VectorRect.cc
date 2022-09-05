#include <vector>
#include <iostream>
#include "../../../style.h"
#include "./VectorRect.h"
#include <fluxe/views/View.h>
#include "./FluxeVectorElement.h"

using namespace rehax::ui::fluxe::impl;

#include "../../../shared/components/VectorRect.cc"

class FluxeVectorRect : public FluxeVectorElement {
public:
  // void measureLayout(LayoutConstraint constraints, PossibleLayoutSize parentSize) override;
  void build(ObjectPointer<::fluxe::ViewBuilder> builder) override;
    SkRect rect;
};

void FluxeVectorRect::build(ObjectPointer<::fluxe::ViewBuilder> builder) {
  if (strokeColor.a > 0 || strokeGradient.stops.size() > 0) {
    SkPaint strokePaint;
    strokePaint.setAntiAlias(true);
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
    builder->getCanvas()->drawRect(rect, strokePaint);
  }
  if (fillColor.a > 0 || fillGradient.stops.size() > 0) {
    SkPaint fillPaint;
    fillPaint.setAntiAlias(true);
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
    builder->getCanvas()->drawRect(rect, fillPaint);
  }
    
  // ui::Color fillColor;
  // Gradient fillGradient;
  // Gradient strokeGradient;
  // Filters filters

}

std::string VectorRect::description() {
  std::ostringstream stringStream;
  stringStream << instanceClassName() << "/fluxe " << this;
  return stringStream.str();
}

void VectorRect::createNativeView() {
  auto view = ::rehaxUtils::Object<FluxeVectorRect>::Create();
  view->increaseReferenceCount();
  this->nativeView = view.get();
}

void VectorRect::setSize(rehax::ui::Size size) {
  auto view = static_cast<FluxeVectorRect *>(this->nativeView);
  view->rect = SkRect::MakeXYWH(0, 0, size.width, size.height);
  view->setNeedsRerender(true);
}
