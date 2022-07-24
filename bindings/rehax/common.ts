import path from "path";

const basePath = path.join(__dirname, "..", "..", "native-abstraction");
const targetDir = path.join(__dirname, "..", "generated", "rehax");
export const inputs = [
  {
    name: "View",
    headerPath: path.join(
      basePath,
      "ui",
      "appkit",
      "components",
      "view",
      "View.h"
    ),
    destinationPath: path.join(targetDir, "extracted", "View.json"),
  },
  {
    name: "Button",
    headerPath: path.join(
      basePath,
      "ui",
      "appkit",
      "components",
      "button",
      "Button.h"
    ),
    destinationPath: path.join(targetDir, "extracted", "Button.json"),
  },
];
