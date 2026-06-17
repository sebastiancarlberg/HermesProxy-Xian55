# Local Old Fork Comparison

This note compares the older local `HermesProxy-WOTLK-fork` work against the current Xian55 WotLK branch. It is a triage aid, not proof that a behavior is correct until tested in game.

## Summary

The Xian55 `feature/wotlk-classic-v3.4.3` branch already covers many problems we fixed independently in the old fork, but the implementations are not identical. A `git patch-id --stable` check found no exact patch matches for our old verified commits because Xian55 has refactored heavily into packet-handler modules, descriptor-driven update fields, newer hotfix data, and source-generated tables.

## Old Fixes Already Covered Or Superseded

| Old fork fix | Old commit | Xian55 status |
| --- | --- | --- |
| Forward legacy negative aura/debuff flags | `7ffa949` | Covered by `dc61b8f fix: forward Negative aura flag to modern client` and later aura refactors. |
| Modern unit/update-field alignment | `c0c8004` | Broadly superseded by Xian55's V3_4_3 object update builder work, descriptor fields, and later ActivePlayerData fixes. |
| Explored zones in ActivePlayerData | `8440f95`, later local work | Covered by `704ca8a feat(v3_4_3) load ExploredZones into update` and descriptor writes. |
| Container and bag slot value updates | `4a54625`, `053e1f4` | Covered by `d107f70 fix(v3_4_3): wire Container Values updates so bag UI tracks slot moves` and later slot-preservation work. |
| Quest log visibility / owner typed updates | `e07b8d5` | Covered by `f2c3876 feat(v3_4_3): emit owner-typed PlayerData.QuestLog in Create + Update`. |
| Quest completion NPC response opcode/query | `584c70d` and local setup checks | Present in Xian55 V3_4_3 opcode table and quest handler path. |
| Profession skill lines from legacy skills | `4b36916` | Xian55 has `ActivePlayerData.ProfessionSkillLine` descriptor/update writes. Verify runtime population before assuming parity. |
| LFG/Dungeon Finder work | current old local branch | Xian55 has `LFGHandler.cs`, feature-system-status wiring, blacklist handling, and docs marking end-to-end LFG. |
| Inscription/item icon fix | `28ddb89` | Superseded by broader hotfix/item appearance/glyph pipelines. The old override CSV is not present and should not be ported blindly. |

## Old Fixes Worth Inspecting Before Porting

- `838ffcc Convert legacy dismount packets`: Xian55 has dismount opcodes but the quick grep did not show an obvious V3_4_3 handler equivalent. Test mount/dismount behavior first, then compare old packet translation if needed.
- `098a338 Map pet power regen to modern slots`: Xian55 has `UnitData.ModPowerRegen` descriptors. Verify pet power regen in-game before porting old slot mapping.
- `13d6217 Defer opening spell until game object target`: Xian55 has many game object, quest item, and spell-click fixes. Re-test the old repro before considering a port.
- `be3edd4 Handle party join update requests`: Xian55 has `CMSG_REQUEST_PARTY_JOIN_UPDATES` in generic opcode enums, but the quick grep did not show an obvious V3_4_3 handler. Check party/join UI behavior and packet logs.

## Xian55 Work Missing From The Old Fork

- Auction House 3.4.3 fixes.
- Achievement bridge.
- Heirloom collection panel and tooltip fixes.
- Pet spellbook, pet talents, and pet action encoding.
- Vehicle action button, seat change, active mover, and spell-click translation.
- Death Knight rune/runic-power support.
- Battleground queue/list/port/status work.
- More complete DB2/hotfix data and generated hotfix emitters.
- Descriptor/source-generator based object update serialization.
- Modern logging, metrics, packet-handler organization, tests, and benchmark/perf work.

## Suggested Porting Rule

Default to Xian55's implementation as the new baseline. Only port old fork code when a current runtime test proves a regression or missing behavior in this branch, and then port the smallest concept rather than copying old files wholesale.
