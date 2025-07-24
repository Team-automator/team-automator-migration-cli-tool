import { runCommand } from "../../src/utils/helper.js";
import { logSuccess } from "../../src/utils/logger.js";

export function installDependencies() {
  runCommand(
    "npm install --save-dev typescript@4.7.4 @types/react ts-migrate --legacy-peer-deps"
  );
  runCommand("npm install ts-loader source-map-loader --legacy-peer-deps");
  logSuccess("Typescript dependencies installed");
}
