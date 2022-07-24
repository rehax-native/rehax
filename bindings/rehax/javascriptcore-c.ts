import { SimpleClass, SimpleMethod } from "./types";

function capitalize(str: string) {
  return str.charAt(0).toUpperCase() + str.slice(1);
}

function uncapitalize(str: string) {
  return str.charAt(0).toLocaleLowerCase() + str.slice(1);
}

const namespace = 'rehax::ui::appkit::rawptr::';

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

// function makeInstanceMethodSetup(
//   frameworkName: string,
//   info: SimpleClass,
//   method: SimpleMethod
// ) {
//   const prettyName = jsFunctionName(method);
//   const functionName = makeInstanceMethodFunctionName(
//     frameworkName,
//     info,
//     method
//   );
//   const impl = `  {
//     JSStringRef methodName = JSStringCreateWithUTF8CString("${prettyName}");
//     JSObjectRef methodObject = JSObjectMakeFunctionWithCallback(context, methodName, &${functionName});
//     JSObjectSetProperty(context, instanceObject, methodName, methodObject, kJSPropertyAttributeReadOnly, NULL);
//   }`;
//   return impl;
// }

// function makeClassMethodSetup(
//   frameworkName: string,
//   info: SimpleClass,
//   method: SimpleMethod
// ) {
//   const prettyName = jsFunctionName(method);
//   const functionName = makeInstanceMethodFunctionName(
//     frameworkName,
//     info,
//     method
//   );
//   const impl = `  {
//     JSStringRef methodName = JSStringCreateWithUTF8CString("${prettyName}");
//     JSObjectRef methodObject = JSObjectMakeFunctionWithCallback(context, methodName, &${functionName});
//     JSObjectSetProperty(context, classObject, methodName, methodObject, kJSPropertyAttributeReadOnly, NULL);
//   }`;
//   return impl;
// }

// function makeMethodImplementation(
//   frameworkName: string,
//   info: SimpleClass,
//   method: SimpleMethod,
//   isInstance: boolean
// ): string {
//   const functionName = makeInstanceMethodFunctionName(
//     frameworkName,
//     info,
//     method
//   );
//   // const parts = method.origin.name
//   let argDefs: string[] = [];
//   let returnType = "  return JSValueMakeUndefined(ctx);";
//   let resultAssignment = "";
//   if (method.origin.type?.qualType?.startsWith("void (")) {
//   } else if (method.origin.type?.qualType?.startsWith("std::string (")) {
//     resultAssignment = "std::string result = ";
//     returnType = `  return StdStringToJSString(ctx, result);`;
//   } else if (
//     method.origin.type?.qualType?.startsWith(
//       "rehax::ui::appkit::impl::View::PtrType ("
//     )
//   ) {
//     resultAssignment = "auto result = ";
//     returnType = `  return rehaxMakeViewInstanceObject(ctx, result);`;
//   } else if (
//     method.origin.type?.qualType?.match(
//       /^typename Container::template Ptr<(.+)<Container>> \(/
//     )
//   ) {
//     const match = method.origin.type?.qualType?.match(
//       /^typename Container::template Ptr<(.+)<Container>> \(/
//     )?.[1];
//     resultAssignment = "auto result = ";
//     returnType = `  return rehaxMake${match}InstanceObject(ctx, result);`;
//   } else if (method.origin.type?.qualType?.startsWith("bool (")) {
//     resultAssignment = "bool result = ";
//     returnType = `  return BoolToJSBool(ctx, result);`;
//     //     resultAssignment = "id result = ";
//     //     returnType = `  return rehaxMake${frameworkName}${info.name}InstanceObject(ctx, result);`;
//     //   } else if (method.origin.returnType?.qualType === "NSView *") {
//     //     // This should check if the type exist by name
//     //     resultAssignment = "NSView * result = ";
//     //     returnType = `  return rehaxMakeAppKitNSViewInstanceObject(ctx, result);`;
//   } else {
//     console.log(method.origin.type);
//   }
//   let call = isInstance
//     ? `${resultAssignment}inst->${method.origin.name}(`
//     : `${resultAssignment}${info.name}::${method.origin.name}(`;

//   let argCount = 0;
//   for (let i = 0; i < (method.origin.inner?.length ?? 0); i++) {
//     const methodArg = method.origin.inner?.[i]!;
//     if (methodArg.kind === "ParmVarDecl") {
//       argCount++;
//     }
//   }
//   for (let i = 0; i < (method.origin.inner?.length ?? 0); i++) {
//     const methodArg = method.origin.inner?.[i]!;
//     //     call += part;
//     // if (i < method.arguments.length) {
//     if (methodArg.kind === "ParmVarDecl") {
//       if (methodArg.type?.desugaredQualType === "std::string") {
//         argDefs.push(
//           `  JSStringRef ${methodArg.name}JS = JSValueToStringCopy(ctx, arguments[${i}], NULL);`
//         );
//         argDefs.push(
//           `  std::string ${methodArg.name} = JSStringToStdString(ctx, ${methodArg.name}JS);`
//         );

//         //       } else if (method.arguments[i].origin.type?.desugaredQualType === "id") {
//         //         argDefs.push(
//         //           `  ${method.arguments[i].origin.type?.qualType} ${method.arguments[i].name} = (__bridge ${method.arguments[i].origin.type?.qualType}) JSObjectGetPrivate((JSObjectRef) arguments[${i}]);`
//         //         );

//         //       } else if (
//         //         method.arguments[i].origin.type?.desugaredQualType === "bool"
//         //       ) {
//         //         argDefs.push(
//         //           `  ${method.arguments[i].origin.type?.qualType} ${method.arguments[i].name} = JSValueToBoolean(ctx, arguments[${i}]);`
//         //         );

//         //       } else if (
//         //         method.arguments[i].origin.type?.desugaredQualType === "NSView *"
//         //       ) {
//         //         // This should check if the type exist by name
//         //         argDefs.push(
//         //           `  ${method.arguments[i].origin.type?.qualType} ${method.arguments[i].name} = (__bridge ${method.arguments[i].origin.type?.qualType}) JSObjectGetPrivate((JSObjectRef) arguments[${i}]);`
//         //         );
//       } else if (
//         methodArg.type?.qualType === "rehax::ui::appkit::impl::View::PtrType"
//       ) {
//         argDefs.push(
//           `  View::PtrType ${methodArg.name} = (View::PtrType) JSObjectGetPrivate((JSObjectRef) arguments[${i}]);`
//         );
//       } else if (methodArg.type?.qualType === "void *") {
//         argDefs.push(
//           `  void * ${methodArg.name} = (void *) JSObjectGetPrivate((JSObjectRef) arguments[${i}]);`
//         );
//       } else if (methodArg.type?.qualType === "float") {
//         argDefs.push(
//           `  float ${methodArg.name} = JSValueToNumber(ctx, arguments[${i}], NULL);`
//         );
//       } else if (methodArg.type?.qualType === "std::function<void ()>") {
//         argDefs.push(
//           `  JSObjectRef ${methodArg.name}Callback = (JSObjectRef) arguments[${i}];`,
//           `  std::function<void ()> ${methodArg.name} = [ctx, ${methodArg.name}Callback, thisObject] () { JSObjectCallAsFunction(ctx, ${methodArg.name}Callback, thisObject, 0, NULL, NULL); };`
//         );
//       } else {
//         console.log(functionName, methodArg.type);
//       }
//       call += `${methodArg.name}`;
//       if (i < argCount - 1) {
//         call += ", ";
//       }
//     }
//   }
//   call += ");";
//   const impl = `// ${
//     method.description
//   }\nJSValueRef ${functionName}(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception)\n{
// ${argDefs.join("\n")}
//   ${
//     isInstance
//       ? `${info.name} * inst = (${info.name} *) JSObjectGetPrivate(thisObject);`
//       : ""
//   }
//   ${call}
// ${returnType}
// }`;
//   return impl;
// }

export function generateJavascriptCoreCBindings(
  frameworkName: string,
  infos: Record<string, SimpleClass>
) {
  let header = `#pragma once\n\n#include <JavaScriptCore/JavaScriptCore.h>\n#include "native-abstraction/rehax.h"\n\nvoid setup${frameworkName}Bindings(JSGlobalContextRef context);\n`;
  const implParts: string[] = [];

  implParts.push(`using namespace rehax::ui::appkit::rawptr;`);

  //   implParts.push(`
  // JSValueRef BoolToJSBool(JSContextRef ctx, bool value) {
  //   return value ? JSValueMakeBoolean(ctx, true) : JSValueMakeBoolean(ctx, false);
  // }`);
    implParts.push(`
  JSValueRef StdStringToJSString(JSContextRef ctx, std::string str) {
    return JSValueMakeString(ctx, JSStringCreateWithUTF8CString(str.c_str()));
  }`);
    implParts.push(`
  std::string JSStringToStdString(JSContextRef ctx, JSStringRef str) {
    size_t maxBufferSize = JSStringGetMaximumUTF8CStringSize(str);
    char* utf8Buffer = new char[maxBufferSize];
    size_t bytesWritten = JSStringGetUTF8CString(str, utf8Buffer, maxBufferSize);
    utf8Buffer[bytesWritten] = '\\0';
    std::string ret = std::string(utf8Buffer);
    delete [] utf8Buffer;
    return ret;
  }`);

//   implParts.push(`
// // We need to assign a class to our objects, otherwise we can't store private data
// JSClassRef rehaxGetObjectClass(JSContextRef ctx) {
//   // This creates one class for all contexts. We probably want one per context.
//   static JSClassRef classRef = NULL;
//   if (classRef == NULL) {
//     static JSClassDefinition classDef = kJSClassDefinitionEmpty;
//     classDef.version = 1;
//     classRef = JSClassCreate(&classDef);
//   }
//   return classRef;
// }`);

  const classSetupCalls: string[] = [];

  for (const info of Object.values(infos)) {
    const classSetups: string[] = [
      `JSObjectRef rehaxMake${info.name}ClassObject(JSContextRef context, JSObjectRef module)\n{\n  JSObjectRef classObject = JSObjectMake(context, NULL, NULL);`,
    ];
    const instanceSetups: string[] = [
      `JSValueRef rehaxMake${info.name}InstanceObject(JSContextRef context, ${info.name} * inst)\n{\n  JSObjectRef instanceObject = JSObjectMake(context, rehaxGetObjectClass(context), (void *) inst);`,
    ];

    header += `JSObjectRef rehaxMake${info.name}ClassObject(JSContextRef context, JSObjectRef module);\n`;
    header += `JSValueRef rehaxMake${info.name}InstanceObject(JSContextRef context, ${namespace}${info.name} * inst);\n`;

    //     const blacklistedMethodNames = [
    //       "dealloc",
    //       "finalize",
    //       "allowsWeakReference",
    //       "retainWeakReference",
    //     ];

    // first pass, we only compiled instance methods
    for (const id of Object.keys(info.methods)) {
      const method = info.methods[id];
      //       // if (info.name === 'NSView') {
      //       //   if (method.name.includes('setFrame')) {
      //       //     console.log(method.arguments[0])
      //       //   }
      //       // }
      //       if (blacklistedMethodNames.includes(method.name)) {
      //         continue;
      //       }
      if (info.methods[id].isStatic) {
        continue;
      }
      //       // const compileInstanceMethod(info, method);
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
      if (!info.methods[id].isStatic) {
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
      `  rehaxMake${info.name}ClassObject(context, module);`
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
