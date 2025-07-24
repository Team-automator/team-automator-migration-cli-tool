import chalk from "chalk";
import logSymbols from "log-symbols";

export function logInfo(msg: string) {
  console.log(`${logSymbols.info} ${chalk.cyan("INFO")} ${msg}`);
}

export function logSuccess(msg: string) {
  console.log(`${logSymbols.success} ${chalk.green("SUCCESS")} ${msg}`);
}

export function logWarning(msg: string) {
  console.log(`${logSymbols.warning} ${chalk.yellow("WARNING")} ${msg}`);
}

export function logError(msg: string) {
  console.log(`${logSymbols.error} ${chalk.red("ERROR")} ${msg}`);
}
