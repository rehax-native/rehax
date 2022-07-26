#include "runtime.h"

using namespace rehax::quickjs;

Runtime::Runtime() {
  runtime = JS_NewRuntime();
  context = JS_NewContext(runtime);
  
  Bindings::setContext(context, runtime);
}

void Runtime::makeConsole() {
  auto globalContext = JS_GetGlobalObject(context);
  auto console = JS_NewObject(context);
  JS_SetPropertyStr(context, globalContext, "console", console);

  {
    auto call = [] (JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic, JSValue* func_data) {
      auto message = JS_ToCString(ctx, argv[0]);
      std::cout << message << std::endl;
      return JS_UNDEFINED;
    };

    auto functionObject = JS_NewCFunctionData(context, call, 0, 0, 0, {});
    JS_SetPropertyStr(context, console, "log", functionObject);
  }
  {
    auto call = [] (JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic, JSValue* func_data) {
      auto message = JS_ToCString(ctx, argv[0]);
      std::cerr << message << std::endl;
      return JS_UNDEFINED;
    };

    auto functionObject = JS_NewCFunctionData(context, call, 0, 0, 0, {});
    JS_SetPropertyStr(context, console, "error", functionObject);
  }
}

void Runtime::evaluate(std::string script) {
  auto value = JS_Eval(context, script.c_str(), script.size(), "<unknown>", JS_EVAL_TYPE_GLOBAL);
  if (JS_IsException(value)) {
    std::cerr << "QuickJs Exception: ";
    auto exc = JS_GetException(context);
    if (JS_IsObject(exc)) {
      auto excMessage = JS_GetPropertyStr(context, exc, "message");
      if (JS_IsString(excMessage)) {
        std::cerr << JS_ToCString(context, excMessage);
      } else {
        std::cerr << "Unknown error";
      }
      auto stack = JS_GetPropertyStr(context, exc, "stack");
      if (JS_IsArray(context, stack)) {
        auto length = JS_GetPropertyStr(context, stack, "length");
        int l;
        JS_ToInt32(context, & l, length);
        std::cerr << "Stack: " << l;
      } else if (JS_IsString(stack)) {
        std::cerr << JS_ToCString(context, stack);
      }
    } else if (JS_IsString(exc)) {
      std::cerr << JS_ToCString(context, exc);
    } else {
      std::cerr << "Unknown exception";
    }
    std::cerr << std::endl;
  }
}

#ifdef REHAX_WITH_FLUXE
void Runtime::setRootView(rehaxUtils::ObjectPointer<rehax::ui::fluxe::impl::View<rehax::ui::RefCountedPointer>> view) {
  auto rootView = cppToJs(view.get());
  auto globalContext = JS_GetGlobalObject(context);
  JS_SetPropertyStr(context, globalContext, "rootView", rootView);
}
#endif

#ifdef REHAX_WITH_APPKIT
void Runtime::setRootView(rehaxUtils::ObjectPointer<rehax::ui::appkit::impl::View<rehax::ui::RefCountedPointer>> view) {
  auto rootView = cppToJs(view.get());
  auto globalContext = JS_GetGlobalObject(context);
  JS_SetPropertyStr(context, globalContext, "rootView", rootView);
}
#endif
