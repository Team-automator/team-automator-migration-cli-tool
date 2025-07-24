import chalk from "chalk";
import { execSync } from "child_process";
import { logError, logInfo } from "./logger.js";

type StdioModeKey = "inh" | "pip" | "ign";

interface StdioMode {
  desc: string;
  use: string;
  val: "inherit" | "pipe" | "ignore";
}

export function handleError(err: Error) {
  logError(`Exiting with error: ${err.message}`);
  process.exit(1);
}

export function runCommand(command: string, option?: StdioModeKey) {
  const stdioModes: Record<StdioModeKey, StdioMode> = {
    inh: {
      desc: "Real-time output to terminal",
      use: "For CLI tools or visible shell commands",
      val: "inherit",
    },
    pip: {
      desc: "Capture output programmatically",
      use: "For logging, parsing, or silent execution",
      val: "pipe",
    },
    ign: {
      desc: "Suppress all output",
      use: "For silent background tasks",
      val: "ignore",
    },
  };
  const stdioMode: any = stdioModes[option || "inh"]?.val;
  try {
    logInfo(`${chalk.magenta("Executing: ")} ${command}`);
    return execSync(command, { stdio: stdioMode });
  } catch (error: any) {
    logError(`Failed to run: ${command}, ${error}`);
    throw new Error(error);
  }
}
