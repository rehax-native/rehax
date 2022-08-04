
template <>
struct Converter<rehax::ui::Color> {
  static runtime::Value toScript(runtime::Context ctx, rehax::ui::Color value) {
    runtime::Value object = runtime::MakeObject(ctx);
    runtime::SetObjectProperty(ctx, object, "red", Converter<float>::toScript(ctx, value.r * 255.0));
    runtime::SetObjectProperty(ctx, object, "green", Converter<float>::toScript(ctx, value.g * 255.0));
    runtime::SetObjectProperty(ctx, object, "blue", Converter<float>::toScript(ctx, value.b * 255.0));
    runtime::SetObjectProperty(ctx, object, "alpha", Converter<float>::toScript(ctx, value.a));
    return object;
  }
  static rehax::ui::Color toCpp(runtime::Context ctx, const runtime::Value& colorValue, Bindings * bindings, std::vector<runtime::Value>& retainedValues) {
    auto r = Converter<float>::toCpp(ctx, runtime::GetObjectProperty(ctx, colorValue, "red"), bindings, retainedValues);
    auto g = Converter<float>::toCpp(ctx, runtime::GetObjectProperty(ctx, colorValue, "green"), bindings, retainedValues);
    auto b = Converter<float>::toCpp(ctx, runtime::GetObjectProperty(ctx, colorValue, "blue"), bindings, retainedValues);
    auto a = Converter<float>::toCpp(ctx, runtime::GetObjectProperty(ctx, colorValue, "alpha"), bindings, retainedValues);
    return ui::Color::RGBA(
      r / 255.0,
      g / 255.0,
      b / 255.0,
      a
    );
  }
};

template <>
struct Converter<rehax::ui::StackLayoutDirection> {
  static runtime::Value toScript(runtime::Context ctx, rehax::ui::StackLayoutDirection& value) {
    if (value == ui::StackLayoutDirection::Vertical) {
      return Converter<std::string>::toScript(ctx, "Vertical");
    }
    if (value == ui::StackLayoutDirection::Horizontal) {
      return Converter<std::string>::toScript(ctx, "Horizontal");
    }
  }
  static rehax::ui::StackLayoutDirection toCpp(runtime::Context ctx, const runtime::Value& value, Bindings * bindings, std::vector<runtime::Value>& retainedValues) {
    auto val = Converter<std::string>::toCpp(ctx, value, bindings, retainedValues);
    if (val == "Horizontal") {
      return ui::StackLayoutDirection::Horizontal;
    }
    return ui::StackLayoutDirection::Vertical;
  }
};

template <>
struct Converter<rehax::ui::StackLayoutOptions> {
  static runtime::Value toScript(runtime::Context ctx, rehax::ui::StackLayoutOptions& value) {
    runtime::Value obj = runtime::MakeObject(ctx);
    runtime::SetObjectProperty(ctx, obj, "spacing", Converter<float>::toScript(ctx, value.spacing));
    runtime::SetObjectProperty(ctx, obj, "direction", Converter<rehax::ui::StackLayoutDirection>::toScript(ctx, value.direction));
    return obj;
  }
  static rehax::ui::StackLayoutOptions toCpp(runtime::Context ctx, const runtime::Value& value, Bindings * bindings, std::vector<runtime::Value>& retainedValues) {
    rehax::ui::StackLayoutOptions options;
    if (runtime::HasObjectProperty(ctx, value, "spacing")) {
      options.spacing = Converter<float>::toCpp(ctx, runtime::GetObjectProperty(ctx, value, "spacing"), bindings, retainedValues);
    }
    if (runtime::HasObjectProperty(ctx, value, "direction")) {
      options.direction = Converter<rehax::ui::StackLayoutDirection>::toCpp(ctx, runtime::GetObjectProperty(ctx, value, "direction"), bindings, retainedValues);
    }
    return options;
  }
};

template <>
struct Converter<rehax::ui::FlexLayoutDirection> {
  static runtime::Value toScript(runtime::Context ctx, rehax::ui::FlexLayoutDirection& value) {
    if (value == ui::FlexLayoutDirection::Column) {
      return Converter<std::string>::toScript(ctx, "Column");
    }
    if (value == ui::FlexLayoutDirection::ColumnReverse) {
      return Converter<std::string>::toScript(ctx, "ColumnReverse");
    }
    if (value == ui::FlexLayoutDirection::Row) {
      return Converter<std::string>::toScript(ctx, "Row");
    }
    if (value == ui::FlexLayoutDirection::RowReverse) {
      return Converter<std::string>::toScript(ctx, "RowReverse");
    }
  }
  static rehax::ui::FlexLayoutDirection toCpp(runtime::Context ctx, const runtime::Value& value, Bindings * bindings, std::vector<runtime::Value>& retainedValues) {
    auto val = Converter<std::string>::toCpp(ctx, value, bindings, retainedValues);
    if (val == "Column") {
      return ui::FlexLayoutDirection::Column;
    }
    if (val == "ColumnReverse") {
      return ui::FlexLayoutDirection::ColumnReverse;
    }
    if (val == "RowReverse") {
      return ui::FlexLayoutDirection::RowReverse;
    }
    return ui::FlexLayoutDirection::Row;
  }
};

template <>
struct Converter<rehax::ui::FlexJustifyContent> {
  static runtime::Value toScript(runtime::Context ctx, rehax::ui::FlexJustifyContent& value) {
    if (value == ui::FlexJustifyContent::FlexStart) {
      return Converter<std::string>::toScript(ctx, "FlexStart");
    }
    if (value == ui::FlexJustifyContent::FlexEnd) {
      return Converter<std::string>::toScript(ctx, "FlexEnd");
    }
    if (value == ui::FlexJustifyContent::Center) {
      return Converter<std::string>::toScript(ctx, "Center");
    }
  }
  static rehax::ui::FlexJustifyContent toCpp(runtime::Context ctx, const runtime::Value& value, Bindings * bindings, std::vector<runtime::Value>& retainedValues) {
    auto val = Converter<std::string>::toCpp(ctx, value, bindings, retainedValues);
    if (val == "FlexEnd") {
      return ui::FlexJustifyContent::FlexEnd;
    }
    if (val == "Center") {
      return ui::FlexJustifyContent::Center;
    }
    return ui::FlexJustifyContent::FlexStart;
  }
};

template <>
struct Converter<rehax::ui::FlexAlignItems> {
  static runtime::Value toScript(runtime::Context ctx, rehax::ui::FlexAlignItems& value) {
    if (value == ui::FlexAlignItems::FlexStart) {
      return Converter<std::string>::toScript(ctx, "FlexStart");
    }
    if (value == ui::FlexAlignItems::FlexEnd) {
      return Converter<std::string>::toScript(ctx, "FlexEnd");
    }
    if (value == ui::FlexAlignItems::Center) {
      return Converter<std::string>::toScript(ctx, "Center");
    }
  }
  static rehax::ui::FlexAlignItems toCpp(runtime::Context ctx, const runtime::Value& value, Bindings * bindings, std::vector<runtime::Value>& retainedValues) {
    auto val = Converter<std::string>::toCpp(ctx, value, bindings, retainedValues);
    if (val == "FlexEnd") {
      return ui::FlexAlignItems::FlexEnd;
    }
    if (val == "Center") {
      return ui::FlexAlignItems::Center;
    }
    return ui::FlexAlignItems::FlexStart;
  }
};

template <>
struct Converter<rehax::ui::FlexItem> {
  static runtime::Value toScript(runtime::Context ctx, rehax::ui::FlexItem& value) {
    runtime::Value obj = runtime::MakeObject(ctx);
    runtime::SetObjectProperty(ctx, obj, "flexGrow", Converter<float>::toScript(ctx, value.flexGrow));
    runtime::SetObjectProperty(ctx, obj, "hasFlexGrow", Converter<bool>::toScript(ctx, value.hasFlexGrow));
    runtime::SetObjectProperty(ctx, obj, "order", Converter<int>::toScript(ctx, value.order));
    runtime::SetObjectProperty(ctx, obj, "alignSelf", Converter<rehax::ui::FlexAlignItems>::toScript(ctx, value.alignSelf));
    return obj;
  }
  static rehax::ui::FlexItem toCpp(runtime::Context ctx, const runtime::Value& value, Bindings * bindings, std::vector<runtime::Value>& retainedValues) {
    rehax::ui::FlexItem flexItem;
    if (runtime::HasObjectProperty(ctx, value, "flexGrow")) {
      flexItem.flexGrow = Converter<float>::toCpp(ctx, runtime::GetObjectProperty(ctx, value, "flexGrow"), bindings, retainedValues);
    }
    if (runtime::HasObjectProperty(ctx, value, "hasFlexGrow")) {
      flexItem.hasFlexGrow = Converter<bool>::toCpp(ctx, runtime::GetObjectProperty(ctx, value, "hasFlexGrow"), bindings, retainedValues);
    }
    if (runtime::HasObjectProperty(ctx, value, "order")) {
      flexItem.order = Converter<int>::toCpp(ctx, runtime::GetObjectProperty(ctx, value, "order"), bindings, retainedValues);
    }
    if (runtime::HasObjectProperty(ctx, value, "alignSelf")) {
      flexItem.alignSelf = Converter<rehax::ui::FlexAlignItems>::toCpp(ctx, runtime::GetObjectProperty(ctx, value, "alignSelf"), bindings, retainedValues);
    }
    return flexItem;
  }
};

template <>
struct Converter<rehax::ui::FlexLayoutOptions> {
  static runtime::Value toScript(runtime::Context ctx, rehax::ui::FlexLayoutOptions& value) {
    runtime::Value obj = runtime::MakeObject(ctx);
    runtime::SetObjectProperty(ctx, obj, "direction", Converter<rehax::ui::FlexLayoutDirection>::toScript(ctx, value.direction));
    runtime::SetObjectProperty(ctx, obj, "justifyContent", Converter<rehax::ui::FlexJustifyContent>::toScript(ctx, value.justifyContent));
    runtime::SetObjectProperty(ctx, obj, "alignItems", Converter<rehax::ui::FlexAlignItems>::toScript(ctx, value.alignItems));

    auto arr = runtime::MakeArray(ctx);
    for (int i = 0; i < value.items.size(); i++) {
      auto js = Converter<rehax::ui::FlexItem>::toScript(ctx, value.items[i]);
      runtime::SetArrayValue(ctx, arr, i, js);
    }
    runtime::SetObjectProperty(ctx, obj, "items", arr);
    return obj;
  }
  static rehax::ui::FlexLayoutOptions toCpp(runtime::Context ctx, const runtime::Value& value, Bindings * bindings, std::vector<runtime::Value>& retainedValues) {
    rehax::ui::FlexLayoutOptions options;
    if (runtime::HasObjectProperty(ctx, value, "direction")) {
      options.direction = Converter<rehax::ui::FlexLayoutDirection>::toCpp(ctx, runtime::GetObjectProperty(ctx, value, "direction"), bindings, retainedValues);
    }
    if (runtime::HasObjectProperty(ctx, value, "justifyContent")) {
      options.justifyContent = Converter<rehax::ui::FlexJustifyContent>::toCpp(ctx, runtime::GetObjectProperty(ctx, value, "justifyContent"), bindings, retainedValues);
    }
    if (runtime::HasObjectProperty(ctx, value, "alignItems")) {
      options.alignItems = Converter<rehax::ui::FlexAlignItems>::toCpp(ctx, runtime::GetObjectProperty(ctx, value, "alignItems"), bindings, retainedValues);
    }
    if (runtime::HasObjectProperty(ctx, value, "items")) {
      runtime::Value items = runtime::GetObjectProperty(ctx, value, "items");
      int length = Converter<int>::toCpp(ctx, runtime::GetObjectProperty(ctx, items, "length"), bindings, retainedValues);
      for (int i = 0; i < length; i++) {
        auto item = runtime::GetArrayValue(ctx, items, i);
        options.items.push_back(Converter<rehax::ui::FlexItem>::toCpp(ctx, item, bindings, retainedValues));
      }
    }
    return options;
  }
};

template <>
struct Converter<rehax::ui::GestureState> {
  static runtime::Value toScript(runtime::Context ctx, rehax::ui::GestureState& value) {
    if (value == ui::GestureState::Possible) {
      return Converter<std::string>::toScript(ctx, "Possible");
    }
    if (value == ui::GestureState::Recognized) {
      return Converter<std::string>::toScript(ctx, "Recognized");
    }
    if (value == ui::GestureState::Began) {
      return Converter<std::string>::toScript(ctx, "Began");
    }
    if (value == ui::GestureState::Changed) {
      return Converter<std::string>::toScript(ctx, "Changed");
    }
    if (value == ui::GestureState::Canceled) {
      return Converter<std::string>::toScript(ctx, "Canceled");
    }
    if (value == ui::GestureState::Ended) {
      return Converter<std::string>::toScript(ctx, "Ended");
    }
  }
  static rehax::ui::GestureState toCpp(runtime::Context ctx, const runtime::Value& value, Bindings * bindings, std::vector<runtime::Value>& retainedValues) {
    auto val = Converter<std::string>::toCpp(ctx, value, bindings, retainedValues);
    if (val == "Recognized") {
      return ui::GestureState::Recognized;
    }
    if (val == "Began") {
      return ui::GestureState::Began;
    }
    if (val == "Changed") {
      return ui::GestureState::Changed;
    }
    if (val == "Canceled") {
      return ui::GestureState::Canceled;
    }
    if (val == "Ended") {
      return ui::GestureState::Ended;
    }
    return ui::GestureState::Possible;
  }
};

template <>
struct Converter<rehax::ui::VectorLineCap> {
  static runtime::Value toScript(runtime::Context ctx, rehax::ui::VectorLineCap& value) {
    if (value == ui::VectorLineCap::Butt) {
      return Converter<std::string>::toScript(ctx, "Butt");
    }
    if (value == ui::VectorLineCap::Square) {
      return Converter<std::string>::toScript(ctx, "Square");
    }
    if (value == ui::VectorLineCap::Round) {
      return Converter<std::string>::toScript(ctx, "Round");
    }
  }
  static rehax::ui::VectorLineCap toCpp(runtime::Context ctx, const runtime::Value& value, Bindings * bindings, std::vector<runtime::Value>& retainedValues) {
    auto val = Converter<std::string>::toCpp(ctx, value, bindings, retainedValues);
    if (val == "Square") {
      return ui::VectorLineCap::Square;
    }
    if (val == "Round") {
      return ui::VectorLineCap::Round;
    }
    return ui::VectorLineCap::Butt;
  }
};

template <>
struct Converter<rehax::ui::VectorLineJoin> {
  static runtime::Value toScript(runtime::Context ctx, rehax::ui::VectorLineJoin& value) {
    if (value == ui::VectorLineJoin::Miter) {
      return Converter<std::string>::toScript(ctx, "Miter");
    }
    if (value == ui::VectorLineJoin::Round) {
      return Converter<std::string>::toScript(ctx, "Round");
    }
    if (value == ui::VectorLineJoin::Bevel) {
      return Converter<std::string>::toScript(ctx, "Bevel");
    }
  }
  static rehax::ui::VectorLineJoin toCpp(runtime::Context ctx, const runtime::Value& value, Bindings * bindings, std::vector<runtime::Value>& retainedValues) {
    auto val = Converter<std::string>::toCpp(ctx, value, bindings, retainedValues);
    if (val == "Round") {
      return ui::VectorLineJoin::Round;
    }
    if (val == "Bevel") {
      return ui::VectorLineJoin::Bevel;
    }
    return ui::VectorLineJoin::Miter;
  }
};

template <>
struct Converter<rehax::ui::GradientStop> {
  static runtime::Value toScript(runtime::Context ctx, rehax::ui::GradientStop& value) {
    runtime::Value obj = runtime::MakeObject(ctx);
    runtime::SetObjectProperty(ctx, obj, "color", Converter<rehax::ui::Color>::toScript(ctx, value.color));
    runtime::SetObjectProperty(ctx, obj, "offset", Converter<float>::toScript(ctx, value.offset));
    return obj;
  }
  static rehax::ui::GradientStop toCpp(runtime::Context ctx, const runtime::Value& value, Bindings * bindings, std::vector<runtime::Value>& retainedValues) {
    rehax::ui::GradientStop stop;
    if (runtime::HasObjectProperty(ctx, value, "color")) {
      stop.color = Converter<rehax::ui::Color>::toCpp(ctx, runtime::GetObjectProperty(ctx, value, "color"), bindings, retainedValues);
    }
    if (runtime::HasObjectProperty(ctx, value, "offset")) {
      stop.offset = Converter<float>::toCpp(ctx, runtime::GetObjectProperty(ctx, value, "offset"), bindings, retainedValues);
    }
    return stop;
  }
};

template <>
struct Converter<rehax::ui::Gradient> {
  static runtime::Value toScript(runtime::Context ctx, rehax::ui::Gradient& value) {
    auto obj = runtime::MakeObject(ctx);
    auto arr = runtime::MakeArray(ctx);
    for (int i = 0; i < value.stops.size(); i++) {
      auto js = Converter<rehax::ui::GradientStop>::toScript(ctx, value.stops[i]);
      runtime::SetArrayValue(ctx, arr, i, js);
    }
    runtime::SetObjectProperty(ctx, obj, "stops", arr);
    return obj;
  }
  static rehax::ui::Gradient toCpp(runtime::Context ctx, const runtime::Value& value, Bindings * bindings, std::vector<runtime::Value>& retainedValues) {
    rehax::ui::Gradient gradient;
    if (runtime::HasObjectProperty(ctx, value, "stops")) {
      runtime::Value items = runtime::GetObjectProperty(ctx, value, "stops");
      int length = Converter<int>::toCpp(ctx, runtime::GetObjectProperty(ctx, items, "length"), bindings, retainedValues);
      for (int i = 0; i < length; i++) {
        auto item = runtime::GetArrayValue(ctx, items, i);
        gradient.stops.push_back(Converter<rehax::ui::GradientStop>::toCpp(ctx, item, bindings, retainedValues));
      }
    }
    return gradient;
  }
};

template <>
struct Converter<rehax::ui::FilterDef> {
  static runtime::Value toScript(runtime::Context ctx, rehax::ui::FilterDef& value) {
    auto obj = runtime::MakeObject(ctx);
    runtime::SetObjectProperty(ctx, obj, "type", Converter<int>::toScript(ctx, value.type));
    runtime::SetObjectProperty(ctx, obj, "blurRadius", Converter<float>::toScript(ctx, value.blurRadius));
    return obj;
  }
  static rehax::ui::FilterDef toCpp(runtime::Context ctx, const runtime::Value& value, Bindings * bindings, std::vector<runtime::Value>& retainedValues) {
    rehax::ui::FilterDef def;
    if (runtime::HasObjectProperty(ctx, value, "type")) {
      def.type = Converter<int>::toCpp(ctx, runtime::GetObjectProperty(ctx, value, "type"), bindings, retainedValues);
    }
    if (runtime::HasObjectProperty(ctx, value, "blurRadius")) {
      def.blurRadius = Converter<float>::toCpp(ctx, runtime::GetObjectProperty(ctx, value, "blurRadius"), bindings, retainedValues);
    }
    return def;
  }
};

template <>
struct Converter<rehax::ui::Filters> {
  static runtime::Value toScript(runtime::Context ctx, rehax::ui::Filters& value) {
    auto obj = runtime::MakeObject(ctx);
    auto arr = runtime::MakeArray(ctx);
    for (int i = 0; i < value.defs.size(); i++) {
      auto js = Converter<rehax::ui::FilterDef>::toScript(ctx, value.defs[i]);
      runtime::SetArrayValue(ctx, arr, i, js);
    }
    runtime::SetObjectProperty(ctx, obj, "defs", arr);
    return obj;
  }
  static rehax::ui::Filters toCpp(runtime::Context ctx, const runtime::Value& value, Bindings * bindings, std::vector<runtime::Value>& retainedValues) {
    rehax::ui::Filters filters;
    if (runtime::HasObjectProperty(ctx, value, "defs")) {
      runtime::Value items = runtime::GetObjectProperty(ctx, value, "defs");
      int length = Converter<int>::toCpp(ctx, runtime::GetObjectProperty(ctx, items, "length"), bindings, retainedValues);
      for (int i = 0; i < length; i++) {
        auto item = runtime::GetArrayValue(ctx, items, i);
        filters.defs.push_back(Converter<rehax::ui::FilterDef>::toCpp(ctx, item, bindings, retainedValues));
      }
    }
    return filters;
  }
};
