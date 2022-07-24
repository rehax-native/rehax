#include <winrt/Windows.UI.Xaml.h>

using namespace winrt::Windows::UI::Xaml;

struct NativeViewWrapper {
	UIElement element;
};

__declspec(dllexport) void setRootElement(UIElement rootElement);
__declspec(dllexport) UIElement getRootElement();
