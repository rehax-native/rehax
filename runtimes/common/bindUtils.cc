    
void Bindings::bindOS() {
  auto object = runtime::MakeObject(ctx);

  auto name = Converter<std::function<std::string(void)>>::toScript(ctx, [] () {
    switch (rehaxUtils::OS::name()) {
      case rehaxUtils::OSName::Android:
        return "android";
      case rehaxUtils::OSName::IOs:
        return "ios";
      case rehaxUtils::OSName::Mac:
        return "mac";
      case rehaxUtils::OSName::Linux:
        return "linux";
      case rehaxUtils::OSName::Windows:
        return "windows";
    }
  }, this);
  runtime::SetObjectProperty(ctx, object, "name", name);

  runtime::Value rehax = runtime::GetRehaxObject(ctx);
  runtime::SetObjectProperty(ctx, rehax, "os", object);
}

void Bindings::bindApp() {
  auto object = runtime::MakeObject(ctx);
  rehaxUtils::OS::isWindows();

  auto getCurrentUserHomeDirectory = Converter<std::function<std::string(void)>>::toScript(ctx, [] () {
    return rehaxUtils::Paths::getCurrentUserHomeDirectory();
  }, this);
  runtime::SetObjectProperty(ctx, object, "getCurrentUserHomeDirectory", getCurrentUserHomeDirectory);

  auto getCurrentUserDesktopDirectory = Converter<std::function<std::string(void)>>::toScript(ctx, [] () {
    return rehaxUtils::Paths::getCurrentUserDesktopDirectory();
  }, this);
  runtime::SetObjectProperty(ctx, object, "getCurrentUserDesktopDirectory", getCurrentUserDesktopDirectory);

  auto getApplicationSupportDirectory = Converter<std::function<std::string(void)>>::toScript(ctx, [] () {
    return rehaxUtils::App::getApplicationSupportDirectory();
  }, this);
  runtime::SetObjectProperty(ctx, object, "getApplicationSupportDirectory", getApplicationSupportDirectory);

  auto getApplicationSupportDirectoryForApp = Converter<std::function<std::string(void)>>::toScript(ctx, [] () {
    return rehaxUtils::App::getApplicationSupportDirectoryForApp();
  }, this);
  runtime::SetObjectProperty(ctx, object, "getApplicationSupportDirectoryForApp", getApplicationSupportDirectoryForApp);

  auto getApplicationGroupContainerDirectory = Converter<std::function<std::string(std::string appGroupId)>>::toScript(ctx, [] (std::string appGroupId) {
    return rehaxUtils::App::getApplicationGroupContainerDirectory(appGroupId);
  }, this);
  runtime::SetObjectProperty(ctx, object, "getApplicationGroupContainerDirectory", getApplicationGroupContainerDirectory);

  runtime::Value rehax = runtime::GetRehaxObject(ctx);
  runtime::SetObjectProperty(ctx, rehax, "app", object);
}

void Bindings::bindLinking() {
  auto object = runtime::MakeObject(ctx);

  auto openLink = Converter<std::function<void(std::string)>>::toScript(ctx, [] (std::string link) {
    rehaxUtils::Linking::openUrl(link);
  }, this);

  runtime::SetObjectProperty(ctx, object, "openLink", openLink);

  runtime::Value rehax = runtime::GetRehaxObject(ctx);
  runtime::SetObjectProperty(ctx, rehax, "Linking", object);
}
