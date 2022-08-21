    
void Bindings::bindLinks() {
  auto object = runtime::MakeObject(ctx);

  auto openLink = Converter<std::function<void(std::string)>>::toScript(ctx, [] (std::string link) {
    rehaxUtils::Links::openUrl(link);
  }, this);

  runtime::SetObjectProperty(ctx, object, "openLink", openLink);

  runtime::Value rehax = runtime::GetRehaxObject(ctx);
  runtime::SetObjectProperty(ctx, rehax, "links", object);
}
