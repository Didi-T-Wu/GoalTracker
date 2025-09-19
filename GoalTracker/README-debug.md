# Debugging / Running GoalTracker (macOS)

Quick commands to build and run the app from macOS (zsh).

Build MacCatalyst (mac app):

```bash
cd /Users/didiwu/repos/GoalTracker/GoalTracker
dotnet build -f net9.0-maccatalyst
```

Run MacCatalyst:

```bash
dotnet run -f net9.0-maccatalyst --runtime maccatalyst-x64 --project /Users/didiwu/repos/GoalTracker/GoalTracker/GoalTracker.csproj
```

Build & run iOS simulator (example):

```bash
cd /Users/didiwu/repos/GoalTracker/GoalTracker
dotnet build -f net9.0-ios
# then launch via IDE or use run with the proper runtime (e.g., iossimulator-x64)
```

Build & run Android (emulator/device):

```bash
cd /Users/didiwu/repos/GoalTracker/GoalTracker
dotnet build -f net9.0-android
dotnet run -f net9.0-android --project /Users/didiwu/repos/GoalTracker/GoalTracker/GoalTracker.csproj
```

Notes:
- On macOS, prefer Visual Studio for Mac for iOS simulator workflows. From VS Code, use the commands above and ensure Xcode and Android SDKs are installed.
- If the app seems to start without terminal output, check macOS Activity Monitor or run the app bundle directly in Finder.
