#include "Text.h"
#include "../../../base.h"
#include "../../../fluxe/fluxe/misc/Object.h"
#include "../../../fluxe/fluxe/views/Text.h"
#include <iostream>

using namespace rehax::ui::fluxe::impl;


template <typename Container>
void Text<Container>::createNativeView()
{
  auto view = ::fluxe::Object<::fluxe::Text>::Create();
  view->increaseReferenceCount();
  this->nativeView = view.get();
}

template <typename Container>
void Text<Container>::setText(std::string text)
{
  auto view = static_cast<::fluxe::Text *>(this->nativeView);
  view->setText(text);
}

template <typename Container>
std::string Text<Container>::getText()
{
  auto view = static_cast<::fluxe::Text *>(this->nativeView);
//  view->getText();
}

template <typename Container>
void Text<Container>::setTextColor(rehax::ui::Color color)
{
  auto view = static_cast<::fluxe::Text *>(this->nativeView);
  view->setTextColor(::fluxe::Color::RGBA(color.r, color.g, color.b, color.a));
}

template <typename Container>
void Text<Container>::setFontSize(float size)
{
  auto view = static_cast<::fluxe::Text *>(this->nativeView);
  view->setTextSize(size);
}

template <typename Container>
void Text<Container>::setFontFamilies(std::vector<std::string> fontFamilies)
{
  auto view = static_cast<::fluxe::Text *>(this->nativeView);
  view->setFontFamilies(fontFamilies);
}

template class rehax::ui::fluxe::impl::Text<rehax::ui::RawPtr<rehax::ui::JscRegisteredClass>>;
