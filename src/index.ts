#!/usr/bin/env node

import inquirer from "inquirer";
import { runCommand } from "./utils/helper.js";
import { logError, logInfo, logSuccess, logWarning } from "./utils/logger.js";
import { upgradeToReact19, upgradeToReactTS19 } from "../web/react19/index.js";
import { typescriptMigrate } from "../web/js-to-ts/index.js";

logInfo("Hello from your CLI!");

function isInsideGitRepo() {
  try {
    logInfo("Checking the current folder is a git repository");
    runCommand("git rev-parse --is-inside-work-tree", "ign");
    logSuccess("Inside a Git repository. Processing...");
  } catch (error) {
    logError("Not inside a Git repository. Exiting...");
  }
}

function hasUnCommittedChanges() {
  try {
    const gitStatus = runCommand("git status --porcelain", "pip")
      .toString()
      .trim();
    return gitStatus.length > 0;
  } catch (error) {
    logError(`Error checking git status: ${error}`);
    return false;
  }
}

async function isWorkingTreeDirty() {
  logInfo("Checking the current repo is dirty or not ...");
  if (hasUnCommittedChanges()) {
    const { proceed } = await inquirer.prompt([
      {
        type: "confirm",
        name: "proceed",
        message: "Uncommitted changes detected. Do you want to continue?",
        default: false,
      },
    ]);
    if (!proceed) {
      logWarning("Aborting process due to uncommitted changes.");
    }
  } else {
    logSuccess("Current repository is clean");
  }
}

async function getUserChoice() {
  const choices = [
    { name: "React JS upgrade to 19", value: "react19" },
    // { name: "React with TS upgrade to 19", value: "reactTs19" },
    { name: "JS to TS Migration", value: "jsToTs" },
    { name: "Exit the process", value: "exit" },
  ];

  const { option } = await inquirer.prompt([
    {
      type: "list",
      name: "option",
      message: "Choose an option:",
      choices,
    },
  ]);

  switch (option) {
    case "react19":
      upgradeToReact19();
      break;
    case "reactTs19":
      upgradeToReact19();
      upgradeToReactTS19();
      break;
    case "jsToTs":
      typescriptMigrate();
      break;
    default:
      logInfo("Exiting.....");
      break;
  }
}

try {
  // For checking the folder is git repository
  isInsideGitRepo();

  // For checking uncommitted changes
  await isWorkingTreeDirty();

  await getUserChoice();
} catch (error) {}
