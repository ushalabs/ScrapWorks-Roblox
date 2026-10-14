-- Scrapworks Phase 2: independent additive upgrade, import exactly once.
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Root=script.Parent
local GameRoot=Root.Parent
if workspace:FindFirstChild("SCRAPWORKS_GAME")~=GameRoot then
    warn("[SW Phase2] Duplicate Phase2 add-on ignored. Remove extra copies from Workspace.")
    return
end
local phase1=GameRoot:WaitForChild("SCRAPWORKS_PHASE1_ADDON",20)
local phase0=GameRoot:WaitForChild("SCRAPWORKS_DEMO_V1",20)
if not phase1 or not phase0 then warn("[SW Phase2] Phase0 and Phase1 must be present before installing Phase2.");return end
local Config=require(Root:WaitForChild("Config"))
local Upgrade=require(Root:WaitForChild("MachineService"))
Upgrade.BindPhase1(phase1)
local remotes=Instance.new("Folder");remotes.Name="SW2_Remotes";remotes.Parent=Root
local purchaseRemote=Instance.new("RemoteEvent");purchaseRemote.Name="PurchaseMachine";purchaseRemote.Parent=remotes
local function setup(player)
    local limit=os.clock()+15
    while player.Parent==Players and not player:GetAttribute("SW1_Ready") and os.clock()<limit do task.wait(.15) end
    if player.Parent~=Players then return end
    Upgrade.Init(player)
    local pg=player:WaitForChild("PlayerGui",15)
    if not pg then return end
    if not pg:FindFirstChild("ScrapworksPhase2HUD") then
        local template=Root:FindFirstChild("ScrapworksPhase2HUD")
        if template then template:Clone().Parent=pg end
    end
    player:SetAttribute("SW2_Notice","Machine upgrades available in the UPGRADES menu!")
end
Players.PlayerAdded:Connect(function(player)task.spawn(setup,player)end)
Players.PlayerRemoving:Connect(Upgrade.Release)
for _,player in ipairs(Players:GetPlayers()) do task.spawn(setup,player) end
local lastRequest={}
purchaseRemote.OnServerEvent:Connect(function(player,id)
    local now=os.clock()
    if now-(lastRequest[player] or -100)<.35 then return end
    lastRequest[player]=now
    Upgrade.Purchase(player,id)
end)
Players.PlayerRemoving:Connect(function(p)lastRequest[p]=nil end)
local colors={Compactor=Color3.fromRGB(255,205,92),Sorter=Color3.fromRGB(83,241,229),Smelter=Color3.fromRGB(250,139,74)}
local stations=Root:WaitForChild("MachineStations")
local function makeSign(part,title,sub,color)
    local gui=Instance.new("SurfaceGui")
    gui.Name="MachineSign";gui.Face=Enum.NormalId.Back;gui.LightInfluence=0;gui.PixelsPerStud=45
    gui.Parent=part
    local f=Instance.new("Frame")
    f.BackgroundTransparency=1;f.Size=UDim2.fromScale(1,1);f.Parent=gui
    local l=Instance.new("TextLabel")
    l.BackgroundTransparency=1;l.Size=UDim2.fromScale(1,.58)
    l.Font=Enum.Font.GothamBlack;l.TextScaled=true;l.Text=title
    l.TextColor3=color;l.TextStrokeTransparency=.3;l.Parent=f
    local s=Instance.new("TextLabel")
    s.BackgroundTransparency=1;s.Position=UDim2.fromScale(0,.6);s.Size=UDim2.fromScale(1,.35)
    s.Font=Enum.Font.GothamBold;s.TextScaled=true;s.Text=sub
    s.TextColor3=Color3.fromRGB(240,249,252);s.Parent=f
end
for _,id in ipairs(Config.Order) do
    local info=Config.Machines[id]
    local machine=stations:FindFirstChild(id.."_Station")
    local interaction=machine and machine:FindFirstChild("MachineInteractor")
    if interaction then
        local screen=machine:FindFirstChild(id.."_Screen")
        if screen then makeSign(screen,info.Name,"+"..math.floor((info.Multiplier-1)*100+.5).."% VALUE  •  "..info.Minimum.." SCRAP",colors[id]) end
        local prompt=interaction:FindFirstChild("ProcessScrap") or Instance.new("ProximityPrompt")
        prompt.Name="ProcessScrap";prompt.ActionText="Process Scrap";prompt.ObjectText=info.Name
        prompt.KeyboardKeyCode=Enum.KeyCode.E;prompt.MaxActivationDistance=10
        prompt.HoldDuration=.4;prompt.RequiresLineOfSight=false;prompt.Parent=interaction
        prompt.Triggered:Connect(function(player)Upgrade.Process(player,id,interaction)end)
    else
        warn("[SW Phase2] Missing station:",id)
    end
end
print("[Scrapworks Unified] Machines initialized for factory game.")
