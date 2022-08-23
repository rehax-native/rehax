#include "../../runtimes/jsc/runtime.h"
#include <fluxe/views/EngineUtility.h>
#include <iostream>

using namespace rehax::ui::fluxe;

#if _WIN32
#include <windows.h>

int WINAPI WinMain(HINSTANCE inst, HINSTANCE prev, LPSTR cmd, int show) {
#else
int main() {
#endif
  auto container = View::Create();
  auto view = static_cast<fluxe::View *>(container->getNativeView());

  auto vm = new rehax::jsc::Runtime();
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

  NSString * resourcePath = [[NSBundle mainBundle] resourcePath];
  NSString * scriptPath = [NSString pathWithComponents:@[resourcePath, @"index.native.js"]];
  NSString * script = [NSString stringWithContentsOfFile:scriptPath encoding:NSUTF8StringEncoding error:NULL];
  vm->evaluate([script UTF8String]);

  fluxe::EngineUtility::startWithView(view->getThisPointer());

  return 0;
}
