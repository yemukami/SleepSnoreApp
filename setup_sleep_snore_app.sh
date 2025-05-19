#!/usr/bin/env bash
set -e

# ベースディレクトリ
ROOT="$(pwd)"

# アプリ本体ディレクトリ
mkdir -p "$ROOT/SleepSnoreApp"
cd "$ROOT/SleepSnoreApp"

# Xcode プロジェクト用フォルダ
mkdir -p SleepSnoreApp.xcodeproj

# アプリソース構造
mkdir -p SleepSnoreApp/{Assets.xcassets,Views,ViewModels,Models,Services,Resources}
touch \
  SleepSnoreApp/Info.plist \
  SleepSnoreApp/AppDelegate.swift \
  SleepSnoreApp/SceneDelegate.swift \
  SleepSnoreApp/ContentView.swift \
  SleepSnoreApp/Views/{HomeView.swift,SettingsView.swift,HistoryView.swift} \
  SleepSnoreApp/ViewModels/{HomeViewModel.swift,SettingsViewModel.swift,HistoryViewModel.swift} \
  SleepSnoreApp/Models/{ThresholdConfig.swift,Session+CoreData.swift} \
  SleepSnoreApp/Services/{AudioEngineManager.swift,PersistenceController.swift,ConfigStorage.swift} \
  SleepSnoreApp/Resources/LaunchScreen.storyboard

# テストフォルダ
mkdir -p "$ROOT/Tests/SleepSnoreAppTests" "$ROOT/Tests/SleepSnoreAppUITests"
touch \
  Tests/SleepSnoreAppTests/AudioEngineManagerTests.swift \
  Tests/SleepSnoreAppUITests/HomeViewUITests.swift

# .vscode フォルダ
mkdir -p "$ROOT/.vscode"
cat > .vscode/extensions.json << 'E2'
{
  "recommendations": [
    "GitHub.copilot",
    "ms-swift.swift",
    "swift-server.swift-format",
    "openai.openai-vscode",
    "ms-vscode.cpptools",
    "usernamehw.errorlens"
  ]
}
E2

cat > .vscode/settings.json << 'E3'
{
  "swift.path.sourcekit-lsp": "/usr/bin/sourcekit-lsp",
  "swift.path.swift-driver": "/usr/bin/swift",
  "editor.defaultFormatter": "swift-server.swift-format",
  "[swift]": {
    "editor.formatOnSave": true,
    "editor.tabSize": 2,
    "editor.insertSpaces": true
  },
  "github.copilot.enable": {
    "*": true,
    "plaintext": false,
    "markdown": false
  },
  "openai.api.key": "${env:OPENAI_API_KEY}",
  "openai.chatgpt.enable": true,
  "terminal.integrated.shell.osx": "/bin/zsh"
}
E3

cat > .vscode/tasks.json << 'E4'
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Build iOS App",
      "type": "shell",
      "command": "xcodebuild -scheme SleepSnoreApp -workspace SleepSnoreApp.xcworkspace -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 14' clean build",
      "group": "build",
      "problemMatcher": ["$msCompile"]
    },
    {
      "label": "Run Tests",
      "type": "shell",
      "command": "xcodebuild test -scheme SleepSnoreApp -workspace SleepSnoreApp.xcworkspace -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 14'",
      "group": "test",
      "problemMatcher": ["$msCompile"]
    }
  ]
}
E4

echo "SleepSnoreApp scaffold script created."
