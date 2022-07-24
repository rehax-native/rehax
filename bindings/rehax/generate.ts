import path from "path";
import fs from "fs/promises";
import {
  Framework,
  OriginalNamespaceKind,
  FrameworkInner,
  CunningInner,
  FluffyInner,
  HilariousInner,
  IndigoInner,
  PurpleInner,
  StickyInner,
  TentacledInner,
} from "../generated/rehax/extracted";
import { SimpleClass, SimpleMethodArgument } from "./types";
import { generateJavascriptCoreCBindings } from "./javascriptcore-c";
import { inputs } from "./common";

const frameworkName = "Rehax";

const bindingHeaderFile = path.join(
  __dirname,
  "..",
  "generated",
  frameworkName,
  "binding.h"
);
const bindingImplFile = path.join(
  __dirname,
  "..",
  "generated",
  frameworkName,
  "binding.cpp"
);

async function simplifyInfo(): Promise<Record<string, SimpleClass>> {
  const classDeclarations: Record<string, SimpleClass> = {};
  const classNamesToExport = inputs.map((input) => input.name);

  for (const input of inputs) {
    const data = JSON.parse(
      await fs.readFile(input.destinationPath, "utf-8")
    ) as Framework;

    function traverse(
      inner:
        | FrameworkInner
        | PurpleInner
        | FluffyInner
        | TentacledInner
        | StickyInner
        | IndigoInner
        | HilariousInner
        | CunningInner,
      namespace: string[]
    ) {
      let thisNamespace: string[] = [...namespace]
      if (inner.kind === OriginalNamespaceKind.NamespaceDecl && inner.name) {
        thisNamespace = [...namespace, inner.name];
      }
      if (
        inner.kind === OriginalNamespaceKind.CXXRecordDecl &&
        inner.tagUsed === "class" &&
        inner.name &&
        classNamesToExport.includes(inner.name)
      ) {
        if (!classDeclarations[inner.name]) {
          classDeclarations[inner.name] = {
            name: inner.name,
            origin: inner,
            // superClass: 'super' in inner && inner.super?.name,
            namespace: thisNamespace.join('::'),
            methods: {},
          };
        }

        const classDeclaration = classDeclarations[inner.name];
        // No previous decl means first time it is defined
        if (!inner.previousDecl) {
          classDeclaration.origin = inner;
          classDeclaration.namespace = thisNamespace.join('::')
        }
        inner.inner?.forEach((classInner) => {
          if (classInner.kind === "CXXMethodDecl" && classInner.name) {
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
              isStatic: classInner.storageClass === "static",
            };
          }
        });
      }

      if ("inner" in inner) {
        inner.inner?.map((inner) => traverse(inner, thisNamespace));
      }
    }

    data.inner.forEach((inner) => traverse(inner, []));

    //   function addSuperClassDefinitions(
    //     classDef: SimpleClass,
    //     superClassName: string | undefined
    //   ) {
    //     const superClass = superClassName
    //       ? classDeclarations[superClassName]
    //       : undefined;
    //     if (superClass) {
    //       for (const name of Object.keys(superClass.methods)) {
    //         classDef.methods[name] = superClass.methods[name];
    //       }
    //       addSuperClassDefinitions(classDef, superClass.superClass);
    //     }
    //   }

    //   // hydrate with super class methods
    //   for (const name of Object.keys(classDeclarations)) {
    //     addSuperClassDefinitions(
    //       classDeclarations[name],
    //       classDeclarations[name].superClass
    //     );
    //   }
  }

  const exportedDeclarations: Record<string, SimpleClass> = {};
  for (const id of Object.keys(classDeclarations)) {
    const classDef = classDeclarations[id];
    // const isDefinedInThisFramework =
    //   classDef.origin.loc.includedFrom?.file.includes(
    //     `${frameworkName}.framework`
    //   );
    // if (!isDefinedInThisFramework) {
    //   continue;
    // }
    // // if (blacklistedClasses.includes(name)) {
    // //   continue;
    // // }
    // if (!classNamesToExport.includes(classDef.name)) {
    //   continue;
    // }
    exportedDeclarations[classDef.name] = classDef;
  }

  return exportedDeclarations;
}

async function run() {
  const simple = await simplifyInfo();

  const output = generateJavascriptCoreCBindings(frameworkName, simple);
  await fs.writeFile(bindingHeaderFile, output.header, "utf-8");
  await fs.writeFile(bindingImplFile, output.impl, "utf-8");
}

run();
