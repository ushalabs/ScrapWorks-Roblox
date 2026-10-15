-- v0.6.0: single-root factory plot allocation, authoritative automated production.
local Players=game:GetService("Players")
local gameRoot=script.Parent.Parent
assert(gameRoot.Name=="SCRAPWORKS_GAME","v0.6 requires the single unified model")
local root=script.Parent
local plots=require(root:WaitForChild("FactoryPlotService"))
plots.Bind(gameRoot:WaitForChild("SCRAPWORKS_PHASE1_ADDON"),gameRoot:WaitForChild("ManufacturingV1"))
local actions=Instance.new("RemoteEvent")
actions.Name="FactoryAction";actions.Parent=root
local last={}
local function setup(player)
    local timeout=os.clock()+25
    while player.Parent==Players and not player:GetAttribute("SW3_Ready") and os.clock()<timeout do task.wait(.15) end
    if player.Parent~=Players then return end
    plots.Init(player)
    local pg=player:WaitForChild("PlayerGui",15)
    local template=root:FindFirstChild("FactoryPlotUI")
    if pg and template and not pg:FindFirstChild("FactoryPlotUI") then template:Clone().Parent=pg end
    local cosmetic=root:FindFirstChild("FactoryVisuals")
    if pg and cosmetic and not pg:FindFirstChild("FactoryVisuals") then cosmetic:Clone().Parent=pg end
end
Players.PlayerAdded:Connect(function(p)task.spawn(setup,p)end)
for _,p in ipairs(Players:GetPlayers()) do task.spawn(setup,p) end
actions.OnServerEvent:Connect(function(p,action,index,recipe)
    if type(action)~="string" or #action>24 then return end
    local now=os.clock()
    if now-(last[p] or -100)<.16 then return end
    last[p]=now
    if action=="deposit" then plots.Deposit(p)
    elseif action=="buy" then plots.BuySlot(p,index)
    elseif action=="upgrade" then plots.UpgradeSlot(p,index)
    elseif action=="recipe" then plots.SetRecipe(p,index,recipe)
    elseif action=="visit" then plots.Teleport(p,"Plot")
    elseif action=="return" then plots.Teleport(p,"Yard")
    end
end)
Players.PlayerRemoving:Connect(function(p)
    last[p]=nil
    -- Let Phase3Persistence take its snapshot before releasing factory data.
    task.delay(5,function()plots.Release(p)end)
end)
task.spawn(function()
    while task.wait(.6) do plots.Tick() end
end)
print("[Scrapworks v0.6] 12 factory plots allocated, virtual production enabled")
