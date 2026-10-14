-- Scrapworks Phase 2: purchases and processor throughput. Prices are in session Cash.
local Config = {}
Config.Order = {"Compactor", "Sorter", "Smelter"}
Config.Machines = {
    Compactor = {Name="HYDRAULIC COMPACTOR", Cost=200, Multiplier=1.20, Minimum=3, Description="Press scrap into dense bundles", Tier=1},
    Sorter = {Name="OPTICAL SORTER", Cost=650, Multiplier=1.35, Minimum=5, Description="Sort and recover extra value", Tier=2},
    Smelter = {Name="INDUCTION SMELTER", Cost=1600, Multiplier=1.60, Minimum=8, Description="Refine scrap into high-value ingots", Tier=3},
}
return Config
