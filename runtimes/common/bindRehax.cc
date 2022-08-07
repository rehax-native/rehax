
template <typename View, typename Layout, typename Gesture>
void bindViewClassMethods(JSContextRef ctx, JSObjectRef prototype) {
  bindMethod<View, std::string, &View::description>("toString", ctx, prototype);
  bindMethod<View, rehaxUtils::ObjectPointer<View>, rehaxUtils::ObjectPointer<View>, &View::addView>("addView", ctx, prototype);
  bindMethod<View, &View::removeFromParent>("removeFromParent", ctx, prototype);
  bindMethod<View, rehaxUtils::ObjectPointer<View>, &View::removeView>("removeView", ctx, prototype);
  bindMethod<View, rehaxUtils::WeakObjectPointer<View>, &View::getParent>("getParent", ctx, prototype);
  bindMethod<View, rehaxUtils::WeakObjectPointer<View>, &View::getFirstChild>("getFirstChild", ctx, prototype);
  bindMethod<View, rehaxUtils::WeakObjectPointer<View>, &View::getNextSibling>("getNextSibling", ctx, prototype);
  bindMethod<View, rehax::ui::Length, &View::setWidth>("setWidth", ctx, prototype);
  bindMethod<View, rehax::ui::Length, &View::setHeight>("setHeight", ctx, prototype);
  bindMethod<View, rehaxUtils::ObjectPointer<Layout>, &View::setLayout>("setLayout", ctx, prototype);
  bindMethod<View, &View::layout>("layout", ctx, prototype);
  bindMethod<View, rehaxUtils::ObjectPointer<Gesture>, &View::addGesture>("addGesture", ctx, prototype);
  bindMethod<View, rehax::ui::Color, ::rehax::ui::DefaultValue, &View::setBackgroundColor, &View::setBackgroundColor>("setBackgroundColor", ctx, prototype);
}

template <typename View>
void bindButtonClassMethods(JSContextRef ctx, JSObjectRef prototype) {
  bindMethod<View, std::string, &View::getTitle>("getTitle", ctx, prototype);
  bindMethod<View, std::string, rehax::ui::DefaultValue, &View::setTitle, &View::setTitle>("setTitle", ctx, prototype);
  bindMethod<View, std::function<void(void)>, rehax::ui::DefaultValue, &View::setOnPress, &View::setOnPress>("setOnPress", ctx, prototype);
}

template <typename View>
void bindTextClassMethods(JSContextRef ctx, JSObjectRef prototype) {
  bindMethod<View, std::string, &View::getText>("getText", ctx, prototype);
  bindMethod<View, std::string, rehax::ui::DefaultValue, &View::setText, &View::setText>("setText", ctx, prototype);
  bindMethod<View, rehax::ui::Color, rehax::ui::DefaultValue, &View::setTextColor, &View::setTextColor>("setTextColor", ctx, prototype);
  bindMethod<View, float, rehax::ui::DefaultValue, &View::setFontSize, &View::setFontSize>("setFontSize", ctx, prototype);
}

template <typename View>
void bindTextInputClassMethods(JSContextRef ctx, JSObjectRef prototype) {
  bindMethod<View, std::string, rehax::ui::DefaultValue, &View::setValue, &View::setValue>("setValue", ctx, prototype);
  bindMethod<View, std::string, &View::getValue>("getValue", ctx, prototype);
}

template <typename View>
void bindVectorElementClassMethods(JSContextRef ctx, JSObjectRef prototype) {
  bindMethod<View, float, rehax::ui::DefaultValue, &View::setLineWidth, &View::setLineWidth>("setLineWidth", ctx, prototype);
  bindMethod<View, rehax::ui::VectorLineJoin, rehax::ui::DefaultValue, &View::setLineJoin, &View::setLineJoin>("setLineJoin", ctx, prototype);
  bindMethod<View, rehax::ui::VectorLineCap, rehax::ui::DefaultValue, &View::setLineCap, &View::setLineCap>("setLineCap", ctx, prototype);
  bindMethod<View, rehax::ui::Color, rehax::ui::DefaultValue, &View::setFillColor, &View::setFillColor>("setFillColor", ctx, prototype);
  bindMethod<View, rehax::ui::Color, rehax::ui::DefaultValue, &View::setStrokeColor, &View::setStrokeColor>("setStrokeColor", ctx, prototype);
  bindMethod<View, rehax::ui::Gradient, rehax::ui::DefaultValue, &View::setFillGradient, &View::setFillGradient>("setFillGradient", ctx, prototype);
  bindMethod<View, rehax::ui::Gradient, rehax::ui::DefaultValue, &View::setStrokeGradient, &View::setStrokeGradient>("setStrokeGradient", ctx, prototype);
  bindMethod<View, rehax::ui::Filters, rehax::ui::DefaultValue, &View::setFilters, &View::setFilters>("setFilters", ctx, prototype);
}

template <typename View>
void bindVectorPathClassMethods(JSContextRef ctx, JSObjectRef prototype) {
  bindMethod<View, &View::beginPath>("beginPath", ctx, prototype);
  bindMethod<View, float, &View::pathHorizontalTo>("pathHorizontalTo", ctx, prototype);
  bindMethod<View, float, &View::pathVerticalTo>("pathVerticalTo", ctx, prototype);
  bindMethod<View, float, float, &View::pathMoveTo>("pathMoveTo", ctx, prototype);
  bindMethod<View, float, float, &View::pathMoveBy>("pathMoveBy", ctx, prototype);
  bindMethod<View, float, float, &View::pathLineTo>("pathLineTo", ctx, prototype);
  bindMethod<View, float, float, float, float, &View::pathQuadraticBezier>("pathQuadraticBezier", ctx, prototype);
  bindMethod<View, float, float, float, int, int, float, float, &View::pathArc>("pathArc", ctx, prototype);
  bindMethod<View, float, float, float, float, float, float, &View::pathCubicBezier>("pathCubicBezier", ctx, prototype);
  bindMethod<View, &View::pathClose>("pathClose", ctx, prototype);
  bindMethod<View, &View::endPath>("endPath", ctx, prototype);
}

template <typename Layout, typename View>
void bindStackLayoutClassMethods(JSContextRef ctx, JSObjectRef prototype) {
  bindMethod<Layout, rehax::ui::StackLayoutOptions, &Layout::setOptions>("setOptions", ctx, prototype);
}

template <typename Layout, typename View>
void bindFlexLayoutClassMethods(JSContextRef ctx, JSObjectRef prototype) {
  bindMethod<Layout, rehax::ui::FlexLayoutOptions, &Layout::setOptions>("setOptions", ctx, prototype);
}

template <typename Gesture>
void bindGestureClassMethods(JSContextRef ctx, JSObjectRef prototype) {
  bindMethod<Gesture, std::function<void(void)>, std::function<void(float, float)>, std::function<void(float, float)>, std::function<void(float, float)>, &Gesture::setup>("setup", ctx, prototype);
  bindMethod<Gesture, rehax::ui::GestureState, &Gesture::setState>("setState", ctx, prototype);
}

template <
  typename StackLayout,
  typename FlexLayout,
  typename View,
  typename Button,
  typename Text,
  typename TextInput,
  typename VectorContainer,
  typename VectorElement,
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
    
  defineViewClass<StackLayout>(ctx, "StackLayout", nullptr);
  defineViewClass<FlexLayout>(ctx, "FlexLayout", nullptr);

  defineViewClass<View>(ctx, "View", nullptr);
  defineViewClass<Button>(ctx, "Button", classRegistry["View"].prototype);
  defineViewClass<Text>(ctx, "Text", classRegistry["View"].prototype);
  defineViewClass<TextInput>(ctx, "TextInput", classRegistry["View"].prototype);
  defineViewClass<VectorContainer>(ctx, "VectorContainer", classRegistry["View"].prototype);
  defineViewClass<VectorElement, false>(ctx, "VectorElement", classRegistry["View"].prototype);
  defineViewClass<VectorPath>(ctx, "VectorPath", classRegistry["VectorElement"].prototype);

  bindViewClassMethods<View, ILayout, Gesture>(ctx, classRegistry["View"].prototype);
  bindButtonClassMethods<Button>(ctx, classRegistry["Button"].prototype);
  bindTextClassMethods<Text>(ctx, classRegistry["Text"].prototype);
  bindTextInputClassMethods<TextInput>(ctx, classRegistry["TextInput"].prototype);
  bindVectorElementClassMethods<VectorElement>(ctx, classRegistry["VectorElement"].prototype);
  bindVectorPathClassMethods<VectorPath>(ctx, classRegistry["VectorPath"].prototype);

  bindStackLayoutClassMethods<StackLayout, View>(ctx, classRegistry["StackLayout"].prototype);
  bindFlexLayoutClassMethods<FlexLayout, View>(ctx, classRegistry["FlexLayout"].prototype);

  defineViewClass<Gesture>(ctx, "Gesture", nullptr);
  bindGestureClassMethods<Gesture>(ctx, classRegistry["Gesture"].prototype);

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
    rehax::ui::appkit::VectorContainer,
    rehax::ui::appkit::VectorElement,
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
    rehax::ui::fluxe::VectorContainer,
    rehax::ui::fluxe::VectorElement,
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
