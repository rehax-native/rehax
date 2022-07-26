#pragma once

#include "ui/appkit/components/view/View.h"
#include "ui/appkit/components/text/Text.h"
#include "ui/appkit/components/button/Button.h"
#include "ui/fluxe/components/view/View.h"
#include "ui/fluxe/components/text/Text.h"
#include "ui/fluxe/components/button/Button.h"

#include "ui/base.h"

namespace rehax::ui {
    namespace appkit {
        // namespace smartptr {
        //     using ViewBase = SmartPtrBase<impl::View>;
        //     using View = SmartPtr<impl::View, ViewBase>;
        //     using Button = SmartPtr<impl::Button, ViewBase>;
        // }
        namespace rawptr {
            using View = impl::View<RawPtr<>>;
            using Text = impl::Text<RawPtr<>>;
            using Button = impl::Button<RawPtr<>>;
        }
    }
    namespace fluxe {
        // namespace smartptr {
        //     using ViewBase = SmartPtrBase<impl::View>;
        //     using View = SmartPtr<impl::View, ViewBase>;
        //     using Button = SmartPtr<impl::Button, ViewBase>;
        // }
        namespace rawptr {
            using View = impl::View<RawPtr<>>;
            using Text = impl::Text<RawPtr<>>;
            using Button = impl::Button<RawPtr<>>;
        }
    }
}

// #include "components/view/View.h"
// #include "components/root/Root.h"
// #include "components/text/Text.h"
// #include "components/textInput/TextInput.h"
// #include "components/button/Button.h"
// #include "components/fragment/Fragment.h"
// #include "components/util/Util.h"
// #include "components/layout/FlexLayout.h"
// #include "components/layout/StackLayout.h"
