#pragma once

#include <vector>
#include <iostream>
#include "../../../style.h"
#include "../view/View.h"

namespace rehax::ui::appkit::impl {

#define ADDITIONAL_TEXT_DEFS private: \
  std::string text; \
  size_t childrenTextLength = 0; \
  bool isRootTextView = true; \
  bool isItalic = false; \
  bool isUnderlined = false; \
  bool isStrikeThrough = false; \
  float fontSize = 12; \
  float fontWeight = 1; \
  bool hasFontSize = false; \
  bool hasFontWeight = false; \
  bool hasColor = false; \
  rehax::ui::Color color = rehax::ui::Color::RGBA(1, 1, 1, 1); \
  std::vector<std::string> fontFamilies; \
  void rebuildAttributedString(); \
  std::string collectChildrenText(); \
  unsigned int applyAttributes(unsigned int pos, void * str);

#include "../../../interfaces/Text.h"

}
