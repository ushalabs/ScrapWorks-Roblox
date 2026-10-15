-- Schema-versioned storage. Studio uses disposable state by default. Published games use DataStore.
-- IMPORTANT: This prototype does not implement cross-server session locking.
local RunService=game:GetService("RunService")
local DataStoreService=game:GetService("DataStoreService")
local Players=game:GetService("Players")
local root=script.Parent
local gameRoot=root.Parent
local Phase1=gameRoot:WaitForChild("SCRAPWORKS_PHASE1_ADDON")
local Phase2=gameRoot:WaitForChild("SCRAPWORKS_PHASE2_ADDON")
local Inventory=require(Phase1:WaitForChild("InventoryService"))
local Economy=require(Phase1:WaitForChild("EconomyService"))
local Production=require(root:WaitForChild("ProductionService"))
local Plots=require(gameRoot:WaitForChild("FactoryPlotsV1"):WaitForChild("FactoryPlotService"))
local VERSION=1
local SAVE_IN_STUDIO=false
local enabled=(not RunService:IsStudio()) or SAVE_IN_STUDIO
local store=enabled and DataStoreService:GetDataStore("Scrapworks_Profile_v1") or nil
local saveAllowed={}
local function key(p)return "player_"..p.UserId end
local function snapshot(p)
  local money=Economy.Init(p)
  return {schema=VERSION,cash=money.Value,raw=Inventory.Export(p),machines={
   Compactor=p:GetAttribute("SW2_Own_Compactor")==true,
   Sorter=p:GetAttribute("SW2_Own_Sorter")==true,
   Smelter=p:GetAttribute("SW2_Own_Smelter")==true},
   manufacturing=Production.Export(p),automation=Plots.Export(p),savedAt=os.time()}
end
local function load(p)
  p:SetAttribute("SW3_Loading",true)
  local deadline=os.clock()+20
  while p.Parent==Players and (not p:GetAttribute("SW1_Ready") or not p:GetAttribute("SW2_Ready") or not p:GetAttribute("SW3_Ready") or not p:GetAttribute("SW4_Ready")) and os.clock()<deadline do task.wait(.1) end
  if p.Parent~=Players then return end
  if not enabled then saveAllowed[p]=false;p:SetAttribute("SW3_Loading",false);return end
  local ok,data=pcall(function()return store:GetAsync(key(p))end)
  if not ok then
     warn("[Scrapworks] Profile LOAD failed for ",p.UserId, data,"; skipping saves to prevent data loss")
     saveAllowed[p]=false;p:SetAttribute("SW3_Loading",false);return
  end
  if type(data)=="table" and (data.schema==VERSION) then
     local cash=data.cash
     if type(cash)=="number" and cash==cash and cash>=0 then Economy.Init(p).Value=math.floor(math.min(cash,1e12)) end
     Inventory.Import(p,data.raw)
     if type(data.machines)=="table" then
       for _,id in ipairs({"Compactor","Sorter","Smelter"}) do p:SetAttribute("SW2_Own_"..id,data.machines[id]==true) end
     end
     Production.Import(p,data.manufacturing)
     if type(data.automation)=="table" then Plots.Import(p,data.automation) end
  elseif data~=nil then
     warn("[Scrapworks] Unknown profile schema, refusing to overwrite for ",p.UserId)
     saveAllowed[p]=false;p:SetAttribute("SW3_Loading",false);return
  end
  saveAllowed[p]=true
  p:SetAttribute("SW3_Loading",false)
end
local function save(p)
  if not enabled or not saveAllowed[p] then return end
  local data=snapshot(p)
  local ok,err=pcall(function()
    store:UpdateAsync(key(p),function(previous)
      if type(previous)=="table" and previous.schema~=VERSION then return nil end
      return data
    end)
  end)
  if not ok then warn("[Scrapworks] SAVE failure: ",p.UserId,err) end
end
Players.PlayerAdded:Connect(function(p)task.spawn(load,p)end)
for _,p in ipairs(Players:GetPlayers()) do task.spawn(load,p) end
-- Save before Phase1 and Phase3 release their in-memory data.
Players.PlayerRemoving:Connect(function(p)save(p);saveAllowed[p]=nil end)
if enabled then
 task.spawn(function()
   while task.wait(90) do
     for _,p in ipairs(Players:GetPlayers()) do save(p) end
   end
 end)
end
game:BindToClose(function()
 if not enabled then return end
 for _,p in ipairs(Players:GetPlayers()) do save(p) end
end)
print("[Scrapworks v0.5] DataStore:",enabled and "enabled" or "disabled in Studio")
