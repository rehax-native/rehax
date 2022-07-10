import path from "path";
import fs from "fs/promises";
import util from "util";
import { exec } from "child_process";
import {
  quicktype,
  jsonInputForTargetLanguage,
  InputData,
} from "quicktype-core";

const execProm = util.promisify(exec);

// const frameworkName = "Foundation";
const frameworkName = "AppKit";
const frameworkLocation =
  "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/Library/Frameworks/";
const frameworkHeaderPath = path.join(
  frameworkLocation,
  `${frameworkName}.framework`,
  "Headers",
  `${frameworkName}.h`
  // `NSDate.h` ////////////////
);

const targetDir = path.join(
  __dirname,
  "generated",
  `${frameworkName}.framework`,
);
const targetLocation = path.join(
  targetDir,
  "extracted.json"
);
const tsDefinitionFileLocation = path.join(
  __dirname,
  "generated",
  `${frameworkName}.framework`,
  "extracted.ts"
);

const extractionCommand = `clang -Xclang -ast-dump=json -fsyntax-only -x objective-c ${frameworkHeaderPath} > ${targetLocation}`;

async function run() {
  await fs.mkdir(targetDir, {
    recursive: true,
  });
  console.log("Extracting data");
  console.log(extractionCommand);
  await execProm(extractionCommand);

  console.log("Generating typescript definition from extracted info");
  const jsonInput = jsonInputForTargetLanguage("typescript");
  // We could add multiple samples for the same desired
  // type, or many sources for other types. Here we're
  // just making one type from one piece of sample JSON.
  await jsonInput.addSource({
    name: "Framework",
    samples: [await fs.readFile(targetLocation, "utf8")],
  });

  const inputData = new InputData();
  inputData.addInput(jsonInput);

  const { lines } = await quicktype({
    inputData,
    lang: "typescript",
  });

  await fs.writeFile(tsDefinitionFileLocation, lines.join("\n"));
}

run();
