# Scrapworks v0.4.0 — Unified Workspace Model

**Migration:** The previous releases comprised four independent Workspace models; they caused physical/layout conflicts. This revision packages a single authoritative `SCRAPWORKS_GAME` model which contains the original functional submodules as internal children, with cross-service references updated accordingly.

## Install (in Roblox Studio, NOT alongside old models)

1. Save your existing place to a separate `.rbxl` backup.
2. Stop Play.
3. Under `Workspace`, DELETE the four previous Scrapworks imports: `SCRAPWORKS_DEMO_V1`, `SCRAPWORKS_PHASE1_ADDON`, `SCRAPWORKS_PHASE2_ADDON`, and `SCRAPWORKS_PHASE25_VISUALS` (and any duplicate/Phase2.6 imports). **Do not remove default Roblox services.**
4. `Workspace` → **Insert from File** → `Scrapworks_v0.4.0_Unified.rbxmx`.
5. Confirm Workspace has exactly ONE top-level custom Scrapworks model: `SCRAPWORKS_GAME`.
6. Ensure any leftover default Baseplate spawn location does not override the game's intended spawn.
7. Click **Play** to test scrap collection, 12-item inventory, refinery selling, machine unlocking, and processing.

Do not install future releases on top of this version. Future releases should **replace** `SCRAPWORKS_GAME` after backing up the `.rbxl` place.

## Key changes

- Single root model; nested Phase0/Phase1/Phase2 sections retained for maintainability.
- Removed the detached/elevated opaque canopy and giant shelves that blocked navigation and scrap collection.
- Repositioned 15 Phase1 collectible nodes inside open lanes; all part coordinates are baked into the model file, including newer visual scrap models.
- Incorporated six material-specific scrap appearances directly into the collectible models; no duplicate separate SalvageVisuals system.
- Added machine guard geometry with **CanCollide=true** inside each machine.
- Machine `E` prompts are controlled locally based on that player's ownership attributes, while processing validation remains on the server.
- Player-leave cleanup no longer references an undefined `throttle` variable.
- Kept the original refinery and three machine sale multipliers, shop costs, inventory logic and Cash values.
- Added limited refinery detailing inside the original refinery model, and retained only the prior visual UI styler.
- No saving/data migration yet; Cash and ownership still session-only.

## Actual testing status

Validated **offline**: XML parses, unique instance referents, collection node position boundaries, game-root script dependencies, and presence of ownership-check logic. **Roblox Studio runtime and multiplayer tests have NOT been executed** here.

## Required real-world smoke test

- Press Play in new / cleaned place, check spawn in the yard not under a model.
- Press E to collect multiple materials, sell at the refinery for nonzero Cash.
- Before unlock, confirm each of three processing machines has no usable `E` prompt.
- Buy Compactor for $200 and confirm the prompt appears within 10 studs for owner; sell >=3 scrap at Compactor.
- Confirm Sorter and Smelter remain locked.
- Check all scrap is visible and reachable, machine panels have collision, and no large roof covers salvage ground.
- Test in 2-player Studio server when feasible to confirm prompt gating and inventory isolation.

## Phase 3 direction

Next substantial phase is an integrated **manufacturing vertical slice**: raw scrap → refined inputs → assembled goods → contract payout with virtual server-authoritative production, then persistent saving and player-specific state. No more isolated cash-multiplier machines.
