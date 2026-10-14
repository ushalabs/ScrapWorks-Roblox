# Scrapworks — Modular Roblox Factory Simulator

A phase-by-phase Roblox Studio project built around collectible scrap, material processing, factory upgrades, and a stylized industrial environment.

**Status:** playable technical prototype; Phase 2 validated in a Studio session by the project owner. Phase 2.5 visual add-on requires Studio testing. All purchases and Cash are **session-only** until a later persistence phase.

## Play / install from Roblox Studio

1. Create a new **Baseplate** experience in Roblox Studio.
2. Import the models below **under Workspace**, one at a time, in this order:
   1. `models/Scrapworks_Demo_v1.rbxmx`
   2. `models/Scrapworks_Phase1_Upgrade.rbxmx`
   3. `models/Scrapworks_Phase2_MachineUpgrade.rbxmx`
   4. `models/Scrapworks_Phase2_5_VisualOverhaul.rbxmx` (visual styling update, optional)
3. Preserve all earlier models; do not remove them when adding new phases.
4. Verify the model names `SCRAPWORKS_DEMO_V1`, `SCRAPWORKS_PHASE1_ADDON`, `SCRAPWORKS_PHASE2_ADDON`, and `SCRAPWORKS_PHASE25_VISUALS` (if installed).
5. Press Play to collect, process scrap, purchase machines, and refine at upgraded stations.

These are Roblox **model** files, not whole `.rbxl` places. They rely on being installed together in the same place as described above.

## Repository layout

- `src/phase0/`: original proof-of-concept Luau sources.
- `src/phase1/`: six-material economy, inventory, and refinery sources.
- `src/phase2/`: processing machine purchases and shop sources.
- `src/phase2_5/`: visual add-on bootstrap and UI styler.
- `models/`: original importable `.rbxmx` artifacts for each phase.
- `docs/`: architecture, installation, release notes, and testing.
- `scripts/`: source extraction/verification helpers.

The Luau files are extracted directly from the corresponding `.rbxmx` sources. Do **not** directly paste all of these in `ServerScriptService` as a new duplicate runtime—these modules are already embedded in the importable models.

## Architecture and updates

Phase 1 disables the original Phase 0 gameplay controller and replaces it with modular server modules. Phase 2 adds machine transactions using Phase 1's inventory and economy services. Phase 2.5 adds cosmetic geometry and reskins the live HUD **without replacing the original purchase or processing code**.

This repo is a source mirror and release archive. A future Rojo workflow can make `.luau` source authoritative if desired. For now, use the bundled `.rbxmx` models for playing the game.

## Testing and caveats

- Phase 0: player verified collection of five scrap and sale for $120.
- Phase 1: player verified mixed-material collection and a 12-item sale for $387.
- Phase 2: player reported the upgrade running and supplied a Play-mode screenshot. Detailed tests for every machine purchase/processor are not independently logged.
- Phase 2.5: structurally validated as XML and model hierarchy only; **not yet run in Roblox Studio**.
- All progression is session-only. There are no live Robux transactions or cloud persistence yet.
- Roblox does not guarantee imported models are safe; inspect third-party resources if importing additional Creator Store content. This code was generated as part of the project.

See `docs/RELEASE_NOTES.md` and `docs/TESTING.md`.
