    
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
      case rehaxUtils::OSName::Unknown:
        return "unknown";
    }
    return "unknown";
  }, this);
  runtime::SetObjectProperty(ctx, object, "name", name);

  runtime::Value rehax = runtime::GetRehaxObject(ctx);
  runtime::SetObjectProperty(ctx, rehax, "os", object);
}

template <>
struct Converter<::rehaxUtils::App::ApplicationTheme> {
  static runtime::Value toScript(runtime::Context ctx, ::rehaxUtils::App::ApplicationTheme& value, Bindings * bindings) {
    if (value == ::rehaxUtils::App::ApplicationTheme::Unsupported) {
      return Converter<std::string>::toScript(ctx, "unsupported");
    }
    if (value == ::rehaxUtils::App::ApplicationTheme::SystemDark) {
      return Converter<std::string>::toScript(ctx, "system-dark");
    }
    if (value == ::rehaxUtils::App::ApplicationTheme::SystemLight) {
      return Converter<std::string>::toScript(ctx, "system-light");
    }
  }
  static ::rehaxUtils::App::ApplicationTheme toCpp(runtime::Context ctx, const runtime::Value& value, Bindings * bindings) {
    auto val = Converter<std::string>::toCpp(ctx, value, bindings);
    if (val == "system-light") {
      return ::rehaxUtils::App::ApplicationTheme::SystemLight;
    }
    if (val == "system-dark") {
      return ::rehaxUtils::App::ApplicationTheme::SystemDark;
    }
    return ::rehaxUtils::App::ApplicationTheme::Unsupported;
  }
};

template <>
struct Converter<::rehaxUtils::App::ApplicationThemeListenerId> {
  static runtime::Value toScript(runtime::Context ctx, ::rehaxUtils::App::ApplicationThemeListenerId& value, Bindings * bindings) {
    return Converter<int>::toScript(ctx, value.id);
  }
  static ::rehaxUtils::App::ApplicationThemeListenerId toCpp(runtime::Context ctx, const runtime::Value& value, Bindings * bindings) {
    return { Converter<int>::toCpp(ctx, value, bindings) };
  }
};

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

  auto getApplicationTheme = Converter<std::function<rehaxUtils::App::ApplicationTheme(void)>>::toScript(ctx, [] () {
    return rehaxUtils::App::getApplicationTheme();
  }, this);
  runtime::SetObjectProperty(ctx, object, "getApplicationTheme", getApplicationTheme);

  auto addApplicationThemeChangeListener = Converter<std::function<rehaxUtils::App::ApplicationThemeListenerId(std::function<void(rehaxUtils::App::ApplicationTheme)>)>>::toScript(ctx, [] (std::function<void(rehaxUtils::App::ApplicationTheme)> cb) {
    return rehaxUtils::App::addApplicationThemeChangeListener(cb);
  }, this);
  runtime::SetObjectProperty(ctx, object, "addApplicationThemeChangeListener", addApplicationThemeChangeListener);
  
  auto removeApplicationThemeChangeListener = Converter<std::function<void(rehaxUtils::App::ApplicationThemeListenerId)>>::toScript(ctx, [] (rehaxUtils::App::ApplicationThemeListenerId listener) {
    rehaxUtils::App::removeApplicationThemeChangeListener(listener);
  }, this);
  runtime::SetObjectProperty(ctx, object, "removeApplicationThemeChangeListener", removeApplicationThemeChangeListener);

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
