    
struct FileEntry {
    std::string name;
    bool isFile;
    bool isDirectory;
};

template <>
struct Converter<FileEntry> {
  static runtime::Value toScript(runtime::Context ctx, FileEntry value, Bindings * bindings) {
    runtime::Value object = runtime::MakeObject(ctx);
    runtime::SetObjectProperty(ctx, object, "name", Converter<std::string>::toScript(ctx, value.name));
    runtime::SetObjectProperty(ctx, object, "isFile", Converter<bool>::toScript(ctx, value.isFile));
    runtime::SetObjectProperty(ctx, object, "isDirectory", Converter<bool>::toScript(ctx, value.isDirectory));
    return object;
  }
  static FileEntry toCpp(runtime::Context ctx, const runtime::Value& value, Bindings * bindings) {
    auto name = Converter<std::string>::toCpp(ctx, runtime::GetObjectProperty(ctx, value, "name"), bindings);
    auto isFile = Converter<bool>::toCpp(ctx, runtime::GetObjectProperty(ctx, value, "isFile"), bindings);
    auto isDirectory = Converter<bool>::toCpp(ctx, runtime::GetObjectProperty(ctx, value, "isDirectory"), bindings);
    return {
      .name = name,
      .isFile = isFile,
      .isDirectory = isDirectory,
    };
  }
};

void Bindings::bindFs() {
  auto object = runtime::MakeObject(ctx);
  runtime::SetObjectProperty(ctx, object, "readFileSync", Converter<std::function<std::string(std::string, runtime::Value)>>::toScript(ctx, [] (std::string pathName, runtime::Value options) {
    std::ifstream t(pathName);
    std::stringstream buffer;
    buffer << t.rdbuf();
    return buffer.str();
  }, this));

  runtime::SetObjectProperty(ctx, object, "writeFileSync", Converter<std::function<void(std::string, runtime::Value, runtime::Value)>>::toScript(ctx, [this] (std::string pathName, runtime::Value data, runtime::Value options) {
    std::ofstream myfile;
    myfile.open (pathName);
    auto contents = Converter<std::string>::toCpp(ctx, data, this);
    myfile << contents;
    myfile.close();
  }, this));
    
  runtime::SetObjectProperty(ctx, object, "readdirSync", Converter<std::function<runtime::Value(std::string, runtime::Value)>>::toScript(ctx, [this] (std::string pathName, runtime::Value options) {
    if (!runtime::IsValueUndefined(ctx, options) && !runtime::IsValueNull(ctx, options)) {
      std::vector<FileEntry> files = {};
      for (const auto & entry : std::filesystem::directory_iterator(pathName)) {
        files.push_back(FileEntry {
          .name = entry.path().filename().string(),
          .isFile = entry.is_regular_file(),
          .isDirectory = entry.is_directory(),
        });
      }
      return Converter<std::vector<FileEntry>>::toScript(ctx, files, this);
    }
    std::vector<std::string> files = {};
    for (const auto & entry : std::filesystem::directory_iterator(pathName)) {
      files.push_back(entry.path().string());
    }
    return Converter<std::vector<std::string>>::toScript(ctx, files, this);
  }, this));

  runtime::Value rehax = runtime::GetRehaxObject(ctx);
  runtime::SetObjectProperty(ctx, rehax, "fs", object);
}
