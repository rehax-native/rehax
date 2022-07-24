import { SimpleClass, SimpleMethod } from "../types";

function capitalize(str: string) {
  return str.charAt(0).toUpperCase() + str.slice(1);
}

function uncapitalize(str: string) {
  return str.charAt(0).toLocaleLowerCase() + str.slice(1);
}

function canCompileMethod(method: SimpleMethod) {
  let knowsAllArguments = true;
  for (const arg of method.arguments) {
    if (arg.origin.type?.desugaredQualType === "NSString *") {
    } else if (arg.origin.type?.desugaredQualType === "id") {
    } else if (arg.origin.type?.desugaredQualType === "bool") {
    } else if (arg.origin.type?.desugaredQualType === "NSView *") {
    } else if (arg.origin.type?.qualType === "NSRect") {
    } else if (arg.origin.kind === "AvailabilityAttr") {
    } else {
      knowsAllArguments = false;
    }
  }

  if (!knowsAllArguments) {
    return false;
  }

  if (
    method.origin.returnType?.qualType === "NSString *" ||
    method.origin.returnType?.qualType === "void" ||
    method.origin.returnType?.desugaredQualType === "bool" ||
    method.origin.returnType?.desugaredQualType === "NSView *" ||
    method.origin.returnType?.qualType=== "NSRect"
  ) {
    return true;
  }

  if (method.isStatic && method.origin.returnType?.desugaredQualType === "id") {
    return true;
  }
  return false;
}

function jsFunctionName(method: SimpleMethod) {
  return uncapitalize(method.name.split(":").map(capitalize).join(""));
}

function makeInstanceMethodFunctionName(
  frameworkName: string,
  info: SimpleClass,
  method: SimpleMethod
) {
  const prettyName = jsFunctionName(method);
  const functionName = `rehax${frameworkName}${info.name}${capitalize(
    prettyName
  )}FunctionCallback`;
  return functionName;
}

function makeInstanceMethodSetup(
  frameworkName: string,
  info: SimpleClass,
  method: SimpleMethod
) {
  const prettyName = jsFunctionName(method);
  const functionName = makeInstanceMethodFunctionName(
    frameworkName,
    info,
    method
  );
  const impl = `  {
    JSStringRef methodName = JSStringCreateWithUTF8CString("${prettyName}");
    JSObjectRef methodObject = JSObjectMakeFunctionWithCallback(context, methodName, &${functionName});
    JSObjectSetProperty(context, instanceObject, methodName, methodObject, kJSPropertyAttributeReadOnly, NULL);
  }`;
  return impl;
}

function makeClassMethodSetup(
  frameworkName: string,
  info: SimpleClass,
  method: SimpleMethod
) {
  const prettyName = jsFunctionName(method);
  const functionName = makeInstanceMethodFunctionName(
    frameworkName,
    info,
    method
  );
  const impl = `  {
    JSStringRef methodName = JSStringCreateWithUTF8CString("${prettyName}");
    JSObjectRef methodObject = JSObjectMakeFunctionWithCallback(context, methodName, &${functionName});
    JSObjectSetProperty(context, classObject, methodName, methodObject, kJSPropertyAttributeReadOnly, NULL);
  }`;
  return impl;
}

function makeMethodImplementation(
  frameworkName: string,
  info: SimpleClass,
  method: SimpleMethod,
  isInstance: boolean
) {
  const functionName = makeInstanceMethodFunctionName(
    frameworkName,
    info,
    method
  );
  const parts = method.origin.name?.split(":") ?? [];
  let argDefs = [];
  let returnType = "  return JSValueMakeUndefined(ctx);";
  let resultAssignment = "";
  if (method.origin.returnType?.desugaredQualType === "id") {
    resultAssignment = "id result = ";
    returnType = `  return rehaxMake${frameworkName}${info.name}InstanceObject(ctx, result);`;
  } else if (method.origin.returnType?.desugaredQualType === "bool") {
    resultAssignment = "bool result = ";
    returnType = `  return BoolToJSBool(ctx, result);`;
  } else if (method.origin.returnType?.qualType === "NSString *") {
    resultAssignment = "NSString * result = ";
    returnType = `  return NSStringToJSString(ctx, result);`;
  } else if (method.origin.returnType?.qualType === "NSView *") {
    // This should check if the type exist by name
    resultAssignment = "NSView * result = ";
    returnType = `  return rehaxMakeAppKitNSViewInstanceObject(ctx, result);`;
  }
  let call = isInstance
    ? `${resultAssignment}[inst `
    : `${resultAssignment}[${info.name} `;
  for (let i = 0; i < parts.length; i++) {
    const part = parts[i];
    call += part;
    if (i < method.arguments.length) {
      if (method.arguments[i].origin.type?.desugaredQualType === "NSString *") {
        argDefs.push(
          `  JSStringRef ${method.arguments[i].name}JS = JSValueToStringCopy(ctx, arguments[${i}], NULL);`
        );
        argDefs.push(
          `  NSString * ${method.arguments[i].name} = JSStringToNSString(ctx, ${method.arguments[i].name}JS);`
        );

      } else if (method.arguments[i].origin.type?.desugaredQualType === "id") {
        argDefs.push(
          `  ${method.arguments[i].origin.type?.qualType} ${method.arguments[i].name} = (__bridge ${method.arguments[i].origin.type?.qualType}) JSObjectGetPrivate((JSObjectRef) arguments[${i}]);`
        );

      } else if (
        method.arguments[i].origin.type?.desugaredQualType === "bool"
      ) {
        argDefs.push(
          `  ${method.arguments[i].origin.type?.qualType} ${method.arguments[i].name} = JSValueToBoolean(ctx, arguments[${i}]);`
        );

      } else if (
        method.arguments[i].origin.type?.desugaredQualType === "NSView *"
      ) {
        // This should check if the type exist by name
        argDefs.push(
          `  ${method.arguments[i].origin.type?.qualType} ${method.arguments[i].name} = (__bridge ${method.arguments[i].origin.type?.qualType}) JSObjectGetPrivate((JSObjectRef) arguments[${i}]);`
        );
      } else if (
        method.arguments[i].origin.type?.qualType === "NSRect"
      ) {
        argDefs.push(
          `  JSObjectRef ${method.arguments[i].name}JS = (JSObjectRef) arguments[${i}];`,
          `  JSObjectRef ${method.arguments[i].name}JSOrigin = (JSObjectRef) JSObjectGetProperty(ctx, ${method.arguments[i].name}JS, JSStringCreateWithUTF8CString("origin"), NULL);`,
          `  JSObjectRef ${method.arguments[i].name}JSSize = (JSObjectRef) JSObjectGetProperty(ctx, ${method.arguments[i].name}JS, JSStringCreateWithUTF8CString("size"), NULL);`,
          `  ${method.arguments[i].origin.type?.qualType} ${method.arguments[i].name} = NSMakeRect(`,
          `    JSValueToNumber(ctx, JSObjectGetProperty(ctx, ${method.arguments[i].name}JSOrigin, JSStringCreateWithUTF8CString("x"), NULL), NULL),`,
          `    JSValueToNumber(ctx, JSObjectGetProperty(ctx, ${method.arguments[i].name}JSOrigin, JSStringCreateWithUTF8CString("y"), NULL), NULL),`,
          `    JSValueToNumber(ctx, JSObjectGetProperty(ctx, ${method.arguments[i].name}JSSize, JSStringCreateWithUTF8CString("width"), NULL), NULL),`,
          `    JSValueToNumber(ctx, JSObjectGetProperty(ctx, ${method.arguments[i].name}JSSize, JSStringCreateWithUTF8CString("height"), NULL), NULL)`,
          `  );`,
        );

      } else {
        console.log(method.arguments[i].origin.type);
      }
      call += `:${method.arguments[i].name} `;
    }
  }
  call += "];";
  const impl = `// ${
    method.description
  }\nJSValueRef ${functionName}(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception)\n{
${argDefs.join("\n")}
  ${
    isInstance
      ? `${info.name} * inst = (__bridge ${info.name} *) JSObjectGetPrivate(thisObject);`
      : ""
  }
  ${call}
${returnType}
}`;
  return impl;
}

export function generateJavascriptCoreCBindings(
  frameworkName: string,
  infos: Record<string, SimpleClass>
) {
  // we filter out everything with unknown types
  // unknown types are everything that we don't know how to convert to/from js

  let header = `#pragma once\n\n#include <${frameworkName}/${frameworkName}.h>\n#include <JavaScriptCore/JavaScriptCore.h>\n\nvoid setup${frameworkName}Bindings(JSGlobalContextRef context);\n`;
  const implParts: string[] = [];

  implParts.push(`
JSValueRef BoolToJSBool(JSContextRef ctx, bool value) {
  return value ? JSValueMakeBoolean(ctx, true) : JSValueMakeBoolean(ctx, false);
}`);
  implParts.push(`
JSValueRef NSStringToJSString(JSContextRef ctx, NSString * str) {
  return JSValueMakeString(ctx, JSStringCreateWithUTF8CString([str UTF8String]));
}`);
  implParts.push(`
NSString * JSStringToNSString(JSContextRef ctx, JSStringRef str) {
  size_t maxBufferSize = JSStringGetMaximumUTF8CStringSize(str);
  char* utf8Buffer = new char[maxBufferSize];
  size_t bytesWritten = JSStringGetUTF8CString(str, utf8Buffer, maxBufferSize);
  utf8Buffer[bytesWritten] = '\\0';
  NSString * ret = [NSString stringWithUTF8String:utf8Buffer];
  delete [] utf8Buffer;
  
  return ret;
}`);
  implParts.push(`
// We need to assign a class to our objects, otherwise we can't store private data
JSClassRef rehaxGetObjectClass(JSContextRef ctx) {

  // This creates one class for all contexts. We probably want one per context.
  static JSClassRef classRef = NULL;
  if (classRef == NULL) {
    static JSClassDefinition classDef = kJSClassDefinitionEmpty;
    classDef.version = 1;
    classRef = JSClassCreate(&classDef);
  }
  return classRef;
}`);
  const classSetupCalls: string[] = [];

  for (const info of Object.values(infos)) {
    const classSetups: string[] = [
      `JSObjectRef rehaxMake${frameworkName}${info.name}ClassObject(JSContextRef context, JSObjectRef module)\n{\n  JSObjectRef classObject = JSObjectMake(context, NULL, NULL);`,
    ];
    const instanceSetups: string[] = [
      `JSValueRef rehaxMake${frameworkName}${info.name}InstanceObject(JSContextRef context, ${info.name} * inst)\n{\n  JSObjectRef instanceObject = JSObjectMake(context, rehaxGetObjectClass(context), (void *) CFBridgingRetain(inst) /*(__bridge void *) inst*/);`,
    ];

    header += `JSObjectRef rehaxMake${frameworkName}${info.name}ClassObject(JSContextRef context, JSObjectRef module);\n`;
    header += `JSValueRef rehaxMake${frameworkName}${info.name}InstanceObject(JSContextRef context, ${info.name} * inst);\n`;

    const blacklistedMethodNames = [
      "dealloc",
      "finalize",
      "allowsWeakReference",
      "retainWeakReference",
    ];

    // first pass, we only compiled instance methods
    for (const id of Object.keys(info.methods)) {
      const method = info.methods[id];
      // if (info.name === 'NSView') {
      //   if (method.name.includes('setFrame')) {
      //     console.log(method.arguments[0])
      //   }
      // }
      if (blacklistedMethodNames.includes(method.name)) {
        continue;
      }
      if (info.methods[id].isStatic || !canCompileMethod(method)) {
        continue;
      }
      // const compileInstanceMethod(info, method);
      const instanceMethodSetup = makeInstanceMethodSetup(
        frameworkName,
        info,
        method
      );
      instanceSetups.push(instanceMethodSetup);
      const methodImplementation = makeMethodImplementation(
        frameworkName,
        info,
        method,
        true
      );
      implParts.push(methodImplementation);
    }

    // second pass, we only compiled class methods
    for (const id of Object.keys(info.methods)) {
      const method = info.methods[id];
      if (!info.methods[id].isStatic || !canCompileMethod(method)) {
        continue;
      }

      const methodImplementation = makeMethodImplementation(
        frameworkName,
        info,
        method,
        false
      );
      implParts.push(methodImplementation);

      const classMethodSetup = makeClassMethodSetup(
        frameworkName,
        info,
        method
      );

      classSetups.push(classMethodSetup);
    }

    classSetups.push(
      `  JSStringRef className = JSStringCreateWithUTF8CString("${info.name}");\n  JSObjectSetProperty(context, module, className, classObject, kJSPropertyAttributeReadOnly, nullptr);\n`
    );
    classSetups.push(`  return classObject;\n}`);
    instanceSetups.push("  return instanceObject;\n}");

    classSetupCalls.push(
      `  rehaxMake${frameworkName}${info.name}ClassObject(context, module);`
    );
    implParts.push(classSetups.join("\n"));
    implParts.push(instanceSetups.join("\n"));
  }

  implParts.push(
    `void setup${frameworkName}Bindings(JSGlobalContextRef context)\n{`
  );
  implParts.push(
    `  JSObjectRef globalObject = JSContextGetGlobalObject(context);\n  JSStringRef frameworkName = JSStringCreateWithUTF8CString("${frameworkName}");\n  JSObjectRef module = JSObjectMake(context, NULL, NULL);  JSObjectSetProperty(context, globalObject, frameworkName, module, kJSPropertyAttributeReadOnly, nullptr);\n`
  );
  implParts.push(classSetupCalls.join("\n"));
  implParts.push(`}\n`);

  const impl = `#include "binding.h"\n\n` + implParts.join("\n\n");

  return {
    header,
    impl,
  };
}
