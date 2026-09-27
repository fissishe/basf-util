local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local function CloneReference(Reference: any)
	local Success, Result = pcall(function()
		return cloneref(Reference)
	end)

	if Success and Result then
		if Result == Reference then
			warn("Your copied reference must be different not same reference to avoid weak-table detection.")
		end

		return Result
	else
		if Result == nil then
			warn("Your executor is absolute scam. Please use another executor")
		end
	end

	return Reference
end


local Util = {
	Build = {},
	Plot = {},
	Misc = {},
	Friend = {},
	Data = {},

	Instances = {
		Friends = CloneReference(ReplicatedStorage:WaitForChild("Friend")) :: Folder,
		Plots = CloneReference(ReplicatedStorage:WaitForChild("Plot")) :: Folder,

		Active = CloneReference(workspace:WaitForChild("Active")) :: Folder,
		Projections = CloneReference(workspace:WaitForChild("Projection")) :: Folder,
		Map = CloneReference(workspace:WaitForChild("Map")) :: Model,

		Post = CloneReference(ReplicatedStorage:WaitForChild("Post")) :: RemoteEvent,
		Get = CloneReference(ReplicatedStorage:WaitForChild("Get")) :: RemoteFunction,
	}
}
table.freeze(Util.Instances)

local LocalPlayer: Player = CloneReference(Players.LocalPlayer)


-- Build

function Util.Build.CreateHologram(Block: string, Position: Vector3?): PVInstance?
	return Util.Instances.Get:InvokeServer("Projection", Block, Position or Vector3.new(0, 64, 0))
end


function Util.Build.Clear(): ()
	Util.Instances.Post:FireServer("Clear")
end

function Util.Build.Destroy(Object: Instance): ()
	Util.Instances.Post:FireServer("Destroy", Object)
end

function Util.Build.Place(
		Block: string, 
		Position: CFrame, 

		Attach: Instance?, 
		Offset: CFrame? , 

		Collision: boolean?, 
		Anchored: boolean?, 

		Color: Color3?, 
		Data: any?
	): PVInstance?
	return Util.Instances.Get:InvokeServer(
		"Place",
		Block,
		Position,

		Attach,
		Offset,

		Collision,
		Anchored,

		Color,
		Data
	)
end


function Util.Build.GetActiveBuilding(Player: Player?): Folder?
	Player = Player or LocalPlayer

	for _, Child in ipairs(Util.Instances.Active:GetChildren()) do
		if Child:IsA("Folder") then
			if Child.Name == Player.Name then 
				return Child
			end
		end
	end

	return nil
end

function Util.Build.GetBlocks(Player: Player?): { PVInstance }
	Player = Player or LocalPlayer

	local List = {}

	local Building = Util.Build.GetActiveBuilding(Player)

	if Building then
		for _, Child in ipairs(Building:GetChildren()) do
			if Util.Build.IsABlock(Child) then
				table.insert(List, Child)
			end
		end
	end

	return List
end

function Util.Build.IsABlock(Object: Instance, Local: boolean?): boolean
	Local = if typeof(Local) == "boolean" then Local else false

	local Building = Util.Build.GetActiveBuilding()

	if Building then
		if Object:IsA("PVInstance") then
			if Local and Object:IsDescendantOf(Building) then
				return true
			elseif not Local and Object:IsDescendantOf(Util.Instances.Active) then
				return true
			end
		end
	end

	return false
end

function Util.Build.IsHologram(Object: Instance): boolean
	if Object:IsA("PVInstance") and Object:IsDescendantOf(Util.Instances.Projections) then
		return true
	end

	return false
end


function Util.Build.GetBlockOwnership(Block: PVInstance): Player?
	if Util.Build.IsABlock(Block) then
		local Building = Block:FindFirstAncestorOfClass("Folder")

		if Building then
			local Player = Players:FindFirstChild(Building.Name)

			if Player and Player:IsA("Player") then
				return Player
			end
		end
	end

	return nil
end


function Util.Build.Paint(Block: PVInstance, Color: Color3): ()
	Util.Instances.Post:FireServer("Paint", Block, Color)
end


-- Plot

function Util.Plot.Claim(Plot: number): ()
	Util.Misc.Execute(
		("Claim %f"):format(Plot)
	)
end

function Util.Plot.Unclaim(): ()
	Util.Plot.Claim(1.1)
end


function Util.Plot.GetOwnerList(): { { Plot: number, Owner: Player? } }
	local List = {}

	for _, Child in ipairs(Util.Instances.Plots:GetChildren()) do
		local Name = Child.Name

		if Child:IsA("StringValue") then
			local Value = Child.Value
			local Player = Players:FindFirstChild(Value)

			table.insert(List, {
				Plot = tonumber(Name),
				Owner = Player,
			})
		end
	end

	return List
end

function Util.Plot.GetOwnerFromNumber(Plot: number): Player?
	for _, Item in ipairs(Util.Plot.GetOwnerList()) do
		if Item.Plot == Plot then
			return Item.Owner
		end
	end

	return nil
end


function Util.Plot.IsAPlot(Object: Instance): boolean
	if Object:IsA("BasePart") and Object:IsDescendantOf(Util.Instances.Map) then
		local Board = Object:FindFirstChild("Board")

		if Board and Board:IsA("BillboardGui") then
			return true
		end
	end

	return false
end

function Util.Plot.GetPlots(): { BasePart }
	local List = {}

	for _, Child in ipairs(Util.Instances.Map:GetChildren()) do
		if Util.Plot.IsAPlot(Child) then
			table.insert(List, Child)
		end
	end

	return List
end

function Util.Plot.GetPlotFromNumber(Plot: number): PVInstance?
	local Plots = Util.Plot.GetPlots()

	for _, Child in ipairs(Plots) do
		local Name = Child.Name

		if tonumber(Name) and tonumber(Name) == Plot then
			return Child
		end
	end

	return nil
end


-- Friend

function Util.Friend.Trust(Player: Player): ()
	if Player == LocalPlayer then
		warn("You cannot add trust yourself.")

		return
	end

	Util.Instances.Post:FireServer("AddFriend", Player)
end

function Util.Friend.Untrust(Player: Player): ()
	if Player == LocalPlayer then
		warn("You cannot remove trust yourself.")

		return
	end

	Util.Instances.Post:FireServer("RemoveFriend", Player)
end

function Util.Friend.GetTrustListFromPlayer(Player: Player?): { string }
	Player = Player or LocalPlayer

	local Container = CloneReference(Util.Instances.Friends:FindFirstChild(Player.Name))

	if Container then
		local List = {}

		for _, Child in ipairs(Container:GetChildren()) do
			if Child:IsA("StringValue") then
				local Name = Child.Name

				if not table.find(List, Name) then
					table.insert(List, Name)
				end
			end
		end

		return List
	end

	return {}
end

function Util.Friend.IsPlayerTrusted(Owner: Player?, Player: Player): boolean
	local List = Util.Friend.GetTrustListFromPlayer(Owner or LocalPlayer)

	if table.find(List, Player.Name) then
		return true
	end

	return false
end


-- Data

function Util.Data.GetBuildingSize(Percentage: boolean?): number
	Percentage = if typeof(Percentage) == "boolean" then Percentage else true

	local Size = Util.Instances.Get:InvokeServer("Size")

	if Percentage then
		return math.ceil(Size / 3900000 * 100)
	end

	return Size
end

function Util.Data.RenameBuildingSave(Slot: number, Name: string?): ()
	Slot = math.max(math.round(Slot), 1)
	Name = Name or ("Slot %f"):format(Slot)

	Util.Instances.Post:FireServer("Slot", Slot, Name)
end

function Util.Data.SaveBuilding(Slot: number): string
	Slot = math.max(math.round(Slot), 1)

	return Util.Instances.Get:InvokeServer("Save", Slot)
end

function Util.Data.LoadBuilding(Slot: number, Clear: boolean?): string
	Slot = math.max(math.round(Slot), 1)
	Clear = if typeof(Clear) == "boolean" then Clear else true

	if Clear then
		Util.Build.Clear()
	end

	return Util.Instances.Get:InvokeServer("Load", Slot)
end

-- Misc

function Util.Misc.Execute(Command: string): ()
	Util.Instances.Post:FireServer("Command", Command)
end


function Util.Misc.IsPlayerOnPVP(Player: Player?): boolean
	Player = Player or LocalPlayer

	local Character = CloneReference(Player.Character)

	if Character then
		local Shield = Character:FindFirstChild("PVPShield")

		if Shield and Shield:IsA("BillboardGui") then
			return false
		end
	end

	return true
end

function Util.Misc.TogglePVP(Enabled: boolean?): ()
	Enabled = if typeof(Enabled) == "boolean" then Enabled else not Util.Misc.IsPlayerOnPVP(LocalPlayer)

	Util.Instances.Post:FireServer("UpdatePVP", Enabled)
end


return Util
