
#ifndef JS_STRICT_NAN_BOXING
template <>
struct Converter<runtime::Value> {
  static runtime::Value toScript(runtime::Context ctx, runtime::Value val, Bindings * bindings) {
    return val;
  }
  static runtime::Value toCpp(runtime::Context ctx, const runtime::Value& value, Bindings * bindings) {
    return value;
  }
};
#endif

template <typename Object>
struct Converter<rehaxUtils::ObjectPointer<Object>> {
  static runtime::Value toScript(runtime::Context ctx, rehaxUtils::ObjectPointer<Object> obj, Bindings * bindings) {
    if (!obj.hasPointer()) {
      return runtime::MakeNull(ctx);
    }
    return Converter<Object>::toScript(ctx, obj.get(), bindings);
  }
  static rehaxUtils::ObjectPointer<Object> toCpp(runtime::Context ctx, const runtime::Value& value, Bindings * bindings) {
    if (runtime::IsValueNull(ctx, value) || runtime::IsValueUndefined(ctx, value)) {
      return rehaxUtils::ObjectPointer<Object>(nullptr);
    }
    auto ptr = Converter<Object>::toCpp(ctx, value, bindings);
    return ptr->getThisPointer();
  }
};

template <typename Object>
struct Converter<rehaxUtils::WeakObjectPointer<Object>> {
  static runtime::Value toScript(runtime::Context ctx, rehaxUtils::WeakObjectPointer<Object> obj, Bindings * bindings) {
    if (!obj.isValid()) {
      return runtime::MakeNull(ctx);
    }
    return Converter<Object>::toScript(ctx, obj.get(), bindings);
  }
  static rehaxUtils::WeakObjectPointer<Object> toCpp(runtime::Context ctx, const runtime::Value& value, Bindings * bindings) {
    if (runtime::IsValueNull(ctx, value) || runtime::IsValueUndefined(ctx, value)) {
      return WeakObjectPointer<Object>(nullptr);
    }
    auto ptr = Converter<Object>::toCpp(ctx, value, bindings);
    return ptr->getThisPointer();
  }
};

template <typename T>
struct Converter<std::vector<T>> {
  static runtime::Value toScript(runtime::Context ctx, std::vector<T> obj, Bindings * bindings) {
    auto arr = runtime::MakeArray(ctx);
    for (int i = 0; i < obj.size(); i++) {
      auto js = Converter<T>::toScript(ctx, obj[i], bindings);
      runtime::SetArrayValue(ctx, arr, i, js);
    }
    return arr;
  }
  static std::vector<T> toCpp(runtime::Context ctx, const runtime::Value& value, Bindings * bindings) {
    int length = Converter<int>::toCpp(ctx, runtime::GetObjectProperty(ctx, value, "length"), bindings);
    std::vector<T> result;
    for (int i = 0; i < length; i++) {
      auto item = runtime::GetArrayValue(ctx, value, i);
      result.push_back(Converter<T>::toCpp(ctx, item, bindings));
    }
    return result;
  }
};

template <typename T>
struct Converter<std::unordered_map<std::string, T>> {
  static runtime::Value toScript(runtime::Context ctx, std::unordered_map<std::string, T> map, Bindings * bindings) {
    auto obj = runtime::MakeObject(ctx);
    for (auto & it : map) {
      runtime::SetObjectProperty(ctx, obj, it.first, Converter<T>::toScript(ctx, it.second, bindings));
    }
    return obj;
  }
  static std::unordered_map<std::string, T> toCpp(runtime::Context ctx, const runtime::Value& value, Bindings * bindings) {
    auto props = runtime::GetObjectProperties(ctx, value);
    std::unordered_map<std::string, T> result;
    for (auto & prop : props) {
      result[prop] = Converter<T>::toCpp(ctx, runtime::GetObjectProperty(ctx, value, prop), bindings);
    }
    return result;
  }
};

template <>
struct Converter<::rehax::ui::Color> {
  static runtime::Value toScript(runtime::Context ctx, ::rehax::ui::Color value, Bindings * bindings) {
    runtime::Value object = runtime::MakeObject(ctx);
    runtime::SetObjectProperty(ctx, object, "red", Converter<float>::toScript(ctx, value.r * 255.0));
    runtime::SetObjectProperty(ctx, object, "green", Converter<float>::toScript(ctx, value.g * 255.0));
    runtime::SetObjectProperty(ctx, object, "blue", Converter<float>::toScript(ctx, value.b * 255.0));
    runtime::SetObjectProperty(ctx, object, "alpha", Converter<float>::toScript(ctx, value.a));
    return object;
  }
  static ::rehax::ui::Color toCpp(runtime::Context ctx, const runtime::Value& colorValue, Bindings * bindings) {
    auto r = Converter<float>::toCpp(ctx, runtime::GetObjectProperty(ctx, colorValue, "red"), bindings);
    auto g = Converter<float>::toCpp(ctx, runtime::GetObjectProperty(ctx, colorValue, "green"), bindings);
    auto b = Converter<float>::toCpp(ctx, runtime::GetObjectProperty(ctx, colorValue, "blue"), bindings);
    auto a = Converter<float>::toCpp(ctx, runtime::GetObjectProperty(ctx, colorValue, "alpha"), bindings);
    return ui::Color::RGBA(
      r / 255.0,
      g / 255.0,
      b / 255.0,
      a
    );
  }
};

template <>
struct Converter<::rehax::ui::Length> {
  static runtime::Value toScript(runtime::Context ctx, ::rehax::ui::Length value, Bindings * bindings) {
    runtime::Value object = runtime::MakeObject(ctx);

    if (auto * p = std::get_if<::rehax::ui::LengthTypes::Natural>(&value)) {
      runtime::SetObjectProperty(ctx, object, "type", Converter<std::string>::toScript(ctx, "natural"));
    } else if (auto * p = std::get_if<::rehax::ui::LengthTypes::Fixed>(&value)) {
      runtime::SetObjectProperty(ctx, object, "type", Converter<std::string>::toScript(ctx, "fixed"));
      runtime::SetObjectProperty(ctx, object, "value", Converter<float>::toScript(ctx, p->length));
    } else if (auto * p = std::get_if<::rehax::ui::LengthTypes::Fill>(&value)) {
      runtime::SetObjectProperty(ctx, object, "type", Converter<std::string>::toScript(ctx, "fill"));
    } else if (auto * p = std::get_if<::rehax::ui::LengthTypes::Percentage>(&value)) {
      runtime::SetObjectProperty(ctx, object, "type", Converter<std::string>::toScript(ctx, "percent"));
      runtime::SetObjectProperty(ctx, object, "value", Converter<float>::toScript(ctx, p->percent));
    }

    return object;
  }
  static ::rehax::ui::Length toCpp(runtime::Context ctx, const runtime::Value& value, Bindings * bindings) {
    auto val = Converter<std::string>::toCpp(ctx, runtime::GetObjectProperty(ctx, value, "type"), bindings);
    if (val == "natural") {
      return ::rehax::ui::LengthTypes::Natural{};
    } else if (val == "fixed") {
      return ::rehax::ui::LengthTypes::Fixed {
        Converter<float>::toCpp(ctx, runtime::GetObjectProperty(ctx, value, "value"), bindings)
      };
    } else if (val == "fill") {
      return ::rehax::ui::LengthTypes::Fill{};
    } else if (val == "percent") {
      return ::rehax::ui::LengthTypes::Percentage{
        Converter<float>::toCpp(ctx, runtime::GetObjectProperty(ctx, value, "value"), bindings)
      };
    }
    return ::rehax::ui::LengthTypes::Natural();
  }
};

template <>
struct Converter<::rehax::ui::Size> {
  static runtime::Value toScript(runtime::Context ctx, ::rehax::ui::Size& value, Bindings * bindings) {
    runtime::Value obj = runtime::MakeObject(ctx);
    runtime::SetObjectProperty(ctx, obj, "width", Converter<float>::toScript(ctx, value.width));
    runtime::SetObjectProperty(ctx, obj, "height", Converter<float>::toScript(ctx, value.height));
    return obj;
  }
  static ::rehax::ui::Size toCpp(runtime::Context ctx, const runtime::Value& value, Bindings * bindings) {
    ::rehax::ui::Size size;
    if (runtime::HasObjectProperty(ctx, value, "width")) {
      size.width = Converter<float>::toCpp(ctx, runtime::GetObjectProperty(ctx, value, "width"), bindings);
    }
    if (runtime::HasObjectProperty(ctx, value, "height")) {
      size.height = Converter<float>::toCpp(ctx, runtime::GetObjectProperty(ctx, value, "height"), bindings);
    }
    return size;
  }
};

template <>
struct Converter<::rehax::ui::StackLayoutDirection> {
  static runtime::Value toScript(runtime::Context ctx, ::rehax::ui::StackLayoutDirection& value, Bindings * bindings) {
    if (value == ui::StackLayoutDirection::Vertical) {
      return Converter<std::string>::toScript(ctx, "vertical");
    }
    if (value == ui::StackLayoutDirection::Horizontal) {
      return Converter<std::string>::toScript(ctx, "horizontal");
    }
  }
  static ::rehax::ui::StackLayoutDirection toCpp(runtime::Context ctx, const runtime::Value& value, Bindings * bindings) {
    auto val = Converter<std::string>::toCpp(ctx, value, bindings);
    if (val == "horizontal") {
      return ui::StackLayoutDirection::Horizontal;
    }
    return ui::StackLayoutDirection::Vertical;
  }
};

template <>
struct Converter<::rehax::ui::StackLayoutOptions> {
  static runtime::Value toScript(runtime::Context ctx, ::rehax::ui::StackLayoutOptions& value, Bindings * bindings) {
    runtime::Value obj = runtime::MakeObject(ctx);
    runtime::SetObjectProperty(ctx, obj, "spacing", Converter<float>::toScript(ctx, value.spacing));
    runtime::SetObjectProperty(ctx, obj, "direction", Converter<::rehax::ui::StackLayoutDirection>::toScript(ctx, value.direction, bindings));
    return obj;
  }
  static ::rehax::ui::StackLayoutOptions toCpp(runtime::Context ctx, const runtime::Value& value, Bindings * bindings) {
    ::rehax::ui::StackLayoutOptions options;
    if (runtime::HasObjectProperty(ctx, value, "spacing")) {
      options.spacing = Converter<float>::toCpp(ctx, runtime::GetObjectProperty(ctx, value, "spacing"), bindings);
    }
    if (runtime::HasObjectProperty(ctx, value, "direction")) {
      options.direction = Converter<::rehax::ui::StackLayoutDirection>::toCpp(ctx, runtime::GetObjectProperty(ctx, value, "direction"), bindings);
    }
    return options;
  }
};

template <>
struct Converter<::rehax::ui::FlexLayoutDirection> {
  static runtime::Value toScript(runtime::Context ctx, ::rehax::ui::FlexLayoutDirection& value, Bindings * bindings) {
    if (value == ui::FlexLayoutDirection::Column) {
      return Converter<std::string>::toScript(ctx, "column");
    }
    if (value == ui::FlexLayoutDirection::ColumnReverse) {
      return Converter<std::string>::toScript(ctx, "column-reverse");
    }
    if (value == ui::FlexLayoutDirection::Row) {
      return Converter<std::string>::toScript(ctx, "row");
    }
    if (value == ui::FlexLayoutDirection::RowReverse) {
      return Converter<std::string>::toScript(ctx, "row-reverse");
    }
  }
  static ::rehax::ui::FlexLayoutDirection toCpp(runtime::Context ctx, const runtime::Value& value, Bindings * bindings) {
    auto val = Converter<std::string>::toCpp(ctx, value, bindings);
    if (val == "column") {
      return ui::FlexLayoutDirection::Column;
    }
    if (val == "column-reverse") {
      return ui::FlexLayoutDirection::ColumnReverse;
    }
    if (val == "row-reverse") {
      return ui::FlexLayoutDirection::RowReverse;
    }
    return ui::FlexLayoutDirection::Row;
  }
};

template <>
struct Converter<::rehax::ui::FlexJustifyContent> {
  static runtime::Value toScript(runtime::Context ctx, ::rehax::ui::FlexJustifyContent& value, Bindings * bindings) {
    if (value == ui::FlexJustifyContent::FlexStart) {
      return Converter<std::string>::toScript(ctx, "flex-start");
    }
    if (value == ui::FlexJustifyContent::FlexEnd) {
      return Converter<std::string>::toScript(ctx, "flex-end");
    }
    if (value == ui::FlexJustifyContent::Center) {
      return Converter<std::string>::toScript(ctx, "center");
    }
  }
  static ::rehax::ui::FlexJustifyContent toCpp(runtime::Context ctx, const runtime::Value& value, Bindings * bindings) {
    auto val = Converter<std::string>::toCpp(ctx, value, bindings);
    if (val == "flex-end") {
      return ui::FlexJustifyContent::FlexEnd;
    }
    if (val == "center") {
      return ui::FlexJustifyContent::Center;
    }
    return ui::FlexJustifyContent::FlexStart;
  }
};

template <>
struct Converter<::rehax::ui::FlexAlignItems> {
  static runtime::Value toScript(runtime::Context ctx, ::rehax::ui::FlexAlignItems& value, Bindings * bindings) {
    if (value == ui::FlexAlignItems::FlexStart) {
      return Converter<std::string>::toScript(ctx, "flex-start");
    }
    if (value == ui::FlexAlignItems::FlexEnd) {
      return Converter<std::string>::toScript(ctx, "flex-end");
    }
    if (value == ui::FlexAlignItems::Center) {
      return Converter<std::string>::toScript(ctx, "center");
    }
  }
  static ::rehax::ui::FlexAlignItems toCpp(runtime::Context ctx, const runtime::Value& value, Bindings * bindings) {
    auto val = Converter<std::string>::toCpp(ctx, value, bindings);
    if (val == "flex-end") {
      return ui::FlexAlignItems::FlexEnd;
    }
    if (val == "center") {
      return ui::FlexAlignItems::Center;
    }
    return ui::FlexAlignItems::FlexStart;
  }
};

template <>
struct Converter<::rehax::ui::FlexItem> {
  static runtime::Value toScript(runtime::Context ctx, ::rehax::ui::FlexItem& value, Bindings * bindings) {
    runtime::Value obj = runtime::MakeObject(ctx);
    runtime::SetObjectProperty(ctx, obj, "flexGrow", Converter<float>::toScript(ctx, value.flexGrow));
    runtime::SetObjectProperty(ctx, obj, "hasFlexGrow", Converter<bool>::toScript(ctx, value.hasFlexGrow));
    runtime::SetObjectProperty(ctx, obj, "order", Converter<int>::toScript(ctx, value.order));
    runtime::SetObjectProperty(ctx, obj, "alignSelf", Converter<::rehax::ui::FlexAlignItems>::toScript(ctx, value.alignSelf, bindings));
    return obj;
  }
  static ::rehax::ui::FlexItem toCpp(runtime::Context ctx, const runtime::Value& value, Bindings * bindings) {
    ::rehax::ui::FlexItem flexItem;
    if (runtime::HasObjectProperty(ctx, value, "flexGrow")) {
      flexItem.flexGrow = Converter<float>::toCpp(ctx, runtime::GetObjectProperty(ctx, value, "flexGrow"), bindings);
      flexItem.hasFlexGrow = true;
    }
    if (runtime::HasObjectProperty(ctx, value, "order")) {
      flexItem.order = Converter<int>::toCpp(ctx, runtime::GetObjectProperty(ctx, value, "order"), bindings);
    }
    if (runtime::HasObjectProperty(ctx, value, "alignSelf")) {
      flexItem.alignSelf = Converter<::rehax::ui::FlexAlignItems>::toCpp(ctx, runtime::GetObjectProperty(ctx, value, "alignSelf"), bindings);
    }
    return flexItem;
  }
};

template <>
struct Converter<::rehax::ui::FlexLayoutOptions> {
  static runtime::Value toScript(runtime::Context ctx, ::rehax::ui::FlexLayoutOptions& value, Bindings * bindings) {
    runtime::Value obj = runtime::MakeObject(ctx);
    runtime::SetObjectProperty(ctx, obj, "direction", Converter<::rehax::ui::FlexLayoutDirection>::toScript(ctx, value.direction, bindings));
    runtime::SetObjectProperty(ctx, obj, "justifyContent", Converter<::rehax::ui::FlexJustifyContent>::toScript(ctx, value.justifyContent, bindings));
    runtime::SetObjectProperty(ctx, obj, "alignItems", Converter<::rehax::ui::FlexAlignItems>::toScript(ctx, value.alignItems, bindings));

    auto arr = runtime::MakeArray(ctx);
    for (int i = 0; i < value.items.size(); i++) {
      auto js = Converter<::rehax::ui::FlexItem>::toScript(ctx, value.items[i], bindings);
      runtime::SetArrayValue(ctx, arr, i, js);
    }
    runtime::SetObjectProperty(ctx, obj, "items", arr);
    return obj;
  }
  static ::rehax::ui::FlexLayoutOptions toCpp(runtime::Context ctx, const runtime::Value& value, Bindings * bindings) {
    ::rehax::ui::FlexLayoutOptions options;
    if (runtime::HasObjectProperty(ctx, value, "direction")) {
      options.direction = Converter<::rehax::ui::FlexLayoutDirection>::toCpp(ctx, runtime::GetObjectProperty(ctx, value, "direction"), bindings);
    }
    if (runtime::HasObjectProperty(ctx, value, "justifyContent")) {
      options.justifyContent = Converter<::rehax::ui::FlexJustifyContent>::toCpp(ctx, runtime::GetObjectProperty(ctx, value, "justifyContent"), bindings);
    }
    if (runtime::HasObjectProperty(ctx, value, "alignItems")) {
      options.alignItems = Converter<::rehax::ui::FlexAlignItems>::toCpp(ctx, runtime::GetObjectProperty(ctx, value, "alignItems"), bindings);
    }
    if (runtime::HasObjectProperty(ctx, value, "items")) {
      runtime::Value items = runtime::GetObjectProperty(ctx, value, "items");
      int length = Converter<int>::toCpp(ctx, runtime::GetObjectProperty(ctx, items, "length"), bindings);
      for (int i = 0; i < length; i++) {
        auto item = runtime::GetArrayValue(ctx, items, i);
        options.items.push_back(Converter<::rehax::ui::FlexItem>::toCpp(ctx, item, bindings));
      }
    }
    return options;
  }
};

template <>
struct Converter<::rehax::ui::KeyEvent> {
  static runtime::Value toScript(runtime::Context ctx, ::rehax::ui::KeyEvent& value, Bindings * bindings) {
    runtime::Value obj = runtime::MakeObject(ctx);
    runtime::SetObjectProperty(ctx, obj, "key", Converter<std::string>::toScript(ctx, value.key));
    runtime::SetObjectProperty(ctx, obj, "isKeyDown", Converter<bool>::toScript(ctx, value.isKeyDown));
    return obj;
  }
  static ::rehax::ui::KeyEvent toCpp(runtime::Context ctx, const runtime::Value& value, Bindings * bindings) {
    ::rehax::ui::KeyEvent event;
    if (runtime::HasObjectProperty(ctx, value, "key")) {
      event.key = Converter<std::string>::toCpp(ctx, runtime::GetObjectProperty(ctx, value, "key"), bindings);
    }
    if (runtime::HasObjectProperty(ctx, value, "isKeyDown")) {
      event.isKeyDown = Converter<bool>::toCpp(ctx, runtime::GetObjectProperty(ctx, value, "isKeyDown"), bindings);
    }
    return event;
  }
};

template <>
struct Converter<::rehax::ui::GestureState> {
  static runtime::Value toScript(runtime::Context ctx, ::rehax::ui::GestureState& value, Bindings * bindings) {
    if (value == ui::GestureState::Possible) {
      return Converter<std::string>::toScript(ctx, "possible");
    }
    if (value == ui::GestureState::Recognized) {
      return Converter<std::string>::toScript(ctx, "recognized");
    }
    if (value == ui::GestureState::Began) {
      return Converter<std::string>::toScript(ctx, "began");
    }
    if (value == ui::GestureState::Changed) {
      return Converter<std::string>::toScript(ctx, "changed");
    }
    if (value == ui::GestureState::Canceled) {
      return Converter<std::string>::toScript(ctx, "canceled");
    }
    if (value == ui::GestureState::Ended) {
      return Converter<std::string>::toScript(ctx, "ended");
    }
  }
  static ::rehax::ui::GestureState toCpp(runtime::Context ctx, const runtime::Value& value, Bindings * bindings) {
    auto val = Converter<std::string>::toCpp(ctx, value, bindings);
    if (val == "recognized") {
      return ui::GestureState::Recognized;
    }
    if (val == "began") {
      return ui::GestureState::Began;
    }
    if (val == "changed") {
      return ui::GestureState::Changed;
    }
    if (val == "canceled") {
      return ui::GestureState::Canceled;
    }
    if (val == "ended") {
      return ui::GestureState::Ended;
    }
    return ui::GestureState::Possible;
  }
};

template <>
struct Converter<::rehax::ui::SelectOption> {
  static runtime::Value toScript(runtime::Context ctx, ::rehax::ui::SelectOption& value, Bindings * bindings) {
    runtime::Value obj = runtime::MakeObject(ctx);
    runtime::SetObjectProperty(ctx, obj, "name", Converter<std::string>::toScript(ctx, value.name));
    runtime::SetObjectProperty(ctx, obj, "value", Converter<std::string>::toScript(ctx, value.value));
    return obj;
  }
  static ::rehax::ui::SelectOption toCpp(runtime::Context ctx, const runtime::Value& value, Bindings * bindings) {
    ::rehax::ui::SelectOption option;
    if (runtime::HasObjectProperty(ctx, value, "name")) {
      option.name = Converter<std::string>::toCpp(ctx, runtime::GetObjectProperty(ctx, value, "name"), bindings);
    }
    if (runtime::HasObjectProperty(ctx, value, "value")) {
      option.value = Converter<std::string>::toCpp(ctx, runtime::GetObjectProperty(ctx, value, "value"), bindings);
    }
    return option;
  }
};

template <>
struct Converter<::rehax::ui::VectorLineCap> {
  static runtime::Value toScript(runtime::Context ctx, ::rehax::ui::VectorLineCap& value, Bindings * bindings) {
    if (value == ui::VectorLineCap::Butt) {
      return Converter<std::string>::toScript(ctx, "butt");
    }
    if (value == ui::VectorLineCap::Square) {
      return Converter<std::string>::toScript(ctx, "square");
    }
    if (value == ui::VectorLineCap::Round) {
      return Converter<std::string>::toScript(ctx, "round");
    }
  }
  static ::rehax::ui::VectorLineCap toCpp(runtime::Context ctx, const runtime::Value& value, Bindings * bindings) {
    auto val = Converter<std::string>::toCpp(ctx, value, bindings);
    if (val == "square") {
      return ui::VectorLineCap::Square;
    }
    if (val == "round") {
      return ui::VectorLineCap::Round;
    }
    return ui::VectorLineCap::Butt;
  }
};

template <>
struct Converter<::rehax::ui::VectorLineJoin> {
  static runtime::Value toScript(runtime::Context ctx, ::rehax::ui::VectorLineJoin& value, Bindings * bindings) {
    if (value == ui::VectorLineJoin::Miter) {
      return Converter<std::string>::toScript(ctx, "miter");
    }
    if (value == ui::VectorLineJoin::Round) {
      return Converter<std::string>::toScript(ctx, "round");
    }
    if (value == ui::VectorLineJoin::Bevel) {
      return Converter<std::string>::toScript(ctx, "bevel");
    }
  }
  static ::rehax::ui::VectorLineJoin toCpp(runtime::Context ctx, const runtime::Value& value, Bindings * bindings) {
    auto val = Converter<std::string>::toCpp(ctx, value, bindings);
    if (val == "round") {
      return ui::VectorLineJoin::Round;
    }
    if (val == "bevel") {
      return ui::VectorLineJoin::Bevel;
    }
    return ui::VectorLineJoin::Miter;
  }
};

template <>
struct Converter<::rehax::ui::GradientStop> {
  static runtime::Value toScript(runtime::Context ctx, ::rehax::ui::GradientStop& value, Bindings * bindings) {
    runtime::Value obj = runtime::MakeObject(ctx);
    runtime::SetObjectProperty(ctx, obj, "color", Converter<::rehax::ui::Color>::toScript(ctx, value.color, bindings));
    runtime::SetObjectProperty(ctx, obj, "offset", Converter<float>::toScript(ctx, value.offset));
    return obj;
  }
  static ::rehax::ui::GradientStop toCpp(runtime::Context ctx, const runtime::Value& value, Bindings * bindings) {
    ::rehax::ui::GradientStop stop;
    if (runtime::HasObjectProperty(ctx, value, "color")) {
      stop.color = Converter<::rehax::ui::Color>::toCpp(ctx, runtime::GetObjectProperty(ctx, value, "color"), bindings);
    }
    if (runtime::HasObjectProperty(ctx, value, "offset")) {
      stop.offset = Converter<float>::toCpp(ctx, runtime::GetObjectProperty(ctx, value, "offset"), bindings);
    }
    return stop;
  }
};

template <>
struct Converter<::rehax::ui::Gradient> {
  static runtime::Value toScript(runtime::Context ctx, ::rehax::ui::Gradient& value, Bindings * bindings) {
    auto obj = runtime::MakeObject(ctx);
    auto arr = runtime::MakeArray(ctx);
    for (int i = 0; i < value.stops.size(); i++) {
      auto js = Converter<::rehax::ui::GradientStop>::toScript(ctx, value.stops[i], bindings);
      runtime::SetArrayValue(ctx, arr, i, js);
    }
    runtime::SetObjectProperty(ctx, obj, "stops", arr);
    return obj;
  }
  static ::rehax::ui::Gradient toCpp(runtime::Context ctx, const runtime::Value& value, Bindings * bindings) {
    ::rehax::ui::Gradient gradient;
    if (runtime::HasObjectProperty(ctx, value, "stops")) {
      runtime::Value items = runtime::GetObjectProperty(ctx, value, "stops");
      int length = Converter<int>::toCpp(ctx, runtime::GetObjectProperty(ctx, items, "length"), bindings);
      for (int i = 0; i < length; i++) {
        auto item = runtime::GetArrayValue(ctx, items, i);
        gradient.stops.push_back(Converter<::rehax::ui::GradientStop>::toCpp(ctx, item, bindings));
      }
    }
    return gradient;
  }
};

template <>
struct Converter<::rehax::ui::FilterDef> {
  static runtime::Value toScript(runtime::Context ctx, ::rehax::ui::FilterDef& value, Bindings * bindings) {
    auto obj = runtime::MakeObject(ctx);
    runtime::SetObjectProperty(ctx, obj, "type", Converter<int>::toScript(ctx, value.type));
    runtime::SetObjectProperty(ctx, obj, "blurRadius", Converter<float>::toScript(ctx, value.blurRadius));
    return obj;
  }
  static ::rehax::ui::FilterDef toCpp(runtime::Context ctx, const runtime::Value& value, Bindings * bindings) {
    ::rehax::ui::FilterDef def;
    if (runtime::HasObjectProperty(ctx, value, "type")) {
      def.type = Converter<int>::toCpp(ctx, runtime::GetObjectProperty(ctx, value, "type"), bindings);
    }
    if (runtime::HasObjectProperty(ctx, value, "blurRadius")) {
      def.blurRadius = Converter<float>::toCpp(ctx, runtime::GetObjectProperty(ctx, value, "blurRadius"), bindings);
    }
    return def;
  }
};

template <>
struct Converter<::rehax::ui::Filters> {
  static runtime::Value toScript(runtime::Context ctx, ::rehax::ui::Filters& value, Bindings * bindings) {
    auto obj = runtime::MakeObject(ctx);
    auto arr = runtime::MakeArray(ctx);
    for (int i = 0; i < value.defs.size(); i++) {
      auto js = Converter<::rehax::ui::FilterDef>::toScript(ctx, value.defs[i], bindings);
      runtime::SetArrayValue(ctx, arr, i, js);
    }
    runtime::SetObjectProperty(ctx, obj, "defs", arr);
    return obj;
  }
  static ::rehax::ui::Filters toCpp(runtime::Context ctx, const runtime::Value& value, Bindings * bindings) {
    ::rehax::ui::Filters filters;
    if (runtime::HasObjectProperty(ctx, value, "defs")) {
      runtime::Value items = runtime::GetObjectProperty(ctx, value, "defs");
      int length = Converter<int>::toCpp(ctx, runtime::GetObjectProperty(ctx, items, "length"), bindings);
      for (int i = 0; i < length; i++) {
        auto item = runtime::GetArrayValue(ctx, items, i);
        filters.defs.push_back(Converter<::rehax::ui::FilterDef>::toCpp(ctx, item, bindings));
      }
    }
    return filters;
  }
};
