// This should support local storage in app bundles
    
void Bindings::bindLocalStorage() {
  auto object = runtime::MakeObject(ctx);

  auto configure = Converter<std::function<void(std::string)>>::toScript(ctx, [this] (std::string savePath) {
    runtime::Value globalObject = runtime::GetGlobalObject(ctx);
    auto localStorage = runtime::GetObjectProperty(ctx, globalObject, "localStorage");
    runtime::SetObjectProperty(ctx, localStorage, "__savePath", Converter<std::string>::toScript(ctx, savePath));
  }, this);

  auto setItem = Converter<std::function<void(std::string, std::string)>>::toScript(ctx, [this] (std::string key, std::string value) {
    runtime::Value globalObject = runtime::GetGlobalObject(ctx);
    auto localStorage = runtime::GetObjectProperty(ctx, globalObject, "localStorage");
    std::vector<runtime::Value> retainedValues;
    auto savePath = Converter<std::string>::toCpp(ctx, runtime::GetObjectProperty(ctx, localStorage, "__savePath"), nullptr, retainedValues);
    std::string filePath = savePath + "/" + key;

    if (!std::filesystem::exists(savePath)) {
      std::filesystem::create_directories(savePath);
    }

    std::ofstream file(filePath, std::ios::trunc);
    file << value;
  }, this);

  auto getItem = Converter<std::function<std::string(std::string)>>::toScript(ctx, [this] (std::string key) {
    runtime::Value globalObject = runtime::GetGlobalObject(ctx);
    auto localStorage = runtime::GetObjectProperty(ctx, globalObject, "localStorage");
    std::vector<runtime::Value> retainedValues;
    auto savePath = Converter<std::string>::toCpp(ctx, runtime::GetObjectProperty(ctx, localStorage, "__savePath"), nullptr, retainedValues);
    auto filePath = savePath + "/" + key;
    if (!std::filesystem::exists(filePath)) {
      return std::string("");
    }

    std::ifstream t(filePath);
    std::stringstream buffer;
    buffer << t.rdbuf();
    return buffer.str();
  }, this);

  auto removeItem = Converter<std::function<void(std::string)>>::toScript(ctx, [this] (std::string key) {
    runtime::Value globalObject = runtime::GetGlobalObject(ctx);
    auto localStorage = runtime::GetObjectProperty(ctx, globalObject, "localStorage");
    std::vector<runtime::Value> retainedValues;
    auto savePath = Converter<std::string>::toCpp(ctx, runtime::GetObjectProperty(ctx, localStorage, "__savePath"), nullptr, retainedValues);
    auto filePath = savePath + "/" + key;
    if (!std::filesystem::exists(filePath)) {
      return;
    }
    std::filesystem::remove(filePath);
  }, this);

  auto clear = Converter<std::function<void(void)>>::toScript(ctx, [this] () {
    runtime::Value globalObject = runtime::GetGlobalObject(ctx);
    auto localStorage = runtime::GetObjectProperty(ctx, globalObject, "localStorage");
    std::vector<runtime::Value> retainedValues;
    auto savePath = Converter<std::string>::toCpp(ctx, runtime::GetObjectProperty(ctx, localStorage, "__savePath"), nullptr, retainedValues);
    std::filesystem::remove_all(savePath);
  }, this);

  runtime::SetObjectProperty(ctx, object, "configure", configure);
  runtime::SetObjectProperty(ctx, object, "setItem", setItem);
  runtime::SetObjectProperty(ctx, object, "getItem", getItem);
  runtime::SetObjectProperty(ctx, object, "removeItem", removeItem);
  runtime::SetObjectProperty(ctx, object, "clear", clear);

  auto supportDir = rehaxUtils::App::getApplicationSupportDirectoryForApp();
  runtime::SetObjectProperty(ctx, object, "__savePath", Converter<std::string>::toScript(ctx, supportDir + "/localStorage"));

  runtime::Value globalObject = runtime::GetGlobalObject(ctx);
  runtime::SetObjectProperty(ctx, globalObject, "localStorage", object);
}
