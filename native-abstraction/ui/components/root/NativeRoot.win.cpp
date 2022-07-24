#include "pch.h"
#include "NativeRoot.h"
#include "../../view/cpp/NativeView.win.h"

UIElement rootElement{ nullptr };

void setRootElement(UIElement element)
{
    rootElement = element;
}

UIElement getRootElement()
{
    return rootElement;
}

void NativeRoot::initialize(std::function<void(void)> onReady)
{
    onReady();
}

void NativeRoot::createFragment()
{
}

void NativeRoot::addView(NativeView * child)
{
    NativeViewWrapper * wrapper = (NativeViewWrapper*) child->nativeView;
    UIElement element = wrapper->element;
    Controls::StackPanel root = rootElement.try_as<Controls::StackPanel>();
    root.Children().Append(element);
}