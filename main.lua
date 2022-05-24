local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ContextActionService = game:GetService("ContextActionService")

local Functions = ReplicatedStorage:WaitForChild("Functions")
local _Events = ReplicatedStorage:WaitForChild("Events")
local Events = {
    CreateForceFieldEvent = _Events.CreateForceFieldEvent;
}

local Player = Players.LocalPlayer;
local Mouse = Player:GetMouse()

local ToolLibrary = {} ToolLibrary.__index = ToolLibrary;
local RemoteFormat = ("Fire%sFunction")

local Backpack = Player.Backpack;
local Character = Player.Character or Player.CharacterAdded:Wait()

Player.CharacterAdded:Connect(function()
    Character = Player.Character or Player.CharacterAdded:Wait()
end)

function ToolLibrary.GetAnyTool(CheckBackpack)
    local Parachute = Backpack:FindFirstChild("Parachute")
    
    if Parachute then
        Parachute:Destroy()
    end
    
    local ToolCharacter = Character:FindFirstChildOfClass("Tool")
    local ToolBackpack = Backpack:FindFirstChildOfClass("Tool")
    
    return (ToolCharacter) or (CheckBackpack and ToolBackpack) or nil;
end

function ToolLibrary.GetTool(ToolName)
    local Tool = Backpack:FindFirstChild(ToolName) or Character:FindFirstChild(ToolName)
    local Remote = Functions:FindFirstChild(RemoteFormat:format(Tool.Name))
    
    if Tool and Remote then
        return setmetatable({
            Tool = Tool;
            Remote = Remote;
        }, ToolLibrary)
    end
    
    return false
end

function ToolLibrary:Fire(LookVector) self.Remote:InvokeServer(self.Tool, LookVector) return true end
function ToolLibrary:Equip(ArgCharacter) self.Tool.Parent = Character or ArgCharacter return true end

local function Main(Data)
    local GiveForceField = Data["ForceField"] or false
    local Disable = Data["Disable"] or false
    local CheckBackpack = Data["CheckBackpack"] or false
    
    if ContextActionService:GetBoundActionInfo("OnMouseClick") then
        ContextActionService:UnbindAction("OnMouseClick");
    end
    
    if not Disable then
        ContextActionService:BindAction("OnMouseClick",function()
            local ActualTool = ToolLibrary.GetAnyTool(CheckBackpack);
            
            if ActualTool then
                local Tool = ToolLibrary.GetTool(ActualTool.Name)
                    
                if GiveForceField then
                    Events.CreateForceFieldEvent:FireServer()
                end
                
                if Tool then
                    Tool:Equip();
                    Tool:Fire(Mouse.UnitRay.Direction)
                end
            end
        end, true, Enum.UserInputType.MouseButton1)
    end
end

return Main
