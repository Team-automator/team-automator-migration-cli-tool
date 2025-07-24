import { logInfo, logSuccess } from "../src/utils/logger.js";
import { getTestScripts } from "./get-test-scripts.js";

export async function postMigrateCheck() {
  logInfo("Running the testcases after migration");
  await getTestScripts();
  logSuccess("Migration changes tested successfully");
}
