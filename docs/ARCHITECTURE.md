# Scrapworks runtime architecture

`SCRAPWORKS_DEMO_V1` owns the initial scrapyard, refinery, and scrap nodes.

`SCRAPWORKS_PHASE1_ADDON` owns Config, InventoryService, EconomyService, ScrapCollectionService, RefineryService, Phase1Bootstrap, and ScrapworksPhase1HUD. It disables the Phase 0 controller and binds collection prompts to both original and Phase 1 nodes.

`SCRAPWORKS_PHASE2_ADDON` owns MachineStations, Config, MachineService, Phase2Bootstrap, and ScrapworksPhase2HUD. It uses the Phase 1 inventory and economy modules (it does not fork the cash balances). Purchases are validated on the server.

`SCRAPWORKS_PHASE25_VISUALS` owns additive 3D refinements, cosmetic scrap models, machine-bay lighting, Phase25VisualBootstrap, and ScrapworksPhase25Styling. It tracks the existing Phase 1 prompt Enabled flag to show/hide enhanced salvage objects and restyles the working client HUD in-place. It contains no economy or purchase remotes.

## Known development concerns

The Phase 2 `MachineService.Release` has an unbound `throttle` reference in the original source, which may produce a warning/error during PlayerRemoving. It does not affect the earlier owner-reported collection and sell test. A targeted code patch is advisable in a future maintenance pass; this visual add-on deliberately does not rewrite gameplay scripts.

Datastore persistence, multiple-client load testing, and commercial-monetization validation have not been performed.
