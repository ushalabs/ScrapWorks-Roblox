# Production architecture

`SCRAPWORKS_GAME/ManufacturingV1` owns the production station, Config, ProductionService, Phase3Bootstrap, Phase3Persistence, and ManufacturingUI template. Existing Phase1 inventory/economy and Phase2 machine purchase systems are reused. The model is replaced as a whole each phase, but source modules remain separated internally.

Gameplay: Server validates request range (within 20 studs), ingredients, owned goods, current job status, and transaction. Raw ingredients consumed atomically. Production completes based on server Unix timestamps and grants goods once. Contracts consume goods before rewarding Cash. Client only renders UI/state.

Persistence: versioned `Scrapworks_Profile_v1`; Studio disabled, public servers enabled. Profile saves need cross-server session locking before a true public launch. No premium purchases.
