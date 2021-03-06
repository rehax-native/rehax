#include "../../runtimes/quickjs/runtime.h"
#include "../../../fluxe/fluxe/views/EngineUtility.h"
#include <iostream>
#include "../../native-abstraction/ui/fluxe/components/view/View.cc"
#include <AppKit/AppKit.h>

using namespace rehax::ui::fluxe::rawptr;

#if _WIN32
#include <windows.h>

int WINAPI WinMain(HINSTANCE inst, HINSTANCE prev, LPSTR cmd, int show) {
#else
int main() {
#endif
  auto container = rehax::ui::fluxe::impl::View<rehax::ui::RefCountedPointer>::Create();
  auto view = static_cast<fluxe::View *>(container->getNativeView());

  auto vm = new rehax::quickjs::Runtime();
  vm->makeConsole();
  vm->bindFluxeToQuickJs();
  vm->setRootView(container);

  NSString * resourcePath = [[NSBundle mainBundle] resourcePath];
  NSString * scriptPath = [NSString pathWithComponents:@[resourcePath, @"index.native.js"]];
  NSString * script = [NSString stringWithContentsOfFile:scriptPath encoding:NSUTF8StringEncoding error:NULL];
  vm->evaluate([script UTF8String]);

  fluxe::EngineUtility::startWithView(view->getThisPointer());

  return 0;
}
