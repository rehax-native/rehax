import path from "path";
import fs from "fs/promises";
import { Framework } from "./generated/AppKit.framework/extracted";
import { SimpleClass, SimpleMethodArgument } from "./types";
import { generateDuktapeFrameworkBindings } from "./generators/duktape-framework";
// import { generateJavascriptCoreFrameworkBindings } from "./generators/javascriptcore-framework";
import { generateJavascriptCoreCBindings } from "./generators/javascriptcore-c";

const frameworkName = "AppKit";
const infoLocation = path.join(
  __dirname,
  "generated",
  `${frameworkName}.framework`,
  "extracted.json"
);

const bindingHeaderFile = path.join(
  __dirname,
  "generated",
  frameworkName + ".framework",
  "binding.h"
);
const bindingImplFile = path.join(
  __dirname,
  "generated",
  frameworkName + ".framework",
  "binding.mm"
);

// // These classes are handled by the javascriptcore framework
// // Subclassing these classes results in an error
// const blacklistedClasses = [
//   "NSDate",
//   "NSDictionary",
//   "NSArray",
//   "NSString",
//   "NSNumber",
// ];

const classNamesToExport = [
  "NSView",
  "NSButton",
  "NSTextField",
];

function simplifyInfo(data: Framework): Record<string, SimpleClass> {
  const classDeclarations: Record<string, SimpleClass> = {};

  data.inner.forEach((inner) => {
    if (inner.kind === "ObjCInterfaceDecl" && inner.name) {
      if (!classDeclarations[inner.name]) {
        classDeclarations[inner.name] = {
          name: inner.name,
          origin: inner,
          superClass: inner.super?.name,
          methods: {},
        };
      }

      const classDeclaration = classDeclarations[inner.name];

      // No previous decl means first time it is defined
      if (!inner.previousDecl) {
        classDeclaration.origin = inner;
      }

      inner.inner?.forEach((classInner) => {
        if (classInner.kind === "ObjCMethodDecl" && classInner.name) {
          const args: SimpleMethodArgument[] = [];
          classInner.inner?.forEach((methodInner) => {
            if (methodInner.kind === "ParmVarDecl" && methodInner.name) {
              args.push({
                name: methodInner.name,
                origin: methodInner,
              });
            }
          });

          classDeclaration.methods[classInner.name] = {
            origin: classInner,
            description: classInner.mangledName,
            name: classInner.name,
            arguments: args,
            isStatic: !classInner.instance,
          };
        }
      });
    }
  });

  function addSuperClassDefinitions(
    classDef: SimpleClass,
    superClassName: string | undefined
  ) {
    const superClass = superClassName
      ? classDeclarations[superClassName]
      : undefined;
    if (superClass) {
      for (const name of Object.keys(superClass.methods)) {
        classDef.methods[name] = superClass.methods[name];
      }
      addSuperClassDefinitions(classDef, superClass.superClass);
    }
  }

  // hydrate with super class methods
  for (const name of Object.keys(classDeclarations)) {
    addSuperClassDefinitions(
      classDeclarations[name],
      classDeclarations[name].superClass
    );
  }

  const exportedDeclarations: Record<string, SimpleClass> = {};
  for (const id of Object.keys(classDeclarations)) {
    const classDef = classDeclarations[id];
    const isDefinedInThisFramework =
      classDef.origin.loc.includedFrom?.file.includes(
        `${frameworkName}.framework`
      );
    if (!isDefinedInThisFramework) {
      continue;
    }

    // if (blacklistedClasses.includes(name)) {
    //   continue;
    // }
    if (!classNamesToExport.includes(classDef.name)) {
      continue;
    }

    exportedDeclarations[classDef.name] = classDef;
  }

  return exportedDeclarations;
}

async function run() {
  const data = JSON.parse(
    await fs.readFile(infoLocation, "utf-8")
  ) as Framework;
  const simple = simplifyInfo(data);

  const output = generateJavascriptCoreCBindings(frameworkName, simple);
  await fs.writeFile(bindingHeaderFile, output.header, "utf-8");
  await fs.writeFile(bindingImplFile, output.impl, "utf-8");
}

run();
