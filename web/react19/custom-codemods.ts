import { fileURLToPath } from "url";
import { dirname, resolve } from "path";
import { runCommand } from "../../src/utils/helper.js";

export function runCustomCodeMod() {
  // Run the null check codemod
  nullCheckCodeMod();
}

function nullCheckCodeMod() {
  const __filename = fileURLToPath(import.meta.url);
  const __dirname = dirname(__filename);
  const codemodPath = resolve(
    __dirname,
    "../custom-codemod/add-root-null-check.cjs"
  );
  runCommand(`npx jscodeshift -t ${codemodPath} ./src --extensions=ts,tsx`);
}
