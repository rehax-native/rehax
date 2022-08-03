#include "pch.h"
#include "NativeTextInput.h"
#include "../../view/cpp/NativeView.win.h"

void NativeTextInput::createFragment()
{
    Controls::TextBox box;
    UIElement element = box.try_as<UIElement>();
    auto wrapper = new NativeViewWrapper { element };
    nativeView = (void*) wrapper;
}

void NativeTextInput::setText(const char * text)
{
    NativeViewWrapper * wrapper = (NativeViewWrapper * ) nativeView;
    size_t size = strlen(text) + 1;
    wchar_t* wcstring = new wchar_t[size];
    size_t convertedChars = 0;
    mbstowcs_s(&convertedChars, wcstring, size, text, _TRUNCATE);
    if (Controls::TextBox box = wrapper->element.try_as<Controls::TextBox>()) {
        box.Text(wcstring);
    }
}

const char * NativeTextInput::getText()
{
    return "No text";
}

void NativeTextInput::setPlaceholder(const char *text)
{
    NativeViewWrapper * wrapper = (NativeViewWrapper * ) nativeView;
    size_t size = strlen(text) + 1;
    wchar_t* wcstring = new wchar_t[size];
    size_t convertedChars = 0;
    mbstowcs_s(&convertedChars, wcstring, size, text, _TRUNCATE);
    if (Controls::TextBox box = wrapper->element.try_as<Controls::TextBox>()) {
        box.PlaceholderText(wcstring);
    }
}

void NativeTextInput::setTextColor(NativeColor color)
{}

void NativeTextInput::addView(NativeView * child)
{}
