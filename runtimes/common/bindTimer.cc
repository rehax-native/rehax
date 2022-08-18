    
void Bindings::bindTimer() {
  static int nextTimerId = 1;

  auto setTimeout = Converter<std::function<int(std::function<void(void)>, int)>>::toScript(ctx, [this] (std::function<void(void)> callback, int timeout) {
    auto timerId = nextTimerId++;

    rehaxUtils::Timer * timer = rehaxUtils::Timer::startInterval(timeout, [this, timerId, callback] () {
      rehaxUtils::Timer::stopTimer(timerRegistry[timerId]);
      callback();
    });
    timerRegistry[timerId] = timer;
    return timerId;
  }, this);

  auto clearTimeout = Converter<std::function<void(int)>>::toScript(ctx, [this] (int timerId) {
    rehaxUtils::Timer::stopTimer(timerRegistry[timerId]);
  }, this);

  auto setInterval = Converter<std::function<int(std::function<void(void)>, int)>>::toScript(ctx, [this] (std::function<void(void)> callback, int timeout) {
    auto timerId = nextTimerId++;
    rehaxUtils::Timer * timer = rehaxUtils::Timer::startInterval(timeout, [timerId, callback] () {
      callback();
    });

    timerRegistry[timerId] = timer;
    return timerId;
  }, this);

  auto clearInterval = Converter<std::function<void(int)>>::toScript(ctx, [this] (int timerId) {
    rehaxUtils::Timer::stopTimer(timerRegistry[timerId]);
  }, this);

  auto globalObject = runtime::GetGlobalObject(ctx);

  runtime::SetObjectProperty(ctx, globalObject, "setTimeout", setTimeout);
  runtime::SetObjectProperty(ctx, globalObject, "setInterval", setInterval);
  runtime::SetObjectProperty(ctx, globalObject, "clearTimeout", clearTimeout);
  runtime::SetObjectProperty(ctx, globalObject, "clearInterval", clearInterval);
}
