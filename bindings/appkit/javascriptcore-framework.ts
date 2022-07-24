import { SimpleClass, SimpleMethod } from "../types";

const MethodTemplate = (info: SimpleMethod) => {
  const nameParts = info.name.split(":");
  const zipped = [nameParts[0]];
  for (let i = 0; i < info.arguments.length; i++) {
    const arg = info.arguments[i];
    zipped.push(`:(${arg.origin.type?.qualType})${arg.name}`);
    if (nameParts[i + 1]) {
      zipped.push(" " + nameParts[i + 1]);
    }
  }

  return `${info.isStatic ? "+" : "-"}(${
    info.origin.returnType?.qualType
  })${zipped.join("")};`;
};

const HeaderExportTemplate = (info: SimpleClass) => `
@protocol Rehax${info.name}Exports <JSExport>;
${Object.values(info.methods).map(MethodTemplate).join("\n")}
@end

@interface Rehax${info.name} : ${info.name} <Rehax${info.name}Exports>
@end
`;

const SetupHeaderTemplate = (name: string) => `
void setup${name}Bindings(JSContext * context);
`;

const SetupSourceTemplate = (name: string, infos: SimpleClass[]) => `
#import "binding.h"

${infos
  .map((info) => `@implementation Rehax${info.name}\n@end\n`)
  .join("\n")}

void setup${name}Bindings(JSContext * context)
{
${infos
  .map((info) => `  context[@"${info.name}"] = [Rehax${info.name} class];`)
  .join("\n")}
}
`;

export function generateJavascriptCoreFrameworkBindings(
  frameworkName: string,
  infos: SimpleClass[]
) {
  let header = "";
  let impl = "";

  header += `#pragma once\n\n#import <${frameworkName}/${frameworkName}.h>\n#import <JavaScriptCore/JavaScriptCore.h>\n\n`;

  for (const info of infos) {
    header += HeaderExportTemplate(info);
  }
  header += SetupHeaderTemplate(frameworkName);

  impl += SetupSourceTemplate(frameworkName, infos);

  return {
    header,
    impl,
  };
}
