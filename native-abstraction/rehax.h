#pragma once

#include "ui/appkit/components/view/View.h"
#include "ui/appkit/components/button/Button.h"
#include "ui/appkit/components/text/Text.h"
#include "ui/appkit/components/textInput/TextInput.h"
#include "ui/appkit/components/vector/VectorContainer.h"
#include "ui/appkit/components/vector/VectorPath.h"

#include "ui/fluxe/components/view/View.h"
#include "ui/fluxe/components/button/Button.h"
#include "ui/fluxe/components/text/Text.h"

#include "ui/base.h"

namespace rehax::ui {
  namespace appkit {
    namespace refcounted {
      using View = impl::View<RefCountedPointer>;
      using Button = impl::Button<RefCountedPointer>;
      using Text = impl::Text<RefCountedPointer>;
      using TextInput = impl::TextInput<RefCountedPointer>;
      using VectorContainer = impl::VectorContainer<RefCountedPointer>;
      using VectorPath = impl::VectorPath<RefCountedPointer>;
    }
    namespace rawptr {
      using View = impl::View<RawPtr>;
      using Button = impl::Button<RawPtr>;
      using Text = impl::Text<RawPtr>;
      using TextInput = impl::TextInput<RawPtr>;
      using VectorContainer = impl::VectorContainer<RawPtr>;
      using VectorPath = impl::VectorPath<RawPtr>;
    }
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
