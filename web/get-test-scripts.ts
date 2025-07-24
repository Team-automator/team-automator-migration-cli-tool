import fs from "fs";
import inquirer from "inquirer";
import path from "path";
import { logInfo, logSuccess, logWarning } from "../src/utils/logger.js";
import { runCommand } from "../src/utils/helper.js";

export async function getTestScripts() {
  const packageJsonPath = path.join(process.cwd(), "package.json");
  const raw = fs.readFileSync(packageJsonPath, "utf-8");
  const pkg = JSON.parse(raw);

  const scripts = pkg.scripts || {};
  const testScripts = Object.entries(scripts).filter(([key]) =>
    key.toLowerCase().includes("test")
  );

  if (testScripts.length > 0) {
    logInfo("🧪 Test Scripts in package.json:\n");
    runCommand("npx playwright install");

    for (const [key, value] of testScripts) {
      const { proceed } = await inquirer.prompt([
        {
          type: "confirm",
          name: "proceed",
          message: `Would you like to run ${value}. Do you want to continue?`,
          default: false,
        },
      ]);
      if (!proceed) {
        logWarning(`Aborting --- ${value} --- testcase execution`);
      } else {
        runCommand(`npm run ${key}`);
      }
    }
  }
  logSuccess("Testcases ran successfully");
}
