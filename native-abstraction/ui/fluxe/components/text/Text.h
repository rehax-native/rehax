#pragma once

#include <vector>
#include <iostream>
#include "../../../style.h"
#include "../view/View.h"
#include <fluxe/views/Text.h>

namespace rehax::ui::fluxe::impl {

#define ADDITIONAL_TEXT_DEFS private: \
  bool isRootTextView = true; \
  ::fluxe::TextPart part; \
  bool hasItalic = false; \
  bool hasUnderlined = false; \
  bool hasStrikeThrough = false; \
  bool hasFontSize = false; \
  bool hasFontWeight = false; \
  bool hasColor = false; \
  void rebuildTextParts(); \
  void buildTextParts(std::vector<::fluxe::TextPart> & parts, ::fluxe::TextPart previousPart);

#include "../../../interfaces/Text.h"

}
