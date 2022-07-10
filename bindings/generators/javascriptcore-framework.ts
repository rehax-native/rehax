import { SimpleClass, SimpleMethod } from "../types";

const MethodTemplate = (info: SimpleMethod) => {

  const nameParts = info.name.split(':')
  const zipped = [nameParts[0]]
  for (let i = 0; i < info.arguments.length; i++) {
    const arg = info.arguments[i]
    zipped.push(`:(${arg.origin.type?.qualType})${arg.name}`)
    if (nameParts[i+1]) {
      zipped.push(' ' + nameParts[i+1])
    }
  }

  return `${info.isStatic ? "+" : "-"}(${info.origin.returnType?.qualType})${zipped.join('')};`;
}

const Template = (info: SimpleClass) => `
@protocol Rehax${info.name}Exports <JSExport>;
${Object.values(info.methods).map(MethodTemplate).join('\n')}
@end

@interface Rehax${info.name} : ${info.name} <Rehax${info.name}Exports>
@end

@implementation Rehax${info.name}
@end
`

export function generateJavascriptCoreFrameworkBindings(info: SimpleClass) {
  let objcSetup = "";

  objcSetup += Template(info);

  return objcSetup;
}
