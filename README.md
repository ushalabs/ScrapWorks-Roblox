# Scrapworks v0.5.0 — Manufacturing vertical slice

Built directly from GitHub `ushalabs/ScrapWorks-Roblox` commit `84c152a1e5890f368cd1b7905a7db6f8cf585477` (file hash verified). **Replace the entire existing `SCRAPWORKS_GAME` root with the new single model. Do not import it as an add-on.**

## Installation
1. Stop Studio Play mode and save a `.rbxl` backup.
2. In Workspace, delete **only** the old `SCRAPWORKS_GAME` model.
3. Right-click Workspace → Insert from File → `models/Scrapworks_v0.5.0_Manufacturing.rbxmx`.
4. Check one top-level `SCRAPWORKS_GAME` root exists. Press Play.
5. Collect scrap. The old 12-cap inventory, refinery selling and Compactor/Sorter/Smelter upgrades still work.
6. Locate the new manufacturing console on the original-yard floor around X=28, Z=25. Move close and use the **PRODUCTION** HUD button to select recipes; click **CONTRACTS** in the same menu to deliver finished goods.
7. Manufacture at least two Steel Plates (2 Steel each), one Copper Wire (2 Copper), then fulfill Building Supply ($240). For Motors produce 1 Plate, 1 Wire, and collect 1 Circuit; assemble a Motor (12 sec) and deliver for $450.

## Gameplay changes
- Removes 144 unnecessary ScrapPad/PadInset/PadSafetyBolt pieces from 24 pickup models.
- Lowers all visible scrap parts to sit directly on the existing yard surfaces; preserves invisible interaction Core for collecting.
- Adds a compact physical manufacturing console in a previously open part of the main yard.
- Adds server-verified timed manufacture of Steel Plate, Copper Wire and Electric Motor.
- Adds three server-verified product-delivery contracts and payouts ($240, $185, $450).
- Client UI displays recipes, resources, goods, countdown and contract deliveries. The legacy refinery remains available.
- InventoryService gains strict, non-yielding recipe consumption; new production goods are tracked per player.
- DataStore profile includes Cash, raw scrap, owned machines, produced goods and pending job. Studio saving disabled to avoid unintentional test writes; published saving is enabled, but requires further multi-server safeguards before public release.

## Required gameplay smoke checks
- Scrap appears on the FLOOR without black boards and collects/respawns correctly.
- No duplicate yards, existing machines/upgrade buttons still function, prompts remain gated by purchase.
- Manufacturing console is visible and accessible without blocking pathways.
- Start Plate job while near terminal: consume 2 Steel, complete after ~6 seconds, +1 Plate.
- Start Wire job: consume 2 Copper, complete after ~6 seconds, +1 Wire.
- Start Motor job: consume 1 Circuit + 1 Plate + 1 Wire, complete after ~12 seconds, +1 Motor.
- Fulfill Electrical Order with 2 Wires → +$185. Fulfill Motor Delivery with Motor → +$450.
- Moving far away from the console should block craft/deliver requests, even if the UI remains open.
- Cash/machines continue operating normally. Test 2-client inventories separately.
- Studio Output has no new errors. Studio data resets between Play sessions by design.

## Status and caveats
XML structural checks are performed offline; Roblox Studio runtime has NOT been executed by GPT. DataStore saving is intentionally off in Studio and has not been integration-tested. Production-grade cross-server profile locks and failure recovery should be added before publishing to real players. Gameplay production is numerical/server-authoritative; there is no server-physics conveyor simulation.

## Versioned development workflow
GitHub `models/Scrapworks_v0.5.0_Manufacturing.rbxmx` is the sole playable model for this release. Update the repository `README.md`, source mirror, and model together after Studio approval. Do not copy these sources into Studio separately; scripts are already embedded in the model.
