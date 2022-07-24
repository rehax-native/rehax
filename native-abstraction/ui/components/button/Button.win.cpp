#include "pch.h"
#include "./Button.h"
#include "../view/View.win.h"

void rehax::Button::createFragment()
{
    Controls::Button btn;
    UIElement element = btn.try_as<UIElement>();
    auto wrapper = new NativeViewWrapper { element };
    nativeView = (void*) wrapper;
}

void rehax::Button::setText(const char * text)
{
    NativeViewWrapper * wrapper = (NativeViewWrapper * ) nativeView;
    Controls::TextBlock textBlock;

    size_t size = strlen(text) + 1;
    wchar_t* wcstring = new wchar_t[size];
    size_t convertedChars = 0;
    mbstowcs_s(&convertedChars, wcstring, size, text, _TRUNCATE);
    textBlock.Text(wcstring);
    if (Controls::Button button = wrapper->element.try_as<Controls::Button>()) {
        button.Content(textBlock);
    }
}

const char * rehax::Button::getText()
{
    return "No text";
}

void rehax::Button::setTextColor(NativeColor color)
{}

void rehax::Button::setOnClick(std::function<void(void)> onClick)
{
    NativeViewWrapper* wrapper = (NativeViewWrapper*)nativeView;
    if (Controls::Button button = wrapper->element.try_as<Controls::Button>()) {
        button.Tapped([onClick](auto&, auto&) {
            onClick();
        });
    }
}