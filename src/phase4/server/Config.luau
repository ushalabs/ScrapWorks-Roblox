-- Scrapworks v0.6.0 / Phase 4 multiplayer plots and virtual production configuration
local C={}
C.MaxPlots=12
C.MaxStock=240
C.MaxMachineLevel=3
C.SlotUnlockPrices={0,450,1350}
C.LevelUpgradePrices={0,225,650}
C.SlotRecipeDefaults={"Plate","Wire","Motor"}
C.Recipes={
    Plate={Name="STEEL PLATES",Seconds=11,Raw={Steel=2},Goods={},Output="Plate"},
    Wire={Name="COPPER WIRE",Seconds=11,Raw={Copper=2},Goods={},Output="Wire"},
    Motor={Name="ELECTRIC MOTORS",Seconds=21,Raw={Circuit=1},Goods={Plate=1,Wire=1},Output="Motor"},
}
C.ProductionOrder={"Plate","Wire","Motor"}
C.RawTypes={"Steel","Aluminum","Copper","Battery","Circuit","Alloy"}
return C
