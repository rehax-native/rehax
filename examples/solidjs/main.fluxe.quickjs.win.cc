#include "../../runtimes/quickjs/runtime.h"
#include <fluxe/views/EngineUtility.h>
#include <iostream>
#include <filesystem>
#include <fstream>

using namespace rehax::ui::fluxe;

// #if _WIN32
// #include <windows.h>

// int WINAPI WinMain(HINSTANCE inst, HINSTANCE prev, LPSTR cmd, int show) {
// #else
int main() {
// #endif
  auto container = View::Create();
  auto view = static_cast<fluxe::View *>(container->getNativeView());

  auto vm = new rehax::quickjs::Runtime();
  vm->makeConsole();
  vm->bindRequire();
  vm->bindFs();
  vm->bindFetch();
  vm->bindTimer();
  vm->bindBuffer();
  vm->bindCrypto();
  vm->bindOS();
  vm->bindApp();
  vm->bindLocalStorage();
  vm->bindFluxeRehax();
  vm->setRootView(container);

  std::ifstream t("index.native.js");
  std::stringstream buffer;
  buffer << t.rdbuf();
  vm->evaluate(buffer.str());

  fluxe::EngineUtility::startWithView(view->getThisPointer());

  return 0;
}
