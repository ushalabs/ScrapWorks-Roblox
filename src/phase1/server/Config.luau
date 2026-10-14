-- Phase 1 / central economy and progression tuning
local Config = {}
Config.BagCapacity = 12
Config.ScrapRespawnSeconds = 9
Config.RefineryProcessingSeconds = 2.4
Config.CollectionRange = 12
Config.RefineryRange = 16
Config.MaterialOrder = {"Steel", "Aluminum", "Copper", "Battery", "Circuit", "Alloy"}
Config.Materials = {
    Steel = {Price = 15, Display = "STEEL"},
    Aluminum = {Price = 20, Display = "ALUMINUM"},
    Copper = {Price = 25, Display = "COPPER"},
    Battery = {Price = 32, Display = "BATTERY"},
    Circuit = {Price = 40, Display = "CIRCUIT"},
    Alloy = {Price = 55, Display = "ALLOY"},
}
return Config
