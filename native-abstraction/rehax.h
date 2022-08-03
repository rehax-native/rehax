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
#include "ui/fluxe/components/textInput/TextInput.h"
#include "ui/fluxe/components/vector/VectorContainer.h"
#include "ui/fluxe/components/vector/VectorPath.h"
#include "ui/fluxe/components/layouts/StackLayout.h"
#include "ui/fluxe/components/layouts/FlexLayout.h"
#include "ui/fluxe/components/view/Gesture.h"

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
    using FlexLayout = impl::FlexLayout;
    using Gesture = impl::Gesture;
  }
  namespace fluxe {
    using View = impl::View;
    using Button = impl::Button;
    using Text = impl::Text;
    using TextInput = impl::TextInput;
    using VectorContainer = impl::VectorContainer;
    using VectorElement = impl::VectorElement;
    using VectorPath = impl::VectorPath;
    using StackLayout = impl::StackLayout;
    using FlexLayout = impl::FlexLayout;
    using Gesture = impl::Gesture;
  }
}
