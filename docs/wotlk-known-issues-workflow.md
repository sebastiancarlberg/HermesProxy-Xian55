# WotLK Known Issues Workflow

Last reviewed: 2026-06-17.

This file is the working queue for the `feature/wotlk-classic-v3.4.3` branch in this fork. It combines:

- Local repo docs: `docs/known-issues.md` and `wotlk.md`.
- Live upstream GitHub Issues from `Xian55/HermesProxy`.
- Our local testing setup in `setup.ps1` and the ignored `launchers/` folder.

GitHub forks do not copy upstream Issues into the fork. Our fork has the code and branches, but the public issue tracker remains at `https://github.com/Xian55/HermesProxy/issues` unless we create separate tracking issues in `sebastiancarlberg/HermesProxy-Xian55`.

## Fix Workflow

1. Start clean on `feature/wotlk-classic-v3.4.3`.
2. Pick one issue from the queue below.
3. Create a narrow branch:
   - `fix/issue-105-spell-go-overread`
   - `fix/issue-103-acore-df-roles`
   - `fix/wotlk-motransport`
4. Reproduce before editing.
   - Run `.\setup.ps1`.
   - Start with `launchers\Start Hermes Xian55 + Client.cmd` or `launchers\Start Hermes Xian55 Only.cmd`.
   - Save Hermes logs, packet logs, client crash behavior, and exact backend used.
5. Compare packet layout against the best oracle.
   - Prefer Wrathion / native 3.4.3 source or capture for WotLK wire shape.
   - Use CypherCoreClassicWOTLK when 3.4.3 source has incomplete CMSG reads.
   - Use old `HermesProxy-WOTLK-fork` as a translated-path reference, not a blind source of truth.
6. Implement the smallest V3_4_3-gated fix that explains the repro.
7. Build with `.\setup.ps1`.
8. Verify in game with the same repro steps.
9. Document the result in this file or `wotlk.md`.
10. Commit and push the fix branch.
11. Merge back into `feature/wotlk-classic-v3.4.3` only after the repro is verified fixed and the main local flow still launches.

## Priority Queue

| Priority | Source | Issue | Backend | Branch name | Status / first check |
|---|---|---|---|---|---|
| P0 | [#105](https://github.com/Xian55/HermesProxy/issues/105) | `SMSG_SPELL_GO` parse over-read recurring combat disconnect | AzerothCore / TrinityCore | `fix/issue-105-spell-go-overread` | Reproduce in combat and inspect spell target/effect read boundaries. |
| P1 | [#103](https://github.com/Xian55/HermesProxy/issues/103) | Solo Dungeon Finder proposal/entry path | AzerothCore | `fix/issue-lfg-proposal-double-rideticket-bit` | 2026-06-17: proposal accept and Deadmines entry verified after removing duplicate `RideTicket` bit consume. Keep watching role edge cases and post-entry LFG status packets. |
| P0 | [#104](https://github.com/Xian55/HermesProxy/issues/104) | Dungeon Finder appears to pass through | cMangos | `fix/issue-104-cmangos-df` | Check cMangos opcode/layout differences after TC LFG path. |
| P1 | [#106](https://github.com/Xian55/HermesProxy/issues/106) | BG scoreboard empty; no end-of-match popup | TrinityCore | `fix/issue-106-bg-scoreboard` | `MSG_PVP_LOG_DATA` is reportedly dropped to `MSG_NULL_ACTION`; inspect opcode table and handler path. |
| P1 | [#107](https://github.com/Xian55/HermesProxy/issues/107) | BG party/raid members show Unknown/offline/Dead out of range | TrinityCore | `fix/issue-107-bg-raid-members` | Inspect party/member status packets during bot-filled BG. |
| P1 | [#96](https://github.com/Xian55/HermesProxy/issues/96) / [#101](https://github.com/Xian55/HermesProxy/issues/101) | Transport / MOTransport crashes or is filtered | AzerothCore / cMangos | `fix/wotlk-motransport` | `wotlk.md` says zeppelins/elevators remain filtered and untested/broken. |
| P2 | `wotlk.md` | Sporadic `CMSG_LOG_DISCONNECT(reason=7)` under load | TC / unknown | `fix/wotlk-reason-7-diagnostics` | Existing ring-buffer logs may need expansion around current repro. |
| P2 | `wotlk.md` | Action Bar 2/3/4/5 visibility checkboxes do not persist | Client account data | `fix/wotlk-edit-mode-account-data` | Needs V3_4_3 Edit Mode account-data capture; legacy CVars are ignored. |
| P2 | `wotlk.md` | Ground-target persistent AOE visual missing after successful cast | TC | `fix/wotlk-dynamicobject-aoe-visual` | DnD cast works, but ground swirl does not render; suspect `DynamicObject` or spell visual packet. |
| P2 | `wotlk.md` | Pet spellbook "Pet" tab missing/broken | TC | `fix/wotlk-pet-spellbook-tab` | Prior native diff matched obvious fields; needs fresh capture or different UI data path. |
| P2 | `wotlk.md` | Random suffix stats missing from item tooltip | TC | `fix/wotlk-random-suffix-tooltip` | Stats apply but tooltip omits suffix bonuses. |
| P2 | `wotlk.md` | Quest tracker click-to-map navigation does not open map | TC / cMangos untested | `fix/wotlk-quest-poi-navigation` | Likely synthesize missing quest POI coords from translated POI blob data. |
| P2 | `wotlk.md` | cMangos quest log state desync after pickup | cMangos | `fix/cmangos-quest-log-refresh` | Quest tracker/map update live; log list refreshes after relog. |
| P2 | `wotlk.md` | cMangos vendor sell leaves grey permanent item | cMangos | `fix/cmangos-vendor-sell` | Buy works; inspect sell response and inventory slot update. |
| P2 | `wotlk.md` | cMangos inventory on-use items do not trigger | cMangos | `fix/cmangos-use-item` | Food/bandages/potions do not fire; likely legacy `CMSG_USE_ITEM` layout difference. |
| Done | 2026-06-17 log | Legacy `SMSG_DISMOUNT` is unhandled | AzerothCore | `fix/wotlk-smsg-dismount` | Fixed by translating the empty legacy dismount event to modern `SMSG_DISMOUNT`; latest test log has no remaining `SMSG_DISMOUNT` warnings. |
| Done | 2026-06-17 log | Legacy `SMSG_MOVE_SET_COLLISION_HGT` is unhandled | AzerothCore | `fix/wotlk-move-collision-height` | Latest test log has no remaining `SMSG_MOVE_SET_COLLISION_HGT` warnings; branch also maps V3_4_3 `CMSG_MOVE_SET_COLLISION_HEIGHT_ACK` (`0x3A3B`) so client ACKs do not fall through as `MSG_NULL_ACTION`. |
| P2 | 2026-06-17 log | Legacy `SMSG_SPELL_EXECUTE_LOG` is unhandled | AzerothCore | `fix/wotlk-spell-execute-log` | Seen during gameplay; may affect combat log or spell effect feedback. |
| P3 | `wotlk.md` | Warlock soulshard item add can disconnect | TC carryover | `fix/wotlk-warlock-soulshard-item` | Re-verify first; old class matrix predates many item descriptor fixes. |
| P3 | `wotlk.md` | Paladin greater blessings report already learned | TC carryover | `fix/wotlk-greater-blessing-learn` | Re-verify first; likely spell-learn dedup translation. |
| P3 | `wotlk.md` | Shaman weapon imbues report already enchanted | TC carryover | `fix/wotlk-shaman-imbues` | Re-verify first; likely enchant item CMSG path. |
| P3 | `wotlk.md` | Holy Wrath / Holy Shock animate but have no damage/heal | TC carryover | `fix/wotlk-holy-spell-effects` | Re-verify first; suspect `SMSG_SPELL_GO` effect payload. |
| P3 | 2026-06-17 log | `CMSG_GUILD_SET_ACHIEVEMENT_TRACKING` is unhandled | 3.4.3 client | `fix/wotlk-guild-achievement-tracking` | Guild roster names are fixed; this is a separate guild-achievement tracking request. |
| P3 | 2026-06-17 log | `SMSG_LFG_UPDATE_SEARCH` is unhandled | AzerothCore | `fix/wotlk-lfg-update-search` | Appears while testing; track after the proposal/teleport path is verified. |
| P3 | 2026-06-17 log | `SMSG_INSTANCE_DIFFICULTY`, `SMSG_LOAD_EQUIPMENT_SET`, `SMSG_LEARNED_DANCE_MOVES` are still unhandled | AzerothCore | `fix/wotlk-misc-state-opcodes` | Already noted in `wotlk.md`; latest logs confirm they still occur. |
| P3 | 2026-06-17 log | `SMSG_CACHE_VERSION` is unhandled | AzerothCore | `fix/wotlk-cache-version` | Seen once at login in the latest logs; likely map to/replace modern cache-version flow or ignore deliberately after confirming layout. |
| P3 | 2026-06-17 log | Modern client account/store/service startup CMSGs are unhandled | 3.4.3 client | `fix/wotlk-modern-startup-cmsg-noops` | Latest log repeats BattlePay/VAS/undelete/pet journal/calendar/ticket/pvp/cemetery startup requests. Likely safe no-op handlers, but track explicitly. |
| P3 | 2026-06-17 log | Modern client telemetry/reporting CMSGs are unhandled | 3.4.3 client | `fix/wotlk-modern-telemetry-noops` | `CMSG_REPORT_CLIENT_VARIABLES`, `CMSG_REPORT_ENABLED_ADDONS`, and `CMSG_REPORT_KEYBINDING_EXECUTION_COUNTS` appear on logout/disconnect path; likely safe no-op handlers. |

## Upstream Issues To Track

These were open on `Xian55/HermesProxy` when reviewed.

| Issue | Title | Labels | WotLK relevance |
|---|---|---|---|
| [#107](https://github.com/Xian55/HermesProxy/issues/107) | `[3.4.3] BG party/raid members show Unknown + offline/Dead out of range (bot-filled BG)` | bug, ai, TrinityCore | High |
| [#106](https://github.com/Xian55/HermesProxy/issues/106) | `[3.4.3] BG scoreboard empty + no end-of-match popup (MSG_PVP_LOG_DATA dropped to MSG_NULL_ACTION)` | bug, ai, TrinityCore | High |
| [#105](https://github.com/Xian55/HermesProxy/issues/105) | `[3.4.3] Recurring disconnect: SMSG_SPELL_GO parse over-read during combat (3.3.5a)` | bug, ai, AzerothCore, TrinityCore | High |
| [#104](https://github.com/Xian55/HermesProxy/issues/104) | `[3.4.3 CMangos] Dungeon Finder not working - seems to pass-through` | bug, cmangos | High |
| [#103](https://github.com/Xian55/HermesProxy/issues/103) | `[3.4.3 AzerothCore] Solo queueing Dungeon Finder crashes proxy and roles are not working` | bug, AzerothCore | High |
| [#101](https://github.com/Xian55/HermesProxy/issues/101) | `[3.4.3] cMangos MOTransport crashes client` | bug, cmangos | High |
| [#96](https://github.com/Xian55/HermesProxy/issues/96) | `[3.4.3 AzerothCore] Transport (Zeppelins) cause client crash if filter is lifted` | bug, AzerothCore | High |
| [#90](https://github.com/Xian55/HermesProxy/issues/90) | Mage trainer wrong quote for non-mage | bug, good first issue | Low / general |
| [#84](https://github.com/Xian55/HermesProxy/issues/84) | Disconnect during BG closure | bug, Kronos | Medium / maybe related |
| [#74](https://github.com/Xian55/HermesProxy/issues/74) | 1.14.0 mob sideways movement when pulling | bug, Kronos | Low / non-WotLK |
| [#55](https://github.com/Xian55/HermesProxy/issues/55) | Banker gossip option | bug, good first issue, cmangos | Low / general |
| [#31](https://github.com/Xian55/HermesProxy/issues/31) | Auto loot + master loot shows wrong item in distribution popup | bug, ai | Medium / loot |
| [#28](https://github.com/Xian55/HermesProxy/issues/28) | Kicked out after login | bug, ai, cant repro | Low until reproduced |
| [#27](https://github.com/Xian55/HermesProxy/issues/27) | Character removed when jumping sideways while running | bug, ai, cant repro | Low until reproduced |
| [#26](https://github.com/Xian55/HermesProxy/issues/26) | Disconnect when entering a group | bug, ai, cant repro | Low until reproduced |
| [#19](https://github.com/Xian55/HermesProxy/issues/19) | Nefarian abilities show out of range | bug, ai, cant repro | Low until reproduced |
| [#18](https://github.com/Xian55/HermesProxy/issues/18) | Incorrect move speed after slow wears off | bug, cant repro | Low until reproduced |

## Repo-Documented General Issue

`docs/known-issues.md` currently documents one non-WotLK-specific known issue:

- Priest wand `Shoot` cancels in melee range on 1.14.x clients because `autoRangedCombat` defaults on. Workaround: `/console autoRangedCombat 0`. Tracked upstream as [#80](https://github.com/Xian55/HermesProxy/issues/80).

## Notes For Porting From The Old Fork

Before fixing a WotLK issue, check `docs/local-old-fork-comparison.md`. Several old-fork fixes are already covered by Xian55's branch, but the following old commits are still worth inspecting if symptoms overlap:

- `838ffcc` - convert legacy dismount packets.
- `098a338` - map pet power regen to modern slots.
- `13d6217` - defer opening spell until game object target.
- `be3edd4` - handle party join update requests.
