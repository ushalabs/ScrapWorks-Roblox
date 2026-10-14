# Runtime structure

Workspace
└── SCRAPWORKS_GAME
    ├── SCRAPWORKS_DEMO_V1 (environment, scrap nodes, refinery, spawn)
    ├── SCRAPWORKS_PHASE1_ADDON (freight yard, inventory/economy/refinery services, Phase1HUD)
    └── SCRAPWORKS_PHASE2_ADDON (machine stations, ownership/processing, Phase2HUD)

The phase-named children are internal modules for compatibility; the user installs/replaces only the outer SCRAPWORKS_GAME model. Phase 2.5 salvage meshes were moved directly under the owning scrap models and selected refinery details into the original refinery.

Never import an older Phase0–Phase2.5 model beside SCRAPWORKS_GAME; that would create duplicate scripts and scenes.
