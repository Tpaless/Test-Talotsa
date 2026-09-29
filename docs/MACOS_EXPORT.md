# macOS export (version 1.0.1)

The `macOS` preset exports a Universal app for Apple Silicon and Intel Macs. Export to a ZIP file so the app executable keeps its Unix execute permission when built on Windows.

With Godot 4.7.2 and its matching macOS export template installed, run from the project root:

```powershell
godot --headless --path . --export-release macOS Builds/macOS/Test-Talotsa-v1.0.1-macOS.zip
```

Copy the ZIP to a Mac, extract it, and launch `TEST Talotsa.app`. The app uses Godot's built-in ad hoc code signing. It has not been notarized with an Apple Developer ID, so macOS may ask you to approve it on first launch in System Settings > Privacy & Security. The game itself has not been run on a Mac as part of this Windows export.

Godot reference: [Exporting for macOS](https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_macos.html).