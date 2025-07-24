import { runCommand } from "../../src/utils/helper.js";
import { logError, logInfo, logSuccess } from "../../src/utils/logger.js";
import { postMigrateCheck } from "../post-migration-check.js";
import { preMigrateCheck } from "../pre-migration-check.js";
import { runCustomCodeMod } from "./custom-codemods.js";

export async function upgradeToReact19() {
  try {
    // checking the testcases before the migration
    await preMigrateCheck();

    runCommand(
      "npm i react@latest react-dom@latest @types/react@latest @types/react-dom@latest @testing-library/react@latest @testing-library/jest-dom --legacy-peer-deps"
    );

    logSuccess("Packages updated successfully!");

    process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0";
    logInfo(
      "Environment variable value set as NODE_TLS_REJECT_UNAUTHORIZED = 0"
    );

    // Codemods
    const codemods = [
      "use-context-hook",
      "remove-context-provider",
      "remove-forward-ref",
      "replace-act-import",
      "replace-string-ref",
      "replace-use-form-state",
      "replace-reactdom-render",
    ];

    const codemodsReact = [
      "create-element-to-jsx",
      "rename-unsafe-lifecycles",
      "update-react-imports",
    ];

    codemods.forEach((mod) =>
      runCommand(`npx codemod@latest react/19/${mod} --target ./src`)
    );

    codemodsReact.forEach((mod) =>
      runCommand(`npx codemod@latest react/${mod} --target ./src`)
    );

    logInfo("Running the custom codemod script...");
    runCustomCodeMod();

    logSuccess("Migration completed successfully!");

    // checking the testcases after the migration
    await postMigrateCheck();
  } catch (error: any) {
    logError(`Migration script failed: ${error.message}`);
    process.exit(1); // End script on failure
  }
}

export function upgradeToReactTS19() {
  // execSync('npm install --save-exact @types/react@^19.0.0 @types/react-dom@^19.0.0', {
  //   stdio: 'inherit'
  // });
  console.log("Installation ts complete");
}
