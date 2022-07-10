import path from "path";
import fs from "fs/promises";
import { Framework } from "./generated/AppKit.framework/extracted";
import { SimpleClass, SimpleMethodArgument } from "./types";
import { generateDuktapeFrameworkBindings } from "./generators/duktape-framework";
import { generateJavascriptCoreFrameworkBindings } from "./generators/javascriptcore-framework";

const frameworkName = "AppKit";
const infoLocation = path.join(
  __dirname,
  "generated",
  `${frameworkName}.framework`,
  "extracted.json"
);

const bindingFile = path.join(
  __dirname,
  "generated",
  frameworkName + ".framework",
  "binding.h"
);

function simplifyInfo(data: Framework): Record<string, SimpleClass> {
  const classDeclarations: Record<string, SimpleClass> = {};

  data.inner.forEach((inner) => {
    if (inner.kind === "ObjCInterfaceDecl" && inner.name) {
      inner.name;

      if (!classDeclarations[inner.name]) {
        classDeclarations[inner.name] = {
          name: inner.name,
          methods: {},
        };
      }

      const classDeclaration = classDeclarations[inner.name];

      inner.inner?.forEach((classInner) => {
        // if (
        //   classDeclaration.name === "NSDate" &&
        //   classInner.name === "timeIntervalSinceReferenceDate"
        // ) {
        //   console.log(classInner);
        // }

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

  return classDeclarations;
}

async function run() {
  const data = JSON.parse(
    await fs.readFile(infoLocation, "utf-8")
  ) as Framework;
  const simple = simplifyInfo(data);

  try {
    await fs.unlink(bindingFile);
  } catch {
  }
  await fs.appendFile(bindingFile, `#import <${frameworkName}/${frameworkName}.h>\n#import <JavaScriptCore/JavaScriptCore.h>`, "utf-8");
  for (const info of Object.values(simple)) {
    const output = generateJavascriptCoreFrameworkBindings(info);
    await fs.appendFile(bindingFile, output, "utf-8");
    // const output = generateDuktapeFrameworkBindings(info);
  }
}

run();
