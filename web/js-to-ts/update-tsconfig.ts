import path from "path";
import fs from "fs";
import { applyEdits, modify } from "jsonc-parser";
import { logInfo } from "../../src/utils/logger.js";

export function updateTSConfig() {
  logInfo("Updating the tsConfig.json");

  const tsconfigPath = path.resolve(process.cwd(), "tsconfig.json");

  // Read the file
  let content = fs.readFileSync(tsconfigPath, "utf8");

  // Define the updates you want to make
  const updates = [
    { path: ["compilerOptions", "outDir"], value: "./built" },
    { path: ["compilerOptions", "allowJs"], value: true },
    { path: ["compilerOptions", "jsx"], value: "react-jsx" },
    { path: ["compilerOptions", "resolveJsonModule"], value: true },
    { path: ["include"], value: ["./src/**/*"] },
  ];

  for (const { path, value } of updates) {
    const edits = modify(content, path, value, {
      formattingOptions: {
        insertSpaces: true,
        tabSize: 2,
      },
    });

    // Apply edits to the original content
    content = applyEdits(content, edits);
  }

  // Write back to file
  fs.writeFileSync(tsconfigPath, content, "utf8");
}
