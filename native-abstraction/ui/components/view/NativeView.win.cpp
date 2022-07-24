#include "pch.h"
#include "NativeView.h"
#include "NativeView.win.h"

NativePosition NativePosition::create(float x, float y)
{
  NativePosition pos;
  pos.x = x;
  pos.y = y;
  return pos;
}

NativeSize NativeSize::create(float width, float height)
{
  NativeSize size;
  size.width = width;
  size.height = height;
  return size;
}

NativeFrame NativeFrame::create(NativePosition position, NativeSize size)
{
  NativeFrame frame;
  frame.position = position;
  frame.size = size;
  return frame;
}

NativeColor NativeColor::create(float r, float g, float b, float a)
{
  NativeColor color;
  color.r = r;
  color.g = g;
  color.b = b;
  color.a = a;
  return color;
}

void NativeView::createFragment()
{
	Controls::StackPanel grid;
	auto wrapper = new NativeViewWrapper { grid };
	nativeView = (void*) wrapper;
}

void NativeView::addView(NativeView *child)
{
	NativeViewWrapper* wrapper = (NativeViewWrapper*)nativeView;
	NativeViewWrapper* childWrapper = (NativeViewWrapper*)child->nativeView;
	Controls::StackPanel root = wrapper->element.try_as<Controls::StackPanel>();
	root.Children().Append(childWrapper->element);
}

void NativeView::removeView(NativeView *child)
{}

void NativeView::removeFromParent()
{}

void NativeView::setWidthFill()
{}

void NativeView::setHeightFill()
{}

void NativeView::setWidthNatural()
{}

void NativeView::setHeightNatural()
{}

void NativeView::setWidthFixed(float width)
{}

void NativeView::setHeightFixed(float height)
{}

void NativeView::setWidthPercentage(float percent)
{}

void NativeView::setHeightPercentage(float percent)
{}

void NativeView::setWidthFlex(float flex, float totalFlex)
{}

void NativeView::setHeightFlex(float flex, float totalFlex)
{}

void NativeView::setVerticalPositionNatural(NativeView *previousView)
{}

void NativeView::setHorizontalPositionNatural(NativeView *previousView)
{}

void NativeView::setVerticalPositionFixed(float x)
{}

void NativeView::setHorizontalPositionFixed(float y)
{}

void NativeView::setBackgroundColor(NativeColor color)
{}

void NativeView::setTextColor(NativeColor color)
{}

void NativeView::setOpacity(float opacity)
{}
