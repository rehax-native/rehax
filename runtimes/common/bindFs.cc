
void Bindings::bindFs() {
  auto object = runtime::MakeObject(ctx);
  runtime::SetObjectProperty(ctx, object, "readFileSync", Converter<std::function<std::string(std::string, runtime::Value)>>::toScript(ctx, [] (std::string pathName, runtime::Value options) {
    std::ifstream t(pathName);
    std::stringstream buffer;
    buffer << t.rdbuf();
    return buffer.str();
  }, this));

  runtime::SetObjectProperty(ctx, object, "writeFileSync", Converter<std::function<void(std::string, runtime::Value, runtime::Value)>>::toScript(ctx, [] (std::string pathName, runtime::Value data, runtime::Value options) {
    // std::ifstream t(pathName);
    // std::stringstream buffer;
    // buffer << t.rdbuf();
    // return buffer.str();
  }, this));
    
  runtime::SetObjectProperty(ctx, object, "readdirSync", Converter<std::function<std::vector<std::string>(std::string)>>::toScript(ctx, [] (std::string pathName) {
    // std::ifstream t(pathName);
    // std::stringstream buffer;
    // buffer << t.rdbuf();
    // return buffer.str();
    std::vector<std::string> files = {
      "Dir1",
      "Dir2",
    };
    return files;
  }, this));

  runtime::Value rehax = runtime::GetRehaxObject(ctx);
  runtime::SetObjectProperty(ctx, rehax, "fs", object);
}
