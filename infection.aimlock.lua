getgenv().AimPart = {"Head"} -- List of aim parts to cycle through
getgenv().AimlockToggleKey = "X" -- Toggles Aimbot On/Off 
getgenv().AimRadius = 50 -- How far away from someones character you want to lock on at
getgenv().FirstPerson = true -- Locking onto someone in your First Person POV
getgenv().TeamCheck = true -- Check if Target is on your Team (True means it wont lock onto your teamates, false is vice versa) (Set it to false if there are no teams)
getgenv().PredictMovement = true -- Predicts if they are moving in fast velocity (like jumping) so the aimbot will go a bit faster to match their speed 
getgenv().PredictionVelocity = 15 -- The speed of the PredictMovement feature 

local Players, Uis, RService, SGui = game:GetService"Players", game:GetService"UserInputService", game:GetService"RunService", game:GetService"StarterGui";
local Client, Mouse, Camera, CF, RNew, Vec3, Vec2 = Players.LocalPlayer, Players.LocalPlayer:GetMouse(), workspace.CurrentCamera, CFrame.new, Ray.new, Vector3.new, Vector2.new;
local Aimlock, MousePressed, CanNotify = true, false, false;
local AimlockTarget;
local CurrentAimPart = getgenv().AimPart[1] -- Initialize the current aim part
local NextAimPartCycle = tick() + math.random(1, 1) -- Time for the next aim part cycle

getgenv().CiazwareUniversalAimbotLoaded = true

getgenv().SeparateNotify = function(title, text, icon, time) 
    SGui:SetCore("SendNotification",{
        Title = title;
        Text = text;
        Duration = time;
    })
end

getgenv().Notify = function(title, text, icon, time)
    if CanNotify == true then 
        if not time or not type(time) == "number" then time = 3 end
        SGui:SetCore("SendNotification",{
            Title = title;
            Text = text;
            Duration = time;
        }) 
    end
end

getgenv().WorldToViewportPoint = function(P)
    return Camera:WorldToViewportPoint(P)
end

getgenv().WorldToScreenPoint = function(P)
    return Camera.WorldToScreenPoint(Camera, P)
end

getgenv().GetObscuringObjects = function(T)
    if T and T:FindFirstChild(CurrentAimPart) and Client and Client.Character:FindFirstChild("Head") then 
        local RayPos = workspace:FindPartOnRay(RNew(
            T[CurrentAimPart].Position, Client.Character.Head.Position)
        )
        if RayPos then return RayPos:IsDescendantOf(T) end
    end
end

getgenv().GetNearestTarget = function()
    -- Credits to whoever made this, i didnt make it, and my own mouse2plr function kinda sucks
    local players = {}
    local PLAYER_HOLD  = {}
    local DISTANCES = {}
    for i, v in pairs(Players:GetPlayers()) do
        if v ~= Client then
            table.insert(players, v)
        end
    end
    for i, v in pairs(players) do
        if v.Character ~= nil then
            local AIM = v.Character:FindFirstChild(CurrentAimPart)
            if getgenv().TeamCheck == true and v.Team ~= Client.Team then
                local DISTANCE = (v.Character:FindFirstChild(CurrentAimPart).Position - game.Workspace.CurrentCamera.CFrame.p).magnitude
                local RAY = Ray.new(game.Workspace.CurrentCamera.CFrame.p, (Mouse.Hit.p - game.Workspace.CurrentCamera.CFrame.p).unit * DISTANCE)
                local HIT,POS = game.Workspace:FindPartOnRay(RAY, game.Workspace)
                local DIFF = math.floor((POS - AIM.Position).magnitude)
                PLAYER_HOLD[v.Name.. i] = {}
                PLAYER_HOLD[v.Name.. i].dist= DISTANCE
                PLAYER_HOLD[v.Name.. i].plr = v
                PLAYER_HOLD[v.Name.. i].diff = DIFF
                table.insert(DISTANCES, DIFF)
            elseif getgenv().TeamCheck == false and v.Team == Client.Team then 
                local DISTANCE = (v.Character:FindFirstChild(CurrentAimPart).Position - game.Workspace.CurrentCamera.CFrame.p).magnitude
                local RAY = Ray.new(game.Workspace.CurrentCamera.CFrame.p, (Mouse.Hit.p - game.Workspace.CurrentCamera.CFrame.p).unit * DISTANCE)
                local HIT,POS = game.Workspace:FindPartOnRay(RAY, game.Workspace)
                local DIFF = math.floor((POS - AIM.Position).magnitude)
                PLAYER_HOLD[v.Name.. i] = {}
                PLAYER_HOLD[v.Name.. i].dist= DISTANCE
                PLAYER_HOLD[v.Name.. i].plr = v
                PLAYER_HOLD[v.Name.. i].diff = DIFF
                table.insert(DISTANCES, DIFF)
            end
        end
    end
    
    if unpack(DISTANCES) == nil then
        return nil
    end
    
    local L_DISTANCE = math.floor(math.min(unpack(DISTANCES)))
    if L_DISTANCE > getgenv().AimRadius then
        return nil
    end
    
    for i, v in pairs(PLAYER_HOLD) do
        if v.diff == L_DISTANCE then
            return v.plr
        end
    end
    return nil
end

RService.RenderStepped:Connect(function()
    if tick() > NextAimPartCycle then
        local Index = table.find(getgenv().AimPart, CurrentAimPart)
        if Index == #getgenv().AimPart then
            CurrentAimPart = getgenv().AimPart[1]
        else
            CurrentAimPart = getgenv().AimPart[Index + 1]
        end
        NextAimPartCycle = tick() + math.random(1, 1)
    end
    if getgenv().FirstPerson == true then 
        if 0 == 0 then 
            CanNotify = true 
        else 
            CanNotify = false
        end
    end
    if Aimlock == true and MousePressed == true then 
        if AimlockTarget and AimlockTarget.Character and AimlockTarget.Character:FindFirstChild(CurrentAimPart) then 
            if getgenv().FirstPerson == true then
                if CanNotify == true then
                    if getgenv().PredictMovement == true then 
                        Camera.CFrame = CF(Camera.CFrame.p, AimlockTarget.Character[CurrentAimPart].Position + AimlockTarget.Character[CurrentAimPart].Velocity/PredictionVelocity)
                    elseif getgenv().PredictMovement == false then 
                        Camera.CFrame = CF(Camera.CFrame.p, AimlockTarget.Character[CurrentAimPart].Position)
                    end
                end
            end
        end
    end
end)

Uis.InputBegan:Connect(function(Key)
    if not (Uis:GetFocusedTextBox()) then 
        if Key.UserInputType == Enum.UserInputType.MouseButton2 then 
            pcall(function()
                if MousePressed ~= true then MousePressed = true end 
                local Target;Target = GetNearestTarget()
                if Target ~= nil then 
                    AimlockTarget = Target
                    Notify("UwuGirlCrimHub", "Aimlock Target: "..tostring(AimlockTarget), "", 3)
                end
            end)
        end
        if Key.KeyCode == Enum.KeyCode[AimlockToggleKey] then 
            Aimlock = not Aimlock
            Notify("UwuGirlCrimHub", "Aimlock: "..tostring(Aimlock), "", 3)
        end
    end
end)
Uis.InputEnded:Connect(function(Key)
    if not (Uis:GetFocusedTextBox()) then 
        if Key.UserInputType == Enum.UserInputType.MouseButton2 then 
            if AimlockTarget ~= nil then AimlockTarget = nil end
            if MousePressed ~= false then 
                MousePressed = false 
            end
        end
    end
end)
