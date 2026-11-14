# ProgressDisplayer2

UnityModManager mod for A Dance of Fire and Ice. Source lives in `ProgressDisplayer2/`.

## Build

```powershell
.\build.ps1                                   # writes ProgressDisplayer.zip next to the script
.\build.ps1 -ZipPath "$env:USERPROFILE\Downloads\ProgressDisplayer.zip"
```

- This machine has no .NET SDK or Visual Studio, so the `.csproj` cannot be built. `build.ps1`
  compiles with the Roslyn `csc.dll` bundled with the installed Unity editor and references the
  DLLs of the installed game directly, so a successful build means every game API used still exists.
- The zip contains `ProgressDisplayer/Info.json` and `ProgressDisplayer/ProgressDisplayer.dll`.
  `Info.json` is kept in `ProgressDisplayer2/Info.json`; bump `Version` there.

## Gotchas

- The source in this repo is older than the upstream v2.0.8 binary (no X-accuracy option, no
  per-tile progress update); upstream never published that source here.
- Game updates rename or remove patch targets. `Main.OnToggle` patches each nested class of
  `Patch` separately and logs `Skipped patch <name>` instead of aborting; check
  `%USERPROFILE%\AppData\LocalLow\7th Beat Games\A Dance of Fire and Ice\Player.log` for those lines.
- The committed `bin/` and `obj/` folders are stale upstream build output, not used by `build.ps1`.
