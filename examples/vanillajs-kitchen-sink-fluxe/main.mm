#include "../../runtimes/jsc.h"
#include "../../../fluxe/fluxe/views/EngineUtility.h"
#include <iostream>

using namespace rehax::ui::fluxe::rawptr;

#if _WIN32
#include <windows.h>

int WINAPI WinMain(HINSTANCE inst, HINSTANCE prev, LPSTR cmd, int show) {
#else
int main() {
#endif
  auto container = View::Create();
  auto view = static_cast<fluxe::View *>(container->getNativeView());

  rehax::jsc::JscVm vm;
  vm.bindFluxeToJsc();
  vm.setRootView(container);

  vm.evaluate("var btn = new Button(); btn.setTitle('Henlo'); rootView.addView(btn);");
  fluxe::EngineUtility::startWithView(view->getThisPointer());

  return 0;
}
