
template <typename View, typename Layout, typename Gesture>
void Bindings::bindViewClassMethods(runtime::Value prototype) {
  bindMethod<View, std::string, &View::description>("toString", prototype);
  bindMethod<View, rehaxUtils::ObjectPointer<View>, rehaxUtils::ObjectPointer<View>, &View::addView>("addView", prototype);
  bindMethod<View, &View::removeFromParent>("removeFromParent", prototype);
  bindMethod<View, rehaxUtils::ObjectPointer<View>, &View::removeView>("removeView", prototype);
  bindMethod<View, rehaxUtils::WeakObjectPointer<View>, &View::getParent>("getParent", prototype);
  bindMethod<View, rehaxUtils::WeakObjectPointer<View>, &View::getFirstChild>("getFirstChild", prototype);
  bindMethod<View, rehaxUtils::WeakObjectPointer<View>, &View::getNextSibling>("getNextSibling", prototype);
  bindMethod<View, rehax::ui::Length, &View::setVerticalPosition>("setVerticalPosition", prototype);
  bindMethod<View, rehax::ui::Length, &View::setHorizontalPosition>("setHorizontalPosition", prototype);
  bindMethod<View, rehax::ui::Length, &View::setWidth>("setWidth", prototype);
  bindMethod<View, rehax::ui::Length, &View::setHeight>("setHeight", prototype);
  bindMethod<View, rehaxUtils::ObjectPointer<Layout>, &View::setLayout>("setLayout", prototype);
  bindMethod<View, &View::layout>("layout", prototype);
  bindMethod<View, rehaxUtils::ObjectPointer<Gesture>, &View::addGesture>("addGesture", prototype);
  bindMethod<View, rehax::ui::Color, ::rehax::ui::DefaultValue, &View::setBackgroundColor, &View::setBackgroundColor>("setBackgroundColor", prototype);
}

template <typename View>
void Bindings::bindButtonClassMethods(runtime::Value prototype) {
  bindMethod<View, std::string, &View::getTitle>("getTitle", prototype);
  bindMethod<View, std::string, rehax::ui::DefaultValue, &View::setTitle, &View::setTitle>("setTitle", prototype);
  bindMethod<View, std::function<void(void)>, rehax::ui::DefaultValue, &View::setOnPress, &View::setOnPress>("setOnPress", prototype);
}

template <typename View>
void Bindings::bindTextClassMethods(runtime::Value prototype) {
  bindMethod<View, std::string, &View::getText>("getText", prototype);
  bindMethod<View, std::string, rehax::ui::DefaultValue, &View::setText, &View::setText>("setText", prototype);
  bindMethod<View, rehax::ui::Color, rehax::ui::DefaultValue, &View::setTextColor, &View::setTextColor>("setTextColor", prototype);
  bindMethod<View, float, rehax::ui::DefaultValue, &View::setFontSize, &View::setFontSize>("setFontSize", prototype);
  bindMethod<View, bool, &View::setItalic>("setItalic", prototype);
  bindMethod<View, bool, &View::setUnderlined>("setUnderlined", prototype);
  bindMethod<View, bool, &View::setStrikeThrough>("setStrikeThrough", prototype);
  bindMethod<View, std::vector<std::string>, &View::setFontFamilies>("setFontFamilies", prototype);
}

template <typename View>
void Bindings::bindTextInputClassMethods(runtime::Value prototype) {
  bindMethod<View, std::string, rehax::ui::DefaultValue, &View::setValue, &View::setValue>("setValue", prototype);
  bindMethod<View, std::string, &View::getValue>("getValue", prototype);
  bindMethod<View, std::function<void(std::string)>, rehax::ui::DefaultValue, &View::setOnValueChange, &View::setOnValueChange>("setOnValueChange", prototype);
  bindMethod<View, &View::focus>("focus", prototype);
  bindMethod<View, std::function<void(void)>, rehax::ui::DefaultValue, &View::setOnFocus, &View::setOnFocus>("setOnFocus", prototype);
  bindMethod<View, std::function<void(void)>, rehax::ui::DefaultValue, &View::setOnBlur, &View::setOnBlur>("setOnBlur", prototype);
  bindMethod<View, std::function<void(void)>, rehax::ui::DefaultValue, &View::setOnSubmit, &View::setOnSubmit>("setOnSubmit", prototype);
}

template <typename View>
void Bindings::bindSelectClassMethods(runtime::Value prototype) {
  bindMethod<View, std::string, rehax::ui::DefaultValue, &View::setValue, &View::setValue>("setValue", prototype);
  bindMethod<View, std::string, &View::getValue>("getValue", prototype);
  bindMethod<View, std::vector<ui::SelectOption>, rehax::ui::DefaultValue, &View::setOptions, &View::setOptions>("setOptions", prototype);
  bindMethod<View, std::vector<ui::SelectOption>, &View::getOptions>("getOptions", prototype);
  bindMethod<View, std::function<void(ui::SelectOption)>, rehax::ui::DefaultValue, &View::setOnValueChange, &View::setOnValueChange>("setOnValueChange", prototype);
}

template <typename View>
void Bindings::bindVectorElementClassMethods(runtime::Value prototype) {
  bindMethod<View, float, rehax::ui::DefaultValue, &View::setLineWidth, &View::setLineWidth>("setLineWidth", prototype);
  bindMethod<View, rehax::ui::VectorLineJoin, rehax::ui::DefaultValue, &View::setLineJoin, &View::setLineJoin>("setLineJoin", prototype);
  bindMethod<View, rehax::ui::VectorLineCap, rehax::ui::DefaultValue, &View::setLineCap, &View::setLineCap>("setLineCap", prototype);
  bindMethod<View, rehax::ui::Color, rehax::ui::DefaultValue, &View::setFillColor, &View::setFillColor>("setFillColor", prototype);
  bindMethod<View, rehax::ui::Color, rehax::ui::DefaultValue, &View::setStrokeColor, &View::setStrokeColor>("setStrokeColor", prototype);
  bindMethod<View, rehax::ui::Gradient, rehax::ui::DefaultValue, &View::setFillGradient, &View::setFillGradient>("setFillGradient", prototype);
  bindMethod<View, rehax::ui::Gradient, rehax::ui::DefaultValue, &View::setStrokeGradient, &View::setStrokeGradient>("setStrokeGradient", prototype);
  bindMethod<View, rehax::ui::Filters, rehax::ui::DefaultValue, &View::setFilters, &View::setFilters>("setFilters", prototype);
}

template <typename View>
void Bindings::bindVectorRectClassMethods(runtime::Value prototype) {
  bindMethod<View, rehax::ui::Size, &View::setSize>("setSize", prototype);
}

template <typename View>
void Bindings::bindVectorPathClassMethods(runtime::Value prototype) {
  bindMethod<View, &View::beginPath>("beginPath", prototype);
  bindMethod<View, float, &View::pathHorizontalTo>("pathHorizontalTo", prototype);
  bindMethod<View, float, &View::pathVerticalTo>("pathVerticalTo", prototype);
  bindMethod<View, float, float, &View::pathMoveTo>("pathMoveTo", prototype);
  bindMethod<View, float, float, &View::pathMoveBy>("pathMoveBy", prototype);
  bindMethod<View, float, float, &View::pathLineTo>("pathLineTo", prototype);
  bindMethod<View, float, float, float, float, &View::pathQuadraticBezier>("pathQuadraticBezier", prototype);
  bindMethod<View, float, float, float, int, int, float, float, &View::pathArc>("pathArc", prototype);
  bindMethod<View, float, float, float, float, float, float, &View::pathCubicBezier>("pathCubicBezier", prototype);
  bindMethod<View, &View::pathClose>("pathClose", prototype);
  bindMethod<View, &View::endPath>("endPath", prototype);
}

template <typename Layout, typename View>
void Bindings::bindStackLayoutClassMethods(runtime::Value prototype) {
  bindMethod<Layout, rehax::ui::StackLayoutOptions, &Layout::setOptions>("setOptions", prototype);
}

template <typename Layout, typename View>
void Bindings::bindFlexLayoutClassMethods(runtime::Value prototype) {
  bindMethod<Layout, rehax::ui::FlexLayoutOptions, &Layout::setOptions>("setOptions", prototype);
}

template <typename Gesture>
void Bindings::bindGestureClassMethods(runtime::Value prototype) {
  bindMethod<Gesture, std::function<void(void)>, std::function<void(float, float)>, std::function<void(float, float)>, std::function<void(float, float)>, &Gesture::setup>("setup", prototype);
  bindMethod<Gesture, rehax::ui::GestureState, &Gesture::setState>("setState", prototype);
}

template <
  typename StackLayout,
  typename FlexLayout,
  typename View,
  typename Button,
  typename Text,
  typename TextInput,
  typename Select,
  typename VectorContainer,
  typename VectorElement,
  typename VectorRect,
  typename VectorPath,
  typename ILayout,
  typename Gesture
>
void Bindings::bindRehax() {
#if RHX_GEN_DOCS
  jscDocs.collectType("Color", rehax::docs::TypeDocs {
    .type = rehax::docs::get_type_name<rehax::ui::Color>(),
    .note = "Converts from/to an object with shape `{ red: number, green: number, blue: number, alpha: number }`. The range for `alpha` is 0.0 - 1.0, and the ranges for the others is 0.0 - 255.0.",
  });
#endif
#if RHX_GEN_DOCS
  jscDocs.collectType("StackLayoutOptions", rehax::docs::TypeDocs {
    .type = rehax::docs::get_type_name<rehax::ui::StackLayoutOptions>(),
    .note = "Converts from/to an object with shape `{ spacing: float, direction: 'Horizontal' | 'Vertical' }`.",
  });
#endif
#if RHX_GEN_DOCS
  jscDocs.collectType("FlexLayoutOptions", rehax::docs::TypeDocs {
    .type = rehax::docs::get_type_name<rehax::ui::FlexLayoutOptions>(),
    .note = "Converts from/to an object with shape `{ direction: 'Column' | 'ColumnReverse' | 'Row' | 'RowReverse', TODO }`.",
  });
#endif
    
  defineClass<ILayout, false>("ILayout", nullptr);
  defineClass<StackLayout>("StackLayout", &classRegistry["ILayout"]);
  defineClass<FlexLayout>("FlexLayout", &classRegistry["ILayout"]);

  defineClass<View>("View", nullptr);
  defineClass<Button>("Button", &classRegistry["View"]);
  defineClass<Text>("Text", &classRegistry["View"]);
  defineClass<TextInput>("TextInput", &classRegistry["View"]);
  defineClass<Select>("Select", &classRegistry["View"]);
  defineClass<VectorContainer>("VectorContainer", &classRegistry["View"]);
  defineClass<VectorElement, false>("VectorElement", &classRegistry["View"]);
  defineClass<VectorRect>("VectorRect", &classRegistry["VectorElement"]);
  defineClass<VectorPath>("VectorPath", &classRegistry["VectorElement"]);

  bindViewClassMethods<View, ILayout, Gesture>(classRegistry["View"].prototype);
  bindButtonClassMethods<Button>(classRegistry["Button"].prototype);
  bindTextClassMethods<Text>(classRegistry["Text"].prototype);
  bindTextInputClassMethods<TextInput>(classRegistry["TextInput"].prototype);
  bindSelectClassMethods<Select>(classRegistry["Select"].prototype);
  bindVectorElementClassMethods<VectorElement>(classRegistry["VectorElement"].prototype);
  bindVectorRectClassMethods<VectorRect>(classRegistry["VectorRect"].prototype);
  bindVectorPathClassMethods<VectorPath>(classRegistry["VectorPath"].prototype);

  bindStackLayoutClassMethods<StackLayout, View>(classRegistry["StackLayout"].prototype);
  bindFlexLayoutClassMethods<FlexLayout, View>(classRegistry["FlexLayout"].prototype);

  defineClass<Gesture>("Gesture", nullptr);
  bindGestureClassMethods<Gesture>(classRegistry["Gesture"].prototype);

#if RHX_GEN_DOCS
  jscDocs.printJson();
  jscDocs.printMarkdown();
#endif
}


#ifdef REHAX_WITH_APPKIT
void Bindings::bindAppkitRehax() {
  bindRehax<
    rehax::ui::appkit::StackLayout,
    rehax::ui::appkit::FlexLayout,
    rehax::ui::appkit::View,
    rehax::ui::appkit::Button,
    rehax::ui::appkit::Text,
    rehax::ui::appkit::TextInput,
    rehax::ui::appkit::Select,
    rehax::ui::appkit::VectorContainer,
    rehax::ui::appkit::VectorElement,
    rehax::ui::appkit::VectorRect,
    rehax::ui::appkit::VectorPath,
    rehax::ui::appkit::ILayout,
    rehax::ui::appkit::Gesture
  >();

#if RHX_GEN_DOCS
  jscDocs.printJson();
  jscDocs.printMarkdown();
#endif
}
#endif

#ifdef REHAX_WITH_FLUXE
void Bindings::bindFluxeRehax() {
  bindRehax<
    rehax::ui::fluxe::StackLayout,
    rehax::ui::fluxe::FlexLayout,
    rehax::ui::fluxe::View,
    rehax::ui::fluxe::Button,
    rehax::ui::fluxe::Text,
    rehax::ui::fluxe::TextInput,
    rehax::ui::fluxe::Select,
    rehax::ui::fluxe::VectorContainer,
    rehax::ui::fluxe::VectorElement,
    rehax::ui::fluxe::VectorRect,
    rehax::ui::fluxe::VectorPath,
    rehax::ui::fluxe::ILayout,
    rehax::ui::fluxe::Gesture
  >();

#if RHX_GEN_DOCS
  jscDocs.printJson();
  jscDocs.printMarkdown();
#endif
    
}
#endif
