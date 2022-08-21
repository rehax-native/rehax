
class Buffer : public rehaxUtils::Object<Buffer> {
  char * data = nullptr;
public:
  static std::string ClassName() {
    return "Buffer";
  }

  std::string instanceClassName() {
    return "Buffer";
  }

  Buffer() {}
  ~Buffer() {
    if (data != nullptr) {
      delete data;
    }
  }

  void setData(char * data) {
    this->data = data;
  }

  uint32_t readUInt32BE(size_t offset) {
    char * t = &data[offset];
    uint32_t v = 0;
    char * p = (char *) &v;
    p[0] = t[0];
    p[1] = t[1];
    p[2] = t[2];
    p[3] = t[3];
    return v;
  }
  uint32_t readUInt32LE(size_t offset) {
    char * t = &data[offset];
    uint32_t v = 0;
    char * p = (char *) &v;
    p[3] = t[0];
    p[2] = t[1];
    p[1] = t[2];
    p[0] = t[3];
    return v;
  }
};
    
void Bindings::bindBuffer() {
  defineClass<Buffer>("Buffer", nullptr);

  bindMethod<Buffer, uint32_t, size_t, &Buffer::readUInt32BE>("readUInt32BE", classRegistry["Buffer"].prototype);
  bindMethod<Buffer, uint32_t, size_t, &Buffer::readUInt32LE>("readUInt32LE", classRegistry["Buffer"].prototype);

  auto rehax = runtime::GetRehaxObject(ctx);
  auto global = runtime::GetGlobalObject(ctx);

  runtime::SetObjectProperty(ctx, global, "Buffer", runtime::GetObjectProperty(ctx, rehax, "Buffer"));
}
