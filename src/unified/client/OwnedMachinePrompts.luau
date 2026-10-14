-- Single-bundle machine prompts, client-visible only after actual purchase.
-- The server independently enforces distance, ownership, and inventory.
local Players=game:GetService("Players")
local localPlayer=Players.LocalPlayer
local gameRoot=workspace:WaitForChild("SCRAPWORKS_GAME",40)
if not gameRoot then return end
local phase2=gameRoot:WaitForChild("SCRAPWORKS_PHASE2_ADDON",30)
local stations=phase2 and phase2:WaitForChild("MachineStations",30)
if not stations then warn("[Scrapworks] Machine stations missing");return end
for _,id in ipairs({"Compactor","Sorter","Smelter"}) do
    task.spawn(function()
        local station=stations:WaitForChild(id.."_Station",30)
        local interact=station and station:WaitForChild("MachineInteractor",30)
        local prompt=interact and interact:WaitForChild("ProcessScrap",30)
        if not prompt then warn("[Scrapworks] Missing prompt for ",id);return end
        local key="SW2_Own_"..id
        local function refresh()
            prompt.Enabled=(localPlayer:GetAttribute(key)==true)
        end
        localPlayer:GetAttributeChangedSignal(key):Connect(refresh)
        refresh()
    end)
end
