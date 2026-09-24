param([string]$AsepritePath = 'C:\Program Files (x86)\Steam\steamapps\common\Aseprite\Aseprite.exe')
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
if (-not (Test-Path -LiteralPath $AsepritePath)) { throw 'Set -AsepritePath to the installed Aseprite executable.' }
foreach ($sourceFile in Get-ChildItem -LiteralPath (Join-Path $projectRoot 'assets/source') -Filter '*.aseprite') {
    $exportPath = Join-Path $projectRoot ('assets/textures/' + $sourceFile.BaseName + '.png')
    $process = Start-Process -FilePath $AsepritePath -ArgumentList @('-b', ('"' + $sourceFile.FullName + '"'), '--save-as', ('"' + $exportPath + '"')) -WindowStyle Hidden -PassThru -Wait
    if ($process.ExitCode -ne 0) { throw "Export failed: $($sourceFile.Name)" }
}
Write-Output 'Aseprite sources exported. Godot will reimport changed PNGs.'
