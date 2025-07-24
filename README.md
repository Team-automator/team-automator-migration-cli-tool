# 📦 team-automator-migration-cli-tool

# 🔧 Migration CLI

A powerful Node.js command-line tool that automates major frontend upgrades by:

- 🚀 Migrating from **React 17 to React 19**
- 🧠 Converting **JavaScript to TypeScript**
- ⚙️ Migrating from **UIKit based storyboards/xibs to SwiftUI**


Save hours of manual work and upgrade with confidence across codebases large and small.

---

## 📦 Features

- Detects outdated React patterns and transforms them to align with React 19
- Converts `.js` and `.jsx` files to `.ts` and `.tsx`, adding type-safe annotations
- Provides a summary of all changes and optionally stages migration commits
- Converts `.xib` files into **SwiftUI** files 
- Converts `.storyboard` file into multiple **SwiftUI** files on screen/page basis
- Converted SwiftUI files includes, navigation flow as well among the generated files if the storyboard has multiple screens that are connected

---

## 🔨 Installation

Clone the repo and set it up locally:

```bash
git clone https://github.com/Team-automator/team-automator-migration-cli-tool.git

## For Web
cd team-automator-migration-cli-tool
# Install dependencies
npm install
# Compile TypeScript
npx tsc
# Link the project globally (for CLI tools or packages) Makes this project available as a global command-line utility during development.
npm link

## For Mobile
cd team-automator-migration-cli-tool/mobile/swift-ui-migration-tool

```
## 📋 Prerequisites
Use mackbook for running SwiftUI migration tool

## 🔧 Execution

For Web
```bash
# run cli command
migrate

```

For Mobile
```bash
# run command
swift run
# Enter the storyboard file path that need to be migrated in CLI
```
