import fs from "fs";
import path from "path";
import { logError } from "../../src/utils/logger.js";

/**
 * Recursively renames .ts files to .tsx
 */
export function convertTsToTsx(folderPath: string): void {
  const items = fs.readdirSync(folderPath);

  for (const item of items) {
    const fullPath = path.join(folderPath, item);
    const stat = fs.statSync(fullPath);

    if (stat.isDirectory()) {
      convertTsToTsx(fullPath); // 🔁 Recurse into subdirectories
    } else if (
      stat.isFile() &&
      fullPath.endsWith(".ts") &&
      !fullPath.endsWith(".d.ts")
    ) {
      const tsxPath = fullPath.slice(0, -3) + ".tsx";
      fs.renameSync(fullPath, tsxPath);
      console.log(`✅ Renamed: ${fullPath} → ${tsxPath}`);
    }
  }
}
