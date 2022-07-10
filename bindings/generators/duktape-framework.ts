import { SimpleClass } from "../types";

export function generateDuktapeFrameworkBindings(info: SimpleClass) {
  // duk_push_c_function(ctx, native_print, DUK_VARARGS);
  // duk_put_global_string(ctx, "print");

  let vmSetup = ''
  let jsSetup = ''

  for (const method of Object.values(info.methods)) {
    vmSetup += `duk_push_c_function(ctx, rhx_${info.name}_${method.name}, ${method.arguments.length});\n`
    vmSetup += `duk_put_global_string(ctx, "rhx_${info.name}_${method.name}");\n`
  }

}