import path from "path";
import fs from "fs/promises";
import util from "util";
import { exec } from "child_process";
import {
  quicktype,
  jsonInputForTargetLanguage,
  InputData,
} from "quicktype-core";
import { inputs } from "./common";

const execProm = util.promisify(exec);

const targetDir = path.join(__dirname, "..", "generated", "rehax");
const tsDefinitionFileLocation = path.join(targetDir, "extracted.ts");

async function run() {
  console.log("Extracting data");
  await fs.mkdir(path.join(targetDir, "extracted"), {
    recursive: true,
  });
  for (const input of inputs) {
    const extractionCommand = `clang -Xclang -ast-dump=json -fsyntax-only -x c++ -std=c++20 -stdlib=libc++ ${input.headerPath} > ${input.destinationPath}`;
    console.log(extractionCommand);
    await execProm(extractionCommand);
  }

  console.log("Generating typescript definition from extracted info");
  const jsonInput = jsonInputForTargetLanguage("typescript");
  // We could add multiple samples for the same desired
  // type, or many sources for other types. Here we're
  // just making one type from one piece of sample JSON.
  await jsonInput.addSource({
    name: "Framework",
    samples: await Promise.all(
      inputs.map((input) => fs.readFile(input.destinationPath, "utf8"))
    ),
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
