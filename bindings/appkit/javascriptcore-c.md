## Libraries

The JavaScriptCore C API bridges the following types:

### AppKit

- NSView
- NSButton
- NSTextField

[TODO] Instead of listing the values here, create documentation that extracts the info from the generated bindings.


## Native Type Conversion

The JavaScriptCore C API is able to convert between the following types:

|           |  Native   |  JavaScript |
|-----------|-----------|-------------|
|         * | boolean   | boolean     |
|      osx  | NSString  | string      |
|      osx  | NSRect    | object ^1   |

 - ^1: The object has the shape { origin: { x: number, y: number }, size: { width: number, height: number } }
