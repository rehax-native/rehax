    
// struct FetchResponse {

// }

// struct FetchRequest {
//     std::string url;
//     std::function<
// };

class HttpBodyWrapper : public rehaxUtils::HttpBody {
public:
    static std::string ClassName() {
      return "HttpBody";
    }
    
    std::string instanceClassName() {
      return HttpBodyWrapper::ClassName();
    }
    
    HttpBodyWrapper(void * data, size_t size)
    :HttpBody(data, size)
    {}
    
    HttpBodyWrapper()
    :HttpBody()
    {}
    
    template <typename... Args>
    static rehaxUtils::ObjectPointer<HttpBodyWrapper> Create(Args&&... args) {
      auto ptr = Object<HttpBodyWrapper>::Create(std::forward<Args>(args)...);
      return ptr;
    }
};

template <>
struct Converter<rehaxUtils::HttpMethod> {
  static runtime::Value toScript(runtime::Context ctx, rehaxUtils::HttpMethod value) {
    switch (value) {
      case rehaxUtils::HttpMethod::GET: return Converter<std::string>::toScript(ctx, "GET");
      case rehaxUtils::HttpMethod::POST: return Converter<std::string>::toScript(ctx, "POST");
      case rehaxUtils::HttpMethod::PUT: return Converter<std::string>::toScript(ctx, "PUT");
      case rehaxUtils::HttpMethod::PATCH: return Converter<std::string>::toScript(ctx, "PATCH");
      case rehaxUtils::HttpMethod::DELETE: return Converter<std::string>::toScript(ctx, "DELETE");
      case rehaxUtils::HttpMethod::OPTIONS: return Converter<std::string>::toScript(ctx, "OPTIONS");
    }
  }
  static rehaxUtils::HttpMethod toCpp(runtime::Context ctx, const runtime::Value& value, Bindings * bindings) {
    auto val = Converter<std::string>::toCpp(ctx, value, bindings);
    if (val == "POST") return rehaxUtils::HttpMethod::POST;
    if (val == "PUT") return rehaxUtils::HttpMethod::PUT;
    if (val == "PATCH") return rehaxUtils::HttpMethod::PATCH;
    if (val == "DELETE") return rehaxUtils::HttpMethod::DELETE;
    if (val == "OPTIONS") return rehaxUtils::HttpMethod::OPTIONS;
    return rehaxUtils::HttpMethod::GET;
  }
};

template <>
struct Converter<rehaxUtils::ObjectPointer<HttpBodyWrapper>> {
  static runtime::Value toScript(runtime::Context ctx, rehaxUtils::ObjectPointer<HttpBodyWrapper> value, Bindings * bindings) {
    runtime::Value object = runtime::MakeObject(ctx);
    runtime::SetObjectProperty(ctx, object, "toString", Converter<std::function<std::string(void)>>::toScript(ctx, [value] () {
      if (!value.hasPointer()) {
        return std::string("");
      }
      std::string ret(static_cast<const char*>(value->data()), value->size());
      return ret;
    }, bindings));
    return object;
  }
  static rehaxUtils::ObjectPointer<HttpBodyWrapper> toCpp(runtime::Context ctx, const runtime::Value& value, Bindings * bindings) {
    if (runtime::IsValueString(ctx, value)) {
      auto str = Converter<std::string>::toCpp(ctx, value, bindings);
      const char * strData = new char[str.size()];
      memcpy((void*) strData, (void*) str.data(), str.size());
      auto body = rehaxUtils::Object<HttpBodyWrapper>::Create((void*) strData, str.size());
      return body;
    }
    return {};
  }
};

template <>
struct Converter<rehaxUtils::HttpResponse> {
  static runtime::Value toScript(runtime::Context ctx, rehaxUtils::HttpResponse value, Bindings * bindings) {
    runtime::Value object = runtime::MakeObject(ctx);
    runtime::SetObjectProperty(ctx, object, "errorMessage", Converter<std::string>::toScript(ctx, value.errorMessage));
    runtime::SetObjectProperty(ctx, object, "status", Converter<int>::toScript(ctx, value.status));
//    auto bodyPtr = rehaxUtils::dynamic_pointer_cast<HttpBodyWrapper>(value.body.get());
    rehaxUtils::HttpBody * bodyPtr = value.body.get();
    auto obj = rehaxUtils::ObjectPointer<HttpBodyWrapper>((HttpBodyWrapper *) bodyPtr);
    runtime::SetObjectProperty(ctx, object, "body", Converter<rehaxUtils::ObjectPointer<HttpBodyWrapper>>::toScript(ctx, obj, bindings));
    return object;
  }
  static rehaxUtils::HttpResponse toCpp(runtime::Context ctx, const runtime::Value& value, Bindings * bindings) {
    auto errorMessage = Converter<std::string>::toCpp(ctx, runtime::GetObjectProperty(ctx, value, "errorMessage"), bindings);
    auto status = Converter<int>::toCpp(ctx, runtime::GetObjectProperty(ctx, value, "status"), bindings);
    return {
      .errorMessage = errorMessage,
      .status = status,
    };
  }
};

template <>
struct Converter<rehaxUtils::HttpRequest> {
  static runtime::Value toScript(runtime::Context ctx, rehaxUtils::HttpRequest value, Bindings * bindings) {
    runtime::Value object = runtime::MakeObject(ctx);
      
    runtime::SetObjectProperty(ctx, object, "url", Converter<std::string>::toScript(ctx, value.url));
    runtime::SetObjectProperty(ctx, object, "method", Converter<rehaxUtils::HttpMethod>::toScript(ctx, value.method));
    runtime::SetObjectProperty(ctx, object, "requestHeaders", Converter<std::unordered_map<std::string, std::string>>::toScript(ctx, value.requestHeaders, bindings));
    return object;
  }
  static rehaxUtils::HttpRequest toCpp(runtime::Context ctx, const runtime::Value& value, Bindings * bindings) {
    auto url = Converter<std::string>::toCpp(ctx, runtime::GetObjectProperty(ctx, value, "url"), bindings);
    auto method = Converter<rehaxUtils::HttpMethod>::toCpp(ctx, runtime::GetObjectProperty(ctx, value, "method"), bindings);
    auto callback = Converter<std::function<void(rehaxUtils::HttpResponse)>>::toCpp(ctx, runtime::GetObjectProperty(ctx, value, "callback"), bindings);
    auto requestHeaders = Converter<std::unordered_map<std::string, std::string>>::toCpp(ctx, runtime::GetObjectProperty(ctx, value, "requestHeaders"), bindings);
      
    rehaxUtils::ObjectPointer<HttpBodyWrapper> body;
    if (runtime::HasObjectProperty(ctx, value, "body")) {
      body = Converter<rehaxUtils::ObjectPointer<HttpBodyWrapper>>::toCpp(ctx, runtime::GetObjectProperty(ctx, value, "body"), bindings);
    }
    return {
      .url = url,
      .method = method,
      .callback = callback,
      .requestHeaders = requestHeaders,
      .body = body,
    };
  }
};

void Bindings::bindFetch() {
  defineClass<HttpBodyWrapper>("HttpBody", nullptr);
    
  auto object = runtime::MakeObject(ctx);
  runtime::SetObjectProperty(ctx, object, "request", Converter<std::function<void(rehaxUtils::HttpRequest)>>::toScript(ctx, [] (rehaxUtils::HttpRequest request) {
    rehaxUtils::HttpFetch::makeRequest(request);
  }, this));

  runtime::Value rehax = runtime::GetRehaxObject(ctx);
  runtime::SetObjectProperty(ctx, rehax, "fetch", object);
}
