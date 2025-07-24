import { runCommand } from "../src/utils/helper.js";
import { logInfo, logSuccess } from "../src/utils/logger.js";
import { getTestScripts } from "./get-test-scripts.js";

export async function preMigrateCheck() {
  logInfo("Installing the dependencies...");
  runCommand("npm install --legacy-peer-deps");

  logInfo("Running the testcases before migration");
  await getTestScripts();
  logSuccess("Premigration check is successful");
}
