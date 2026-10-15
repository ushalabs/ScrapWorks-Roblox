# Scrapworks v0.6.0 — Factory Plots and Virtual Automation

**Source baseline:** `ushalabs/ScrapWorks-Roblox` commit `dd28a3a` (Phase 3). The model in this package is a complete **replacement** for the previous single `SCRAPWORKS_GAME` model, not an add-on.

## Roblox Studio install

1. Stop Play and save a separate `.rbxl` backup.
2. Under Workspace delete ONLY the prior `SCRAPWORKS_GAME` model.
3. Import `models/Scrapworks_v0.6.0_FactoryPlots.rbxmx` under Workspace.
4. Verify **exactly one** `SCRAPWORKS_GAME` exists.
5. Play; use **MY FACTORY** at the bottom right. Visit your plot, collect scrap, and deposit it at the factory console area using the UI.
6. The first auto-machine starts with the Steel Plate recipe. Two further machine slots unlock for $450 and $1,350. Slots can change recipes or increase production speed.
7. The shared production terminal, Phase 3 contracts, old refinery, Cash and upgrades remain in the project.

## Runtime design

- Each player is allocated one of 12 fixed factory plots for the current server session; plot allocation is not permanent between different server sessions.
- The factory hopper stores up to 240 raw materials per player, separate from the backpack's 12-item limit.
- Server-side virtual machinery consumes material from the hopper and credits real Plate/Wire/Motor stock to Phase 3's `ProductionService` (no server-simulated conveyor items).
- Production continues only while the player is online and their server has input materials.
- In Studio, persistence remains disabled; in a published test place, Phase 3 DataStore saves version-1 profiles including the **optional `automation` section**. Existing v1 saves without it still load.
- This is still an early prototype: no cross-server session locking and no performance profiling in Roblox Studio yet. Do not publish for public monetized use until saving and multiplayer tests are completed.

## Source files

- `src/phase4/server/`: FactoryPlotService, Config, and Phase4Bootstrap.
- `src/phase4/client/`: factory management UI and local-only machine glows.
- `src/phase3/server/`: minimal additive patches to ProductionService and Phase3Persistence for Phase 4 integration.
- `models/`: fully updated single-game import file.

**Do not duplicate the extracted `.luau` files as additional active scripts.** These sources mirror the scripts embedded in the Roblox model.
