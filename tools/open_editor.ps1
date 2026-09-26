param(
 [string]$GodotConsole = "C:\Users\amits\Documents\Codex\2026-09-13\i-x20\work\godot-4.7.2\editor\Godot_v4.7.2-stable_win64_console.exe"
)
$ErrorActionPreference = "Stop"
$engineVersion = (& $GodotConsole --version | Out-String).Trim()
if ($engineVersion -notmatch '^4\.7\.2\.') { throw "Shotgun Kid requires Godot 4.7.2. Found: $engineVersion" }
$projectDirectory = Split-Path -Parent $PSScriptRoot
$godotEditor = Join-Path (Split-Path -Parent $GodotConsole) "Godot_v4.7.2-stable_win64.exe"
Start-Process -FilePath $godotEditor -ArgumentList @("--editor", "--path", ('"' + $projectDirectory + '"'))
