
void Bindings::bindRequire() {
  auto require = Converter<std::function<runtime::Value(std::string)>>::toScript(ctx, [this] (std::string module) {
    return runtime::GetObjectProperty(ctx, runtime::GetRehaxObject(ctx), module);
  }, this);
  auto global = runtime::GetGlobalObject(ctx);
  runtime::SetObjectProperty(ctx, global, "require", require);
}
