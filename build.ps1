# Builds ProgressDisplayer.dll against the installed game and packs ProgressDisplayer.zip.
# Needs no .NET SDK: it uses the Roslyn compiler bundled with an installed Unity editor
# (the source uses tuples, which the C# 5 compiler in .NET Framework 4 cannot parse).
param(
    [string]$GameDir = 'C:\Program Files (x86)\Steam\steamapps\common\A Dance of Fire and Ice',
    [string]$ZipPath = (Join-Path $PSScriptRoot 'ProgressDisplayer.zip'),
    [string]$UnityData = (Get-ChildItem 'C:\Program Files\Unity\Hub\Editor\*\Editor\Data' -Directory |
        Sort-Object FullName | Select-Object -Last 1 -ExpandProperty FullName)
)
$ErrorActionPreference = 'Stop'

$dotnet = Join-Path $UnityData 'NetCoreRuntime\dotnet.exe'
$csc = Join-Path $UnityData 'DotNetSdkRoslyn\csc.dll'
if (-not (Test-Path $dotnet) -or -not (Test-Path $csc)) {
    throw 'No C# compiler found. Pass -UnityData <path to a Unity editor Data folder>.'
}
$managed = Join-Path $GameDir 'A Dance of Fire and Ice_Data\Managed'
$src = Join-Path $PSScriptRoot 'ProgressDisplayer2'
$stage = Join-Path $PSScriptRoot 'build\ProgressDisplayer'

$refs = @(
    'mscorlib.dll', 'System.dll', 'System.Core.dll', 'System.Xml.dll', 'netstandard.dll',
    'Assembly-CSharp.dll', 'Assembly-CSharp-firstpass.dll', 'RDTools.dll',
    'UnityEngine.dll', 'UnityEngine.CoreModule.dll', 'UnityEngine.IMGUIModule.dll',
    'UnityEngine.TextRenderingModule.dll', 'UnityEngine.UI.dll', 'UnityEngine.UIModule.dll',
    'UnityModManager\0Harmony.dll', 'UnityModManager\UnityModManager.dll'
) | ForEach-Object { '/reference:' + (Join-Path $managed $_) }

if (Test-Path $stage) { Remove-Item -Recurse -Force $stage }
New-Item -ItemType Directory -Force $stage | Out-Null

$sources = Get-ChildItem $src -Filter *.cs -File | ForEach-Object { $_.FullName }
$sources += Join-Path $src 'Properties\AssemblyInfo.cs'

& $dotnet $csc /nologo /noconfig /nostdlib+ /target:library /optimize+ /warn:4 `
    "/out:$(Join-Path $stage 'ProgressDisplayer.dll')" $refs $sources
if ($LASTEXITCODE -ne 0) { throw "Compilation failed (exit code $LASTEXITCODE)." }

Copy-Item (Join-Path $src 'Info.json') $stage
if (Test-Path $ZipPath) { Remove-Item -Force $ZipPath }
Compress-Archive -Path $stage -DestinationPath $ZipPath
"Built $ZipPath"
