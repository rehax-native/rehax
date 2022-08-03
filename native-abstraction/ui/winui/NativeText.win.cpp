#include "pch.h"
#include "NativeText.h"
#include "../../view/cpp/NativeView.win.h"

void NativeText::createFragment()
{
    Controls::TextBlock text;
    UIElement element = text.try_as<UIElement>();
    auto wrapper = new NativeViewWrapper { element };
    nativeView = (void*) wrapper;
}

void NativeText::setText(const char * text)
{
    NativeViewWrapper * wrapper = (NativeViewWrapper * ) nativeView;
    size_t size = strlen(text) + 1;
    wchar_t* wcstring = new wchar_t[size];
    size_t convertedChars = 0;
    mbstowcs_s(&convertedChars, wcstring, size, text, _TRUNCATE);
    if (Controls::TextBlock textBlock = wrapper->element.try_as<Controls::TextBlock>()) {
        textBlock.Text(wcstring);
    }
}

const char * NativeText::getText()
{
    return "No text";
}

void NativeText::setTextColor(NativeColor color)
{}

void NativeText::addView(NativeView * child)
{}
