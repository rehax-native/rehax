#include "runtime.h"
#include <quickjs-src/quickjs-libc.h>

using namespace rehax::quickjs;


Runtime::Runtime() {
  runtime = JS_NewRuntime();
  context = JS_NewContext(runtime);

  JS_SetMaxStackSize(runtime, 10 * 1024 * 1024);
  JS_SetHostPromiseRejectionTracker(runtime, js_std_promise_rejection_tracker, NULL);

  Bindings::setContext(context, runtime);
}

Runtime::~Runtime() {
  JS_FreeContext(context);
  JS_FreeRuntime(runtime);
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
  auto value = JS_Eval(context, script.c_str(), script.size(), "<unknown>", JS_EVAL_TYPE_MODULE);
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
void Runtime::setRootView(rehaxUtils::ObjectPointer<rehax::ui::fluxe::View> view) {
  auto rootView = cppToJs(view);
  auto globalObject = JS_GetGlobalObject(context);

  JSValue rehax;
  if (!JS_HasProperty(context, globalObject, JS_NewAtom(context, "rehax"))) {
    rehax = JS_NewObject(context);
    JS_SetPropertyStr(context, globalObject, "rehax", rehax);
  } else {
      rehax = JS_GetPropertyStr(context, globalObject, "rehax");
  }
  JS_SetPropertyStr(context, rehax, "rootView", rootView);
}
#endif

#ifdef REHAX_WITH_APPKIT
void Runtime::setRootView(rehaxUtils::ObjectPointer<rehax::ui::appkit::View> view) {
  auto rootView = cppToJs(view);
  auto globalObject = JS_GetGlobalObject(context);
  JSValue rehax;
  if (!JS_HasProperty(context, globalObject, JS_NewAtom(context, "rehax"))) {
    rehax = JS_NewObject(context);
    JS_SetPropertyStr(context, globalObject, "rehax", rehax);
  } else {
    rehax = JS_GetPropertyStr(context, globalObject, "rehax");
  }
  JS_SetPropertyStr(context, rehax, "rootView", rootView);
}
#endif
