-- @ CordeliusVox Mouse module | Version 1.5 | 9/11/2024
--!nonstrict

local Mouse = {}
Mouse.__index = Mouse

--// Services
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

--// Settings
local Debug = true; -- Debug mode, Prints out debug messages to the console. (Does not affect errors)

local ScreenGui_Name = "Mouselock" -- Change this for a custom name for the screengui of FreeMouse function.

--// Types
type Mouse = {
	Player: Player,
	PlayerGui: PlayerGui,
	Mouse: Instance,
	IconID: string,
	ScreenFreeName: string,
	Locked: boolean,
	IsFree: boolean,
	MouseLockConnection: RBXScriptConnection?,
	PreviousLockedState: boolean,
	Connections: {RBXScriptConnection}
}

-- Debug initialization check
local function Init()
	local StartTime = os.clock()

	local Success, Error = pcall(function()
		-- Check if essential services and settings are available
		assert(UserInputService, "Mouse Controller Error: UserInputService is missing.")
		assert(Players, "Mouse Controller Error: Players service is missing.")
		assert(ScreenGui_Name ~= "", "Mouse Controller Error: ScreenGui_Name is not set.")

		local Player = Players.LocalPlayer
		assert(Player and Player:FindFirstChild("PlayerGui"), "Mouse Controller Error: PlayerGui not found.")

		-- Check basic module structure
		assert(Mouse.new and typeof(Mouse.new) == "function", "Mouse Controller Error: Mouse.new function is missing.")
	end)
	
	-- Calculate load time and print result
	local LoadTime = math.floor((os.clock() - StartTime) * 1000) -- Convert to milliseconds
	
	if Success then
		print("Mouse Controller loaded successfully! [" .. LoadTime .. "ms]")
	else
		warn("Mouse Controller failed to load: " .. tostring(Error) .. " [" .. LoadTime .. "ms]")
	end
end

function Mouse.new(Player: Player): Mouse
	assert(Player and Player:IsA("Player"), "Mouse Controller Error: Invalid Player parameter.")

	local self = setmetatable({} :: any, Mouse) :: Mouse

	self.Player = Player or Players.LocalPlayer
	self.PlayerGui = Player:WaitForChild("PlayerGui")
	self.Mouse = Player:GetMouse()

	--// Mouse Settings [DO NOT CHANGE!]
	self.IconID = self.Mouse.Icon

	self.Locked = false
	self.IsFree = false
	-------------------

	self.MouseLockConnection = nil
	self.PreviousLockedState = false
	self.Connections = {}
	
	if Debug then
		Init()
	end

	return self
end

--[[
	Safely disconnects all active connections, ensuring that no lingering references remain.
	This helps prevent memory leaks and ensures proper cleanup.
]]--
function Mouse:Release(): ()
	if self.Connections then
		for _, Connection in pairs(self.Connections) do
			if Connection and Connection.Disconnect then
				Connection:Disconnect()
			end
		end
		
		self.Connections = nil
	end
end

--[[
	Sets a custom image for the mouse icon.

	<strong>ID</strong> accepts either a numeric asset ID or a string in the format "rbxassetid://ID". 
	Automatically formats the ID to "rbxassetid://" if a plain number is provided.
]]--
function Mouse:SetIcon(ID: number | string): ()
	assert(ID, "Mouse Controller Error: Icon ID can not be nil.")

	if typeof(ID) == "number" then
		ID = "rbxassetid://" .. ID
	elseif typeof(ID) == "string" then
		-- Ensure the string starts with "rbxassetid://"
		if not ID:match("^rbxassetid://") then
			ID = "rbxassetid://" .. ID
		end
	else
		if Debug then
			warn("Mouse Controller Warning: ID must be a number or valid string. (rbxassetid://)")
			return
		else
			return
		end
	end

	self.Mouse.Icon = ID
	self.IconID = ID
end

--[[
	Locks the mouse to the center of the screen, preventing free movement. 
]]--
function Mouse:LockCenter()
	if self.Locked then
		if Debug then
			warn("Mouse Controller Warning: Attempt to Lock Center while already Locked.")
			return
		else
			return
		end
	end

	self.Locked = true
	UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter

	self.MouseLockConnection = UserInputService.InputChanged:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseMovement then
			if UserInputService.MouseBehavior ~= Enum.MouseBehavior.LockCenter then
				UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
			end
		elseif Input.UserInputType == Enum.UserInputType.MouseWheel then
			if UserInputService.MouseBehavior ~= Enum.MouseBehavior.LockCenter then
				UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
			end
		end
	end)

	table.insert(self.Connections, self.MouseLockConnection)
end


--[[
	Releases the mouse from the center lock, allowing free movement across the screen.
]]--
function Mouse:UnlockCenter(): ()
	if not self.Locked then 
		if Debug then
			warn("Mouse Controller Warning: Attempt to Unlock Center while already Unlocked.")
			return 
		else 
			return
		end
	end
	
	self.Locked = false

	if self.MouseLockConnection then
		self.MouseLockConnection:Disconnect()
		self.MouseLockConnection = nil
	end

	UserInputService.MouseBehavior = Enum.MouseBehavior.Default
end

--[[
	Toggles the mouse center lock on or off, switching between fixed and free cursor movement modes.
]]--
function Mouse:ToggleLockCenter(): ()
	if self.Locked then
		self:UnlockCenter()
	else
		self:LockCenter()
	end
end

--[[
	Hides the current mouse icon, making it invisible on the screen.
]]--
function Mouse:HideMouseIcon(): ()
	if not UserInputService.MouseIconEnabled then
		if Debug then
			warn("Mouse Controller Warning: Attempt to hide mouse icon while already hidden.")
			return
		else
			return
		end
	end

	-- Store current icon ID only if the icon is visible and needs to be hidden
	if self.Mouse.Icon ~= "" and self.IconID ~= self.Mouse.Icon then
		self.IconID = self.Mouse.Icon
	end

	-- Hide the mouse icon
	UserInputService.MouseIconEnabled = false
end

--[[
	Displays the mouse icon if it is currently hidden, making it visible on the screen.
]]--
function Mouse:ShowMouseIcon(): ()
	if UserInputService.MouseIconEnabled then
		if Debug then
			warn("Mouse Controller Warning: Attempt to show mouse icon while already shown.")
			return
		else
			return
		end
	end
	
	-- Set mouse icon to stored icon ID
	if self.IconID then
		self.Mouse.Icon = self.IconID
	end
	
	-- SHow the mouse icon
	UserInputService.MouseIconEnabled = true
end

--[[
	Returns the current screen position of the mouse cursor as X and Y coordinates.
]]--
function Mouse:GetPosition(): (number?, number?)
	if not self.Mouse then
		if Debug then
			warn("Mouse Controller Warning: No mouse found.")
			return nil, nil
		else
			return nil, nil
		end
	else
		return self.Mouse.X, self.Mouse.Y
	end
end

--[[
	Releases control of the mouse from being locked at the center of the screen.
	Works best in FirstPerson.

	This function creates a transparent ScreenGui with a modal TextButton that captures mouse input, 
	allowing free movement of the cursor without restrictions.

	If the mouse was previously locked, it will be unlocked before proceeding with the process.
]]--
function Mouse:FreeMouse(): ()
	if self.IsFree then
		if Debug then
			warn("Mouse Controller Warning: Attempt to Free Mouse while already Free.")
			return
		else
			return
		end
	end
	
	if not self.PlayerGui:FindFirstChild(ScreenGui_Name) then
		if self.Locked then
			self:UnlockCenter()  -- Call the UnlockCenter method to free the mouse from center locking.
			self.PreviousLockedState = self.Locked  -- Store the previous state for potential later restoration.
		end

		local Screen = Instance.new("ScreenGui")
		Screen.Name = ScreenGui_Name
		Screen.IgnoreGuiInset = true  -- Ignore the GUI inset for consistent sizing
		Screen.ResetOnSpawn = false  -- Prevent resetting when the player respawns

		local Button = Instance.new("TextButton")
		Button.Size = UDim2.new(1, 0, 1, 0)
		Button.Modal = true
		Button.Text = ""
		Button.BackgroundTransparency = 1
		Button.TextTransparency = 1
		Button.Parent = Screen

		-- Parent the ScreenGui to the PlayerGui to make it visible
		Screen.Parent = self.PlayerGui

		self.IsFree = true
	end
end

--[[
	Restores control of the mouse by removing the modal ScreenGui that enables free cursor movement.

	The function checks for the existence of the ScreenGui, removes it if found, and reverts the mouse to its previous lock state, if applicable.
]]--
function Mouse:UnFreeMouse(): ()
	local Gui = self.PlayerGui:FindFirstChild(ScreenGui_Name)

	-- If the ScreenGui is found, proceed with cleanup
	if Gui then
		Gui:Destroy()
		self.IsFree = false

		-- If the mouse was previously locked, restore the lock state
		if self.PreviousLockedState then
			self:LockCenter()  -- Call the LockCenter method to re-lock the mouse to the center
		end
	else
		if Debug then
			warn("Mouse Controller Warning: Attempt to unfree the mouse while it was not free.")
		end
	end
end

--[[
	Returns the current state of the mouse lock (locked or unlocked).
]]--
function Mouse:IsLocked(): (boolean)
	return self.Locked
end

--[[
	Returns the current state of the mouse icon (hidden or visible).
]]--
function Mouse:IsIconVisible(): (boolean)
	return UserInputService.MouseIconEnabled
end

--[[
	Returns the current ID of the mouse icon.
]]--
function Mouse:GetIconID(): ()
	return self.IconID
end

--// Init the module
local _Instance = Mouse.new(game.Players.LocalPlayer)
setmetatable(Mouse, { __index = _Instance })

return Mouse
