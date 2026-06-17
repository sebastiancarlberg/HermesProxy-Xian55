# Codex Workflow

This repository is the local working fork of Xian55/HermesProxy for WotLK Classic 3.4.3 -> 3.3.5a testing. Follow this workflow unless the user explicitly asks for a different flow.

## Branch Roles

- `master` tracks the general Xian55 release branch.
- `feature/wotlk-classic-v3.4.3` is the main WotLK testing branch and current baseline for local builds.
- Start new fixes from `feature/wotlk-classic-v3.4.3` unless the user names another branch.
- Use focused branches such as `fix/<short-name>`, `feature/<short-name>`, or `diagnostic/<short-name>`.
- Keep `upstream` pointed at `https://github.com/Xian55/HermesProxy.git` and `origin` pointed at the user's fork.

## Fix Workflow

1. Run the fresh-session checklist before branch or commit decisions.
2. Create a focused branch from the current WotLK baseline.
3. Keep local launchers, local build outputs, machine-specific config, packet logs, crash dumps, and broad diagnostics out of commits.
4. Build and let the user test.
5. Commit only fixes that are verified by user runtime testing or by a targeted local repro.
6. Merge verified branches back into the WotLK integration branch only when the user asks.

If mixed work already exists, first preserve it on a clearly named `wip/...` or `test/...` branch, then split verified pieces into focused branches.

## Local Files

- `launchers/`, `build/`, and `setup.log` are excluded locally through `.git/info/exclude`.
- `setup.ps1` is the local publish script for this checkout.
- Use `launchers/Start Hermes Xian55 + Client.cmd` for local play testing after a successful build.

## Current Testing Pattern

- The repo root is the current checkout directory.
- Build from the repo root with:
  `.\setup.ps1`
- The script publishes `HermesProxy/HermesProxy.csproj` to `build/` and writes a WotLK local `appsettings.json`.
- Manual publish equivalent:
  `dotnet publish HermesProxy/HermesProxy.csproj -c Release -r win-x64 --self-contained true -o build`
- This repo targets `net10.0`; if the system `dotnet` cannot build it, install or use a local .NET 10 SDK outside the repo and do not commit machine-specific SDK paths.

## Fresh Session Checklist

1. Run `git status --short --branch` and `git branch --list -vv`.
2. Read this file before making branch or commit decisions.
3. Check recent WotLK history with `git log --oneline --decorate --graph --max-count=30 feature/wotlk-classic-v3.4.3`.
4. Run `git fetch --prune --all --tags` when network access is available, then compare `origin`, `upstream`, and the active branch.
5. Prefer local code, logs, packet captures, and user runtime reports over memory from prior sessions.

## Project Notes

- `wotlk.md` is the main upstream status document for 3.4.3 work.
- `docs/local-old-fork-comparison.md` tracks potentially useful differences from the older local HermesProxy-WOTLK fork.
- A local Wrathion 3.4.3 source/build checkout is a useful reference for packet layouts and update-field serialization. In this workspace, likely references are sibling folders such as `Wrathion-3.4.3_Source` and `Wrathion-3.4.3-build`.
- Do not commit absolute paths to local Wrathion, AzerothCore, Arctium, WoW client, or Docker/runtime folders.

## Debugging References

- Prefer field-by-field comparison against Wrathion/Trinity-style 3.4.3 implementations when modern update-field serialization is suspect.
- Useful reference areas include object update builders, update-field descriptors, `WorldSession` packet handlers, LFG/battleground packet structures, and hotfix/DB2 emitters.
- Use Hermes logs, packet captures/sniffs, client crash dumps, and deterministic user repro reports together. A repeatable crash at the same client instruction usually points to packet layout, field width, bit alignment, or missing hotfix data.
- Broad gates such as skipping entire object update categories are diagnostic stabilizers only. Final fixes should repair the specific serializer/translator path.
