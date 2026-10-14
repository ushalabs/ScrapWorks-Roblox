-- Phase 3: single-root factory production, recipe authority, contract server.
local Players=game:GetService("Players")
local root=script.Parent
local world=root.Parent
assert(world.Name=="SCRAPWORKS_GAME","Phase3 requires unified model")
local phase1=world:WaitForChild("SCRAPWORKS_PHASE1_ADDON",30)
if not phase1 then error("Phase 1 inventory is required") end
local service=require(root:WaitForChild("ProductionService"))
service.Bind(phase1)
local remotes=Instance.new("Folder");remotes.Name="Remotes";remotes.Parent=root
local craft=Instance.new("RemoteEvent");craft.Name="Craft";craft.Parent=remotes
local deliver=Instance.new("RemoteEvent");deliver.Name="Deliver";deliver.Parent=remotes
local terminal=root:WaitForChild("ProductionTerminal"):WaitForChild("MainConsole")
local prompt=Instance.new("ProximityPrompt")
prompt.Name="ProductionAccess"
prompt.ActionText="Open Production"
prompt.ObjectText="FACTORY ASSEMBLY TERMINAL"
prompt.KeyboardKeyCode=Enum.KeyCode.E
prompt.MaxActivationDistance=12
prompt.HoldDuration=.25
prompt.RequiresLineOfSight=false
prompt.Parent=terminal
local last={}
local function setup(player)
    local deadline=os.clock()+20
    while player.Parent==Players and not player:GetAttribute("SW1_Ready") and os.clock()<deadline do task.wait(.1) end
    if player.Parent~=Players then return end
    service.Init(player)
    local pg=player:WaitForChild("PlayerGui",15)
    local template=root:FindFirstChild("ManufacturingUI")
    if pg and template and not pg:FindFirstChild("ManufacturingUI") then template:Clone().Parent=pg end
end
Players.PlayerAdded:Connect(function(p) task.spawn(setup,p) end)
for _,p in ipairs(Players:GetPlayers()) do task.spawn(setup,p) end
craft.OnServerEvent:Connect(function(player,id)
    local now=os.clock();if now-(last[player] or -100)<.3 then return end
    last[player]=now;service.Craft(player,id,terminal)
end)
deliver.OnServerEvent:Connect(function(player,id)
    local now=os.clock();if now-(last[player] or -100)<.3 then return end
    last[player]=now;service.Deliver(player,id,terminal)
end)
Players.PlayerRemoving:Connect(function(p) last[p]=nil;task.delay(2,function()service.Release(p)end) end)
print("[Scrapworks v0.5] Manufacturing initialized: plates, wire, motors, contracts")
