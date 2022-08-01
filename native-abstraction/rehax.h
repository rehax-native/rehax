#pragma once

#include "ui/appkit/components/view/View.h"
#include "ui/appkit/components/button/Button.h"
#include "ui/appkit/components/text/Text.h"
#include "ui/appkit/components/textInput/TextInput.h"
#include "ui/appkit/components/vector/VectorContainer.h"
#include "ui/appkit/components/vector/VectorPath.h"
#include "ui/appkit/components/layouts/StackLayout.h"
#include "ui/appkit/components/layouts/FlexLayout.h"
#include "ui/appkit/components/view/Gesture.h"

#include "ui/fluxe/components/view/View.h"
#include "ui/fluxe/components/button/Button.h"
#include "ui/fluxe/components/text/Text.h"

#include "ui/base.h"

namespace rehax::ui {
  namespace appkit {
    using View = impl::View;
    using Button = impl::Button;
    using Text = impl::Text;
    using TextInput = impl::TextInput;
    using VectorContainer = impl::VectorContainer;
    using VectorElement = impl::VectorElement;
    using VectorPath = impl::VectorPath;
    using StackLayout = impl::StackLayout;
    using StackLayoutOptions = impl::StackLayoutOptions;
    using StackLayoutDirection = impl::StackLayoutDirection;
    using FlexLayout = impl::FlexLayout;
    using FlexLayoutOptions = impl::FlexLayoutOptions;
    using FlexJustifyContent = impl::FlexJustifyContent;
    using FlexAlignItems = impl::FlexAlignItems;
    using FlexLayoutDirection = impl::FlexLayoutDirection;
    using Gesture = impl::Gesture;
    using GestureState = impl::GestureState;
    using VectorLineCap = impl::VectorLineCap;
    using VectorLineJoin = impl::VectorLineJoin;
    using GradientStop = impl::GradientStop;
    using Gradient = impl::Gradient;
    using FilterDef = impl::FilterDef;
    using Filters = impl::Filters;
  }
  namespace fluxe {
    namespace refcounted {
      using View = impl::View<RefCountedPointer>;
      using Button = impl::Button<RefCountedPointer>;
      using Text = impl::Text<RefCountedPointer>;
//      using TextInput = impl::TextInput<RefCountedPointer>;
    }
    namespace rawptr {
      using View = impl::View<RawPtr>;
      using Button = impl::Button<RawPtr>;
      using Text = impl::Text<RawPtr>;
//      using TextInput = impl::TextInput<RawPtr>;
    }
  }
}
