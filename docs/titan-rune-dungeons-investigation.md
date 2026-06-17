# Titan Rune Dungeon Investigation

Last reviewed: 2026-06-17.

## Context

Wrathion is useful here as a native 3.4.3 reference: it shows what a Classic Wrath-facing server can expose to the client. Our actual backend is AzerothCore 3.3.5a, so Hermes can translate packets and hotfix data, but it cannot fully implement dungeon mechanics unless AzerothCore also knows about them.

## What Wrathion Shows

Source checked:

- Local source: `C:\Users\carlb\Documents\WoW\Wrathion-3.4.3_Source`
- GitHub source: `https://github.com/lineagedr/3.4.3_Source`
- GitHub release asset: `Databases.7z` from `https://github.com/lineagedr/3.4.3_Source/releases/tag/databases`
- Extracted scratch copy: `C:\Users\carlb\Documents\WoW\_scratch_wrathion_db\extracted`

Wrathion's `LFGMgr.cpp` loads LFG entries from `LFGDungeons.db2`/hotfix rows and then augments them from the world DB `lfg_dungeon_template` table.

The released Wrathion `hotfixes.sql` contains `lfg_dungeons` rows for Titan Rune Protocol Gamma only:

- `2447` - `Random Lich King Titan Rune Protocol Gamma`
- `2448` through `2463` - the specific Gamma dungeon entries, including Utgarde Keep, Culling of Stratholme, Nexus, Oculus, Trial of the Champion, Utgarde Pinnacle, Violet Hold, Ahn'kahet, Azjol-Nerub, Drak'Tharon, Gundrak, Halls of Lightning, Halls of Stone, Halls of Reflection, Pit of Saron, and Forge of Souls.

The same DB release did not expose matching `lfg_dungeons` rows for Protocol Alpha or Beta. It may be incomplete, or Wrathion may only have wired Gamma in this public database.

The released `world.sql` contains a Gamma daily quest:

- `78752` - `Proof of Demise: Titan Rune Protocol Gamma`

It also has LFG reward/template tables, but the random reward table excerpt only includes older random dungeon IDs such as `258`, `259`, `260`, `261`, and `262`, plus holiday rows. No direct reward rows for `2447` were present in the checked slice.

## What Hermes Already Has

Hermes already has 3.4.3 spell hotfix CSV data for the Titan Rune spells:

- Alpha: `392423`, `392430`, `394435`, `394437`, `394438`, `394441`, `394444`
- Beta: `412397`, `412470`, `412770`, `412867`, `412991`, `413078`, `413169`, `413573`
- Gamma: `424184`, `424194`, `424196`, `424201`, `424203`, `424205`, `424210`, `424211`

These are in `HermesProxy/CSV/Hotfix/SpellName3.csv`, with supporting spell/effect rows in the other 3.4.3 spell hotfix CSVs.

Hermes does not currently have an `LfgDungeons` hotfix CSV/loader. `DB2Hash.LfgDungeons` exists, but `GameData.LoadHotfixes()` only loads the existing spell/item/creature/customization/etc. tables. `WorldSocket.SendAvailableHotfixes()` also filters V3_4_3 available hotfixes to character customization tables only.

## Feasibility

Gamma UI exposure looks feasible as a Hermes experiment, but it is not just a packet handler:

1. Add a `LfgDungeons3.csv` source and a `LoadLfgDungeonsHotfixes()` writer matching the 3.4.3 `LFGDungeonsEntry` layout.
2. Include `DB2Hash.LfgDungeons` in the V3_4_3 hotfix availability path without regressing the packet-size/cache behavior.
3. Decide how to bridge slot IDs:
   - Pass Gamma IDs like `2447` to AzerothCore only if AzerothCore's DB knows those LFG IDs.
   - Or translate Gamma random/specific slots back to existing AzerothCore heroic/random IDs, accepting that the backend will still run normal heroic mechanics.
4. Test whether the client accepts injected LFG dungeon hotfixes and whether `CMSG_DF_JOIN` emits the expected slot IDs.

Full Alpha/Beta/Gamma gameplay is backend work, not proxy-only work. AzerothCore would need dungeon selection, instance difficulty/state, creature scaling, reward quests/currency, loot, and per-dungeon rune mechanics. The proxy can make the Classic client see and request those modes; it cannot make legacy creatures gain the correct health/damage/mechanics by itself.

## Likely Next Investigation Branch

Use a research branch such as `research/titan-rune-lfg-hotfixes`.

Suggested first test:

1. Add only the Wrathion Gamma `lfg_dungeons` rows as Hermes hotfix data.
2. Keep the backend mapping conservative: do not attempt mechanics yet.
3. Log all `CMSG_DF_JOIN` slots and all `SMSG_LFG_PLAYER_INFO` slots.
4. Verify whether the Gamma category appears in the client and whether selecting it emits slot `2447`.

If that works, the next decision is whether to build an AzerothCore module/DB patch for actual Titan Rune behavior or keep Gamma as a UI-only/normal-heroic routing experiment.
