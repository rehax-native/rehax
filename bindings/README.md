# Rehax Bindings

Tools to generate bindings between native libraries and scripting languages.

Run `pnpm run extract` to extract header info from a framework, then `pnpm run generate` to generate the bindings.

## MacOS and iOS

Clang is used to extract information from headers. This information is then used to generate bindings.

