-- Client-only cosmetic factory glow animation. Never changes inventories or hitboxes.
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local player=Players.LocalPlayer
local plotRoot=workspace:WaitForChild("SCRAPWORKS_GAME"):WaitForChild("FactoryPlotsV1")
local folder=plotRoot:WaitForChild("FactoryPlots")
local t=0
RunService.RenderStepped:Connect(function(dt)
    t+=dt
    local character=player.Character
    local pivot=character and character:FindFirstChild("HumanoidRootPart")
    if not pivot then return end
    for _,plot in ipairs(folder:GetChildren()) do
        local arrival=plot:FindFirstChild("Arrival")
        if arrival and (pivot.Position-arrival.Position).Magnitude<160 then
            local id=plot:GetAttribute("OwnerUserId") or 0
            local owner=id~=0 and Players:GetPlayerByUserId(id) or nil
            for i=1,3 do
                local glow=plot:FindFirstChild("MachineGlow"..i)
                if glow then
                    local on=owner and owner:GetAttribute("SW4_Slot"..i.."Owned")==true
                    glow.Transparency=on and (.19+.12*math.sin(t*2.8+i)) or .78
                end
            end
        end
    end
end)
