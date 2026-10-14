-- Phase 3 manufacturing and contract configuration: all rewards server validated.
local C={}
C.Outputs={"Plate","Wire","Motor"}
C.OutputNames={Plate="Steel Plate",Wire="Copper Wire",Motor="Electric Motor"}
C.Recipes={
    Plate={Name="PRESS STEEL PLATE",Raw={Steel=2},Goods={},Output="Plate",Amount=1,Seconds=6},
    Wire={Name="DRAW COPPER WIRE",Raw={Copper=2},Goods={},Output="Wire",Amount=1,Seconds=6},
    Motor={Name="ASSEMBLE ELECTRIC MOTOR",Raw={Circuit=1},Goods={Plate=1,Wire=1},Output="Motor",Amount=1,Seconds=12},
}
C.RecipeOrder={"Plate","Wire","Motor"}
C.Contracts={
    Framework={Name="BUILDING SUPPLY",Goods={Plate=2,Wire=1},Reward=240},
    CircuitRun={Name="ELECTRICAL ORDER",Goods={Wire=2},Reward=185},
    MotorOrder={Name="MOTOR DELIVERY",Goods={Motor=1},Reward=450},
}
C.ContractOrder={"Framework","CircuitRun","MotorOrder"}
return C
