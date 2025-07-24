import { runCommand } from "../../src/utils/helper.js";
import { logInfo, logSuccess } from "../../src/utils/logger.js";
import { getTestScripts } from "../get-test-scripts.js";
import { postMigrateCheck } from "../post-migration-check.js";
import { preMigrateCheck } from "../pre-migration-check.js";
import { installDependencies } from "./install-ts-dependencies.js";
import { runTsMigratePlugin } from "./run-ts-migrate.js";

export async function typescriptMigrate() {
  // checking the testcases before the migration
  await preMigrateCheck();

  installDependencies();

  runTsMigratePlugin();

  logSuccess("TS migration completed");

  // checking the testcases after the migration
  await postMigrateCheck();
}
