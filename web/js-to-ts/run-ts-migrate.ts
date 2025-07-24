import path from "path";
import { runCommand } from "../../src/utils/helper.js";
import { logSuccess } from "../../src/utils/logger.js";
import { convertTsToTsx } from "./convert-ts-to-tsx.js";
import { updateTSConfig } from "./update-tsconfig.js";

export function runTsMigratePlugin() {
  runCommand("npx ts-migrate init .");
  logSuccess("tsConfig.json created");

  runCommand("npx ts-migrate rename .");
  logSuccess("File names got changed to TS format");

  updateTSConfig();

  const folderPath = path.resolve(process.cwd(), "src");
  convertTsToTsx(folderPath);

  runCommand("npx ts-migrate migrate .");
}
