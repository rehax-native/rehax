#pragma once

#ifdef REHAX_WITH_APPKIT
#include "ui/appkit/components/view/View.h"
#include "ui/appkit/components/button/Button.h"
#include "ui/appkit/components/text/Text.h"
#include "ui/appkit/components/textInput/TextInput.h"
#include "ui/appkit/components/select/Select.h"
#include "ui/appkit/components/toggle/Toggle.h"
#include "ui/appkit/components/vector/VectorContainer.h"
#include "ui/appkit/components/vector/VectorRect.h"
#include "ui/appkit/components/vector/VectorPath.h"
#include "ui/appkit/components/layouts/StackLayout.h"
#include "ui/appkit/components/layouts/FlexLayout.h"
#include "ui/appkit/components/view/Gesture.h"
#include "ui/appkit/components/view/KeyHandler.h"
#include "ui/appkit/components/view/MouseHandler.h"
#endif

#ifdef REHAX_WITH_FLUXE
#include "ui/fluxe/components/view/View.h"
#include "ui/fluxe/components/button/Button.h"
#include "ui/fluxe/components/text/Text.h"
#include "ui/fluxe/components/textInput/TextInput.h"
#include "ui/fluxe/components/select/Select.h"
#include "ui/fluxe/components/toggle/Toggle.h"
#include "ui/fluxe/components/vector/VectorContainer.h"
#include "ui/fluxe/components/vector/VectorRect.h"
#include "ui/fluxe/components/vector/VectorPath.h"
#include "ui/fluxe/components/layouts/StackLayout.h"
#include "ui/fluxe/components/layouts/FlexLayout.h"
#include "ui/fluxe/components/view/Gesture.h"
#include "ui/fluxe/components/view/KeyHandler.h"
#include "ui/fluxe/components/view/MouseHandler.h"
#endif

#include "ui/base.h"

namespace rehax::ui {

  #ifdef REHAX_WITH_APPKIT
  namespace appkit {
    using View = impl::View;
    using Button = impl::Button;
    using Text = impl::Text;
    using TextInput = impl::TextInput;
    using Select = impl::Select;
    using Toggle = impl::Toggle;
    using VectorContainer = impl::VectorContainer;
    using VectorElement = impl::VectorElement;
    using VectorRect = impl::VectorRect;
    using VectorPath = impl::VectorPath;
    using ILayout = impl::ILayout;
    using StackLayout = impl::StackLayout;
    using FlexLayout = impl::FlexLayout;
    using Gesture = impl::Gesture;
    using KeyHandler = impl::KeyHandler;
    using MouseHandler = impl::MouseHandler;
  }
  #endif

  #ifdef REHAX_WITH_FLUXE
  namespace fluxe {
    using View = impl::View;
    using Button = impl::Button;
    using Text = impl::Text;
    using TextInput = impl::TextInput;
    using Select = impl::Select;
    using Toggle = impl::Toggle;
    using VectorContainer = impl::VectorContainer;
    using VectorElement = impl::VectorElement;
    using VectorRect = impl::VectorRect;
    using VectorPath = impl::VectorPath;
    using ILayout = impl::ILayout;
    using StackLayout = impl::StackLayout;
    using FlexLayout = impl::FlexLayout;
    using Gesture = impl::Gesture;
    using KeyHandler = impl::KeyHandler;
    using MouseHandler = impl::MouseHandler;
  }
  #endif
}
