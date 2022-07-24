#include "pch.h"
#include "./NativeVectorContainer.h"

void NativeVectorContainer::createFragment()
{}

void NativeVectorContainer::setDrawCallback(std::function<void(void)> cb)
{}

void NativeVectorContainer::setFillColor()
{}

void NativeVectorContainer::setStrokeColor()
{}

void NativeVectorContainer::beginPath()
{}

void NativeVectorContainer::pathHorizontalTo(float x)
{}

void NativeVectorContainer::pathVerticalTo(float y)
{}

void NativeVectorContainer::pathMoveTo(float x, float y)
{}

void NativeVectorContainer::pathMoveBy(float x, float y)
{}

void NativeVectorContainer::pathLineTo(float x, float y)
{}

void NativeVectorContainer::pathArc(float rx, float ry, float xAxisRotation, int largeArcFlag, int sweepFlag, float x, float y)
{}

void NativeVectorContainer::pathCubicBezier(float x1, float y1, float x2, float y2, float x, float y)
{}

void NativeVectorContainer::pathQuadraticBezier(float x1, float y1, float x, float y)
{}

void NativeVectorContainer::pathClose()
{}

void NativeVectorContainer::pathStroke(float width, int capsStyle, int joinStyle)
{}

void NativeVectorContainer::pathFill()
{}

void NativeVectorContainer::endPath()
{}
