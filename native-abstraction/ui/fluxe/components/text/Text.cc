#include "Text.h"
#include "../../../base.h"
#include <fluxe/views/Text.h>
#include <iostream>

namespace rehax::ui::fluxe::impl {

#include "../../../shared/components/Text.cc"

std::string Text::description() {
  std::ostringstream stringStream;
  stringStream << instanceClassName() << "/fluxe " << this << ": " << getText();
  return stringStream.str();
}

void Text::createNativeView() {
  auto view = ::rehaxUtils::Object<::fluxe::Text>::Create();
  view->increaseReferenceCount();
  this->nativeView = view.get();
}

void Text::setText(std::string text) {
  part.text = text;
  rebuildTextParts();
}

std::string Text::getText() {
  return part.text;
}

void Text::setTextColor(rehax::ui::Color color) {
  part.color = ::fluxe::Color::RGBA(color.r, color.g, color.b, color.a);
  hasColor = true;
  rebuildTextParts();
}

void Text::setItalic(bool italic) {
  part.isItalic = italic;
  hasItalic = true;
  rebuildTextParts();
}

void Text::setUnderlined(bool underlined) {
  part.isUnderlined = underlined;
  hasUnderlined = true;
  rebuildTextParts();
}

void Text::setStrikeThrough(bool strikeThrough) {
  part.isStrikedThrough = strikeThrough;
  hasStrikeThrough = true;
  rebuildTextParts();
}

void Text::setFontSize(float size) {
  part.fontSize = size;
  hasFontSize = true;
  rebuildTextParts();
}

void Text::setFontFamilies(std::vector<std::string> fontFamilies) {
  part.fontFamilies = fontFamilies;
  rebuildTextParts();
}

void Text::addNativeView(void * child) {
  View::addNativeView(child);
}

void Text::addNativeView(void * child, void * beforeView) {
  View::addNativeView(child, beforeView);
}

void Text::layout() {
  rebuildTextParts();
}

void Text::setLayout(rehaxUtils::ObjectPointer<ILayout> layout) {}

void Text::addView(ObjectPointer<View> view) {
  if (view->instanceClassName() != "Text") {
    std::cerr << "Can only add Text children to Text" << std::endl;
    return;
  }
  View::addView(view);
  auto childText = rehaxUtils::dynamic_pointer_cast<Text>(view);
  childText->isRootTextView = false;
  childText->removeFromNativeParent();
  childText->destroyNativeView();
  rebuildTextParts();
}

void Text::addView(ObjectPointer<View> view, ObjectPointer<View> beforeView) {
  if (view->instanceClassName() != "Text") {
    std::cerr << "Can only add Text children to Text" << std::endl;
    return;
  }
  View::addView(view, beforeView);
  auto childText = rehaxUtils::dynamic_pointer_cast<Text>(view);
  childText->isRootTextView = false;
  childText->removeFromNativeParent();
  childText->destroyNativeView();
  rebuildTextParts();
}

void Text::rebuildTextParts() {
  if (!isRootTextView) {
    if (parent.isValid()) {
      ((Text*) parent.get())->rebuildTextParts();
    }
    return;
  }

  auto view = static_cast<::fluxe::Text *>(this->nativeView);
  std::vector<::fluxe::TextPart> parts;
  buildTextParts(parts, part);
  view->setText(parts);
}

void Text::buildTextParts(std::vector<::fluxe::TextPart> & parts, ::fluxe::TextPart previousPart) {
  ::fluxe::TextPart nextPart = previousPart;
  nextPart.text = part.text;

  if (hasItalic) {
    nextPart.isItalic = part.isItalic;
  }
  if (hasUnderlined) {
    nextPart.isUnderlined = part.isUnderlined;
  }
  if (hasStrikeThrough) {
    nextPart.isStrikedThrough = part.isStrikedThrough;
  }
  if (hasFontSize) {
    nextPart.fontSize = part.fontSize;
  }
//  if (hasFontWeight) {
//    nextPart.fontWeight = part.fontWeight;
//  }
  if (part.fontFamilies.size() > 0) {
    nextPart.fontFamilies = part.fontFamilies;
  }
  if (hasColor) {
    nextPart.color = part.color;
  }

  parts.push_back(nextPart);
  for (auto & child : children) {
    Text * childText = (Text*) child;
    childText->buildTextParts(parts, nextPart);
  }
}

}
