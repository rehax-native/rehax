    
void Bindings::bindCrypto() {
  auto object = runtime::MakeObject(ctx);

  auto randomBytes = Converter<std::function<rehaxUtils::ObjectPointer<Buffer>(int)>>::toScript(ctx, [] (int size) {
    rehaxUtils::ObjectPointer<Buffer> buffer = rehaxUtils::Object<Buffer>::Create();

    // on Win32 we should use CryptoAPI and <wincrypt.h>.
    std::ifstream urandom("/dev/urandom", std::ios::in | std::ios::binary);
    if (urandom) {
      char * bufferData = new char[size];
      urandom.read(bufferData, size);
      if (urandom) {
        buffer->setData(bufferData);
      } else {
        std::cerr << "Failed to read from /dev/urandom" << std::endl;
      }
      urandom.close();
    }
    return buffer;
  }, this);
  runtime::SetObjectProperty(ctx, object, "randomBytes", randomBytes);

  runtime::Value rehax = runtime::GetRehaxObject(ctx);
  runtime::SetObjectProperty(ctx, rehax, "crypto", object);
}
