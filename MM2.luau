-- Suppress console warnings
local warnings_suppressed = true
if warnings_suppressed then
	local _warn = warn
	warn = function() end
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local MarketplaceService = game:GetService("MarketplaceService")

local LocalPlayer = Players.LocalPlayer

LocalPlayer.Idled:Connect(function()
	pcall(function()
		VirtualUser:CaptureController()
		VirtualUser:ClickButton1(Vector2.new())
	end)
end)

-- Premium Check
local premium = false
pcall(function()
	if readfile and isfile then
		if isfile("Zyphrax Hub/MM2/premium.txt") then
			local premiumData = readfile("Zyphrax Hub/MM2/premium.txt")
			premium = premiumData:find(LocalPlayer.Name) ~= nil
		end
	end
end)

-- Loading Screen
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Load UI Library
local uiSource = nil
local okUi = pcall(function()
	uiSource = game:HttpGet("https://raw.githubusercontent.com/Moonshall/ZyphraxHub/refs/heads/main/mainui.lua")
end)

if not okUi or not uiSource then
	return
end
task.wait(0.1)

local ZyphraxHub = loadstring(uiSource)()
if not ZyphraxHub then
	return
end

local isMobile = table.find({ Enum.Platform.Android, Enum.Platform.IOS }, UserInputService:GetPlatform()) ~= nil
local windowSize = isMobile and UDim2.fromOffset(528, 334) or UDim2.fromOffset(620, 370)

local Window = ZyphraxHub:CreateWindow({
	Title = "ZyphraxHub",
	Icon = "rbxassetid://125623993645104",
	Author = premium and "Premium" or "MM2",
	Folder = nil,
	Size = windowSize,
	LiveSearchDropdown = true,
})

local InfoTab = nil
local MainTab = nil
local VisualTab = nil
local MiscTab = nil

pcall(function()
	InfoTab = Window:Tab({ Title = "Information", Icon = "info" })
	MainTab = Window:Tab({ Title = "Main", Icon = "landmark" })
	VisualTab = Window:Tab({ Title = "Visual", Icon = "eye" })
	MiscTab = Window:Tab({ Title = "Misc", Icon = "cog" })
end)

-- Flags
local flags = {
	killAll = false,
	autoShoot = false,
	autoTakeGun = false,
	autoFarmCoin = false,
	espRole = false,
	espGunDrop = false,
	fullBodyChams = false,
	fly = false,
	noclip = false,
}

-- Config
local cfg = {
	selectedPlayer = nil,
	speedHack = 16,
	jumpPower = 50,
	flySpeed = 25,
	coinSpeed = 25,
}

-- Player dropdown global
local playerDropdown = nil

-- Helper Functions
local function getRoot(character)
	if not character then return nil end
	return character:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid(character)
	if not character then return nil end
	return character:FindFirstChildOfClass("Humanoid")
end

local function notify(title, text)
	pcall(function()
		ZyphraxHub:Notify({
			Title = title,
			Content = text,
			Icon = "info",
			Duration = 3,
		})
	end)
end

local rolesCache = {}
local cachedPlayers = {}
local flyState = {
	velocity = nil,
	gyro = nil,
}
local coinFarmState = {
	tween = nil,
	target = nil,
	lastCollect = 0,
}

local function getRoles()
	local ok, data = pcall(function()
		local remote = ReplicatedStorage:FindFirstChild("GetPlayerData", true)
		if not remote then return nil end
		return remote:InvokeServer()
	end)
	if ok and data and type(data) == "table" then
		rolesCache = {}
		for plr, plrData in pairs(data) do
			if type(plrData) == "table" and not plrData.Dead then
				rolesCache[plr] = plrData.Role or "Innocent"
			end
		end
	end
	return rolesCache
end

local function getPlayerNames()
	local names = {}
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			if plr.Name and plr.Name ~= "" then
				table.insert(names, plr.Name)
			end
		end
	end
	return names
end

local function safeTeleport(targetCFrame, offset)
	if not targetCFrame then return end
	offset = offset or Vector3.new(0, 0, 0)
	local character = LocalPlayer.Character
	if not character then return end
	local rootPart = getRoot(character)
	if not rootPart then return end
	
	pcall(function()
		local newCFrame = targetCFrame + offset
		if character:FindFirstChild("Humanoid") then
			character:PivotTo(newCFrame)
		else
			rootPart.CFrame = newCFrame
		end
		task.wait(0.01)
	end)
end

local RoleColors = {
	Murderer = Color3.fromRGB(255, 0, 0),
	Sheriff = Color3.fromRGB(0, 0, 255),
	Innocent = Color3.fromRGB(0, 255, 0)
}

local espPool = {}

local function isBagFull()
	local backpack = LocalPlayer:FindFirstChild("Backpack")
	if not backpack then return false end
	
	local coinCount = 0
	local maxCoins = 40
	
	pcall(function()
		if MarketplaceService:UserOwnsAsset(LocalPlayer.UserId, 3878455) then
			maxCoins = 50
		end
	end)
	
	for _, item in pairs(backpack:GetChildren()) do
		if item.Name == "Coin" or item.Name:lower():find("coin") then
			coinCount = coinCount + 1
		end
	end
	
	return coinCount >= maxCoins
end

local function clearESP()
	for player in pairs(espPool) do
		local highlight = espPool[player]
		if highlight and highlight.Parent then
			pcall(function() highlight:Destroy() end)
		end
		espPool[player] = nil
	end
end

local function clearAllESPHighlights()
	for _, plr in pairs(Players:GetPlayers()) do
		if plr.Character then
			local hl = plr.Character:FindFirstChild("RoleHighlight")
			if hl then
				pcall(function() hl:Destroy() end)
			end
			local gunHl = plr.Character:FindFirstChild("GunHighlight")
			if gunHl then
				pcall(function() gunHl:Destroy() end)
			end
		end
	end
	
	local gunFolder = Workspace:FindFirstChild("Guns")
	if gunFolder then
		for _, gun in pairs(gunFolder:GetChildren()) do
			local hl = gun:FindFirstChild("GunHighlight")
			if hl then
				pcall(function() hl:Destroy() end)
			end
		end
	end
end

local function applyRoleESP()
	if not flags.espRole then return end
	
	pcall(function()
		local roles = getRoles()
		for _, plr in pairs(Players:GetPlayers()) do
			if plr ~= LocalPlayer and plr.Character then
				local role = roles[plr.Name] or "Innocent"
				if role == "Hero" then
					role = "Sheriff"
				end
				local color = RoleColors[role] or RoleColors.Innocent
				local head = plr.Character:FindFirstChild("Head")
				
				if head then
					local hl = plr.Character:FindFirstChild("RoleHighlight")
					if not hl then
						hl = Instance.new("Highlight")
						hl.Name = "RoleHighlight"
						hl.Parent = plr.Character
					end
					hl.FillColor = color
					hl.OutlineColor = Color3.new(1, 1, 1)
					hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
					hl.FillTransparency = 0.3
					hl.OutlineTransparency = 0
				end
			end
		end
	end)
end

local function getKnifeStabbedEvent()
	for _, obj in pairs(getnilinstances()) do
		if obj.Name == "KnifeStabbed" then
			return obj
		end
	end
	return nil
end

local function stopCoinFarmTween()
	if coinFarmState.tween then
		pcall(function()
			coinFarmState.tween:Cancel()
		end)
		coinFarmState.tween = nil
	end
	coinFarmState.target = nil
end

local function clearFlyForces()
	if flyState.velocity then
		pcall(function() flyState.velocity:Destroy() end)
		flyState.velocity = nil
	end
	if flyState.gyro then
		pcall(function() flyState.gyro:Destroy() end)
		flyState.gyro = nil
	end

	local character = LocalPlayer.Character
	if character then
		local humanoid = getHumanoid(character)
		if humanoid then
			humanoid.AutoRotate = true
		end
	end
end

local function ensureFlyForces(rootPart)
	if not flyState.velocity or flyState.velocity.Parent ~= rootPart then
		if flyState.velocity then
			pcall(function() flyState.velocity:Destroy() end)
		end
		local bv = Instance.new("BodyVelocity")
		bv.Name = "FlyVelocity"
		bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
		bv.P = 25000
		bv.Velocity = Vector3.new(0, 0, 0)
		bv.Parent = rootPart
		flyState.velocity = bv
	end

	if not flyState.gyro or flyState.gyro.Parent ~= rootPart then
		if flyState.gyro then
			pcall(function() flyState.gyro:Destroy() end)
		end
		local bg = Instance.new("BodyGyro")
		bg.Name = "FlyGyro"
		bg.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
		bg.P = 30000
		bg.CFrame = rootPart.CFrame
		bg.Parent = rootPart
		flyState.gyro = bg
	end
end

-- === INFORMATION TAB ===
if InfoTab then
	pcall(function()
		InfoTab:Section({ Title = "Information" })
		InfoTab:Paragraph({
			Title = "Murder Mystery 2",
			Desc = "Professional Exploit Script",
		})

		InfoTab:Section({ Title = "Community" })
		InfoTab:Button({
			Title = "Join Our Discord",
			Callback = function()
				if setclipboard then
					setclipboard("https://discord.gg/zyphraxhub")
					notify("Discord", "Link copied to clipboard")
				else
					notify("Clipboard", "setclipboard not available")
				end
			end,
		})
	end)
end

-- === MAIN TAB ===
if MainTab then
	pcall(function()
		MainTab:Section({ Title = "Murder" })
	end)
	pcall(function()
		MainTab:Toggle({
			Title = "Kill All",
			Callback = function(state)
				flags.killAll = state
				if state then notify("Kill All", "Enabled") else notify("Kill All", "Disabled") end
			end,
		})
	end)
	pcall(function()
		local initialPlayers = getPlayerNames()
		local dropdownOptions = initialPlayers
		if #dropdownOptions == 0 then
			dropdownOptions = {"No Players"}
		end
		
		playerDropdown = MainTab:Dropdown({
			Title = "Select Player",
			Options = dropdownOptions,
			Default = "No Players",
			Callback = function(selected)
				if type(selected) == "table" then
					selected = selected[1] or nil
				end
				if selected and selected ~= "No Players" and selected ~= "" then
					cfg.selectedPlayer = selected
				else
					cfg.selectedPlayer = nil
				end
			end,
		})
	end)
	pcall(function()
		MainTab:Button({
			Title = "Kill Selected",
			Callback = function()
				if cfg.selectedPlayer then
					local targetPlr = Players:FindFirstChild(cfg.selectedPlayer)
					if targetPlr and targetPlr ~= LocalPlayer and targetPlr.Character then
						pcall(function()
							local targetRoot = getRoot(targetPlr.Character)
							local targetHumanoid = getHumanoid(targetPlr.Character)
							if targetRoot and targetHumanoid then
								safeTeleport(targetRoot.CFrame)
								task.wait(0.1)
								ReplicatedStorage.Remotes.Gameplay.MeleeHit:FireServer(targetHumanoid)
								notify("Kill", "Selected player eliminated")
							end
						end)
					end
				end
			end,
		})
	end)

	pcall(function()
		MainTab:Section({ Title = "Sheriff" })
	end)
	pcall(function()
		MainTab:Toggle({
			Title = "Auto Shoot (Murder)",
			Callback = function(state)
				flags.autoShoot = state
				if state then notify("Auto Shoot", "Enabled") else notify("Auto Shoot", "Disabled") end
			end,
		})
	end)
	pcall(function()
		MainTab:Toggle({
			Title = "Auto Take Gun",
			Callback = function(state)
				flags.autoTakeGun = state
			end,
		})
	end)

	pcall(function()
		MainTab:Section({ Title = "Farm" })
	end)
	pcall(function()
		MainTab:Toggle({
			Title = "Auto Farm Coin",
			Callback = function(state)
				flags.autoFarmCoin = state
				if not state then
					stopCoinFarmTween()
				end
			end,
		})
	end)
	pcall(function()
		MainTab:Slider({
			Title = "Coin Speed",
			Step = 1,
			Value = { Min = 1, Max = 100, Default = 25 },
			Callback = function(value)
				cfg.coinSpeed = value
			end,
		})
	end)
end

-- Player dropdown update function
local function updatePlayerDropdown()
	if not playerDropdown then return end
	
	local names = getPlayerNames()
	local options = #names > 0 and names or {"No Players"}
	
	pcall(function()
		playerDropdown:Set(options)
	end)
end

Players.PlayerAdded:Connect(function()
	task.wait(0.2)
	updatePlayerDropdown()
end)

Players.PlayerRemoving:Connect(function()
	task.wait(0.1)
	updatePlayerDropdown()
end)

task.delay(0.5, function()
	updatePlayerDropdown()
end)

-- === VISUAL TAB ===
if VisualTab then
	pcall(function()
		VisualTab:Section({ Title = "ESP" })
		VisualTab:Toggle({
			Title = "ESP Role",
			Callback = function(state)
				flags.espRole = state
				if not state then clearESP() end
			end,
		})

		VisualTab:Toggle({
			Title = "ESP Gun Drop",
			Callback = function(state)
				flags.espGunDrop = state
				if not state then
					pcall(function()
						local gunFolder = Workspace:FindFirstChild("Guns")
						if gunFolder then
							for _, gun in pairs(gunFolder:GetChildren()) do
								local gunParent = gun:IsA("BasePart") and gun or gun
								local hl = gunParent:FindFirstChild("GunHighlight")
								if hl then
									hl:Destroy()
								end
							end
						end
					end)
				end
			end,
		})
	end)
end

-- === MISC TAB ===
if MiscTab then
	pcall(function()
		MiscTab:Section({ Title = "Movement" })
		MiscTab:Slider({
			Title = "Speed",
			Step = 1,
			Value = { Min = 1, Max = 100, Default = 16 },
			Callback = function(value)
				cfg.speedHack = value
				local humanoid = getHumanoid(LocalPlayer.Character)
				if humanoid then humanoid.WalkSpeed = value end
			end,
		})

		MiscTab:Slider({
			Title = "Jump Power",
			Step = 1,
			Value = { Min = 1, Max = 250, Default = 50 },
			Callback = function(value)
				cfg.jumpPower = value
				local humanoid = getHumanoid(LocalPlayer.Character)
				if humanoid then humanoid.JumpPower = value end
			end,
		})

		MiscTab:Slider({
			Title = "Fly Speed",
			Step = 1,
			Value = { Min = 5, Max = 200, Default = 25 },
			Callback = function(value)
				cfg.flySpeed = value
			end,
		})

		MiscTab:Toggle({
			Title = "Fly",
			Callback = function(state)
				flags.fly = state
				if not state then
					clearFlyForces()
				end
			end,
		})

		MiscTab:Toggle({
			Title = "Noclip",
			Callback = function(state)
				flags.noclip = state
			end,
		})

		MiscTab:Section({ Title = "Teleport" })
		MiscTab:Button({
			Title = "Teleport to Murder",
			Callback = function()
				pcall(function()
					local roles = getRoles()
					for plr, role in pairs(roles) do
						if role == "Murderer" then
							local targetPlr = Players:FindFirstChild(plr)
							if targetPlr and targetPlr.Character then
								local targetRoot = getRoot(targetPlr.Character)
								if targetRoot then
									safeTeleport(targetRoot.CFrame, Vector3.new(5, 0, 0))
									break
								end
							end
						end
					end
				end)
			end,
		})

		MiscTab:Button({
			Title = "Teleport to Sheriff",
			Callback = function()
				pcall(function()
					local roles = getRoles()
					for plr, role in pairs(roles) do
						if role == "Sheriff" or role == "Hero" then
							local targetPlr = Players:FindFirstChild(plr)
							if targetPlr and targetPlr.Character then
								local targetRoot = getRoot(targetPlr.Character)
								if targetRoot then
									safeTeleport(targetRoot.CFrame, Vector3.new(5, 0, 0))
									break
								end
							end
						end
					end
				end)
			end,
		})

		MiscTab:Button({
			Title = "Teleport to Gun Drop",
			Callback = function()
				pcall(function()
					local gunFolder = Workspace:FindFirstChild("Guns")
					if gunFolder then
						local nearest = nil
						local minDist = math.huge
						local myRoot = getRoot(LocalPlayer.Character)
						if myRoot then
							for _, gun in pairs(gunFolder:GetChildren()) do
								local gunPart = gun:FindFirstChild("Handle") or (gun:IsA("BasePart") and gun)
								if gunPart then
									local dist = (myRoot.Position - gunPart.Position).Magnitude
									if dist < minDist then
										minDist = dist
										nearest = gunPart
									end
								end
							end
							if nearest then
								safeTeleport(nearest.CFrame, Vector3.new(5, 0, 0))
							end
						end
					end
				end)
			end,
		})

		MiscTab:Button({
			Title = "Teleport to Lobby",
			Callback = function()
				pcall(function()
					local lobby = Workspace:FindFirstChild("Lobby", true)
					if lobby then
						local part = lobby:FindFirstChildWhichIsA("BasePart", true)
						if part then
							safeTeleport(part.CFrame, Vector3.new(0, 3, 0))
						end
					end
				end)
			end,
		})
	end)
end

-- === FINALIZE UI ===
if Window then
	pcall(function() Window:SelectTab(1) end)
end

local function resetAllFlags()
	flags.killAll = false
	flags.autoShoot = false
	flags.autoTakeGun = false
	flags.autoFarmCoin = false
	flags.espRole = false
	flags.espGunDrop = false
	flags.fullBodyChams = false
	flags.fly = false
	flags.noclip = false
end

resetAllFlags()
clearAllESPHighlights()

-- === FEATURE LOOPS ===
RunService.Heartbeat:Connect(function()
	if flags.killAll then
		pcall(function()
			for _, plr in pairs(Players:GetPlayers()) do
				if plr ~= LocalPlayer and plr.Character then
					local targetRoot = getRoot(plr.Character)
					local targetHumanoid = getHumanoid(plr.Character)
					if targetRoot and targetHumanoid and targetHumanoid.Health > 0 then
						safeTeleport(targetRoot.CFrame)
						task.wait(0.15)
						local knifeEvent = getKnifeStabbedEvent()
						if knifeEvent then
							pcall(function() knifeEvent:FireServer() end)
						end
					end
				end
			end
		end)
	end

	if flags.autoShoot then
		pcall(function()
			local roles = getRoles()
			for plr, role in pairs(roles) do
				if role == "Murderer" then
					local targetPlr = Players:FindFirstChild(plr)
					if targetPlr and targetPlr.Character then
						local targetRoot = getRoot(targetPlr.Character)
						if targetRoot then
							safeTeleport(targetRoot.CFrame)
							task.wait(0.15)
							local knifeEvent = getKnifeStabbedEvent()
							if knifeEvent then
								pcall(function() knifeEvent:FireServer() end)
							end
						end
					end
					break
				end
			end
		end)
	end

	if flags.autoTakeGun then
		pcall(function()
			local gunFolder = Workspace:FindFirstChild("Guns")
			if gunFolder then
				local myChar = LocalPlayer.Character
				if myChar then
					local myRoot = getRoot(myChar)
					if myRoot then
						for _, gun in pairs(gunFolder:GetChildren()) do
							local gunPart = gun:FindFirstChild("Handle") or (gun:IsA("BasePart") and gun)
							if gunPart and gunPart.Parent then
								local dist = (myRoot.Position - gunPart.Position).Magnitude
								if dist < 150 then
									safeTeleport(gunPart.CFrame, Vector3.new(0, 1, 0))
									task.wait(0.1)
									pcall(function()
										ReplicatedStorage.Remotes.Gameplay.GiveWeapon:FireServer("Gun")
									end)
								end
							end
						end
					end
				end
			end
		end)
	end

	if flags.autoFarmCoin then
		pcall(function()
			if isBagFull() then
				flags.autoFarmCoin = false
				stopCoinFarmTween()
				notify("Auto Farm Coin", "Inventory full, farming stopped")
				return
			end
			
			local coinFolder = Workspace:FindFirstChild("Coins") or Workspace:FindFirstChild("DroppedCoin")
			if coinFolder and LocalPlayer.Character then
				local myRoot = getRoot(LocalPlayer.Character)
				if myRoot then
					for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
						if part:IsA("BasePart") then
							part.CanCollide = false
						end
					end
					
					local nearest = nil
					local minDist = math.huge
					for _, coin in pairs(coinFolder:GetChildren()) do
						if coin:IsA("BasePart") then
							if coin.Parent then
								local dist = (myRoot.Position - coin.Position).Magnitude
								if dist < minDist then
									minDist = dist
									nearest = coin
								end
							end
						elseif coin:FindFirstChild("HumanoidRootPart") then
							local coinPart = coin.HumanoidRootPart
							if coinPart.Parent then
								local dist = (myRoot.Position - coinPart.Position).Magnitude
								if dist < minDist then
									minDist = dist
									nearest = coinPart
								end
							end
						end
					end
					
					if nearest and nearest.Parent then
						if minDist <= 5 then
							stopCoinFarmTween()
							if (tick() - coinFarmState.lastCollect) > 0.1 then
								coinFarmState.lastCollect = tick()
								pcall(function()
									ReplicatedStorage.Remotes.Gameplay.CoinCollected:FireServer("Coin", 1, 50, { Value = 1 })
								end)
							end
						else
							local shouldRetarget = (coinFarmState.target ~= nearest) or (not coinFarmState.tween)
							
							if coinFarmState.tween and not shouldRetarget then
								local state = coinFarmState.tween.PlaybackState
								if state == Enum.PlaybackState.Completed or state == Enum.PlaybackState.Cancelled then
									shouldRetarget = true
								end
							end

							if shouldRetarget then
								stopCoinFarmTween()
								coinFarmState.target = nearest
								
								local targetPos = nearest.Position + Vector3.new(0, 3, 0)
								local targetCFrame = CFrame.new(targetPos)
								
								local tweenDuration = math.clamp(minDist / math.max(cfg.coinSpeed, 5), 0.1, 2)
								local tweenInfo = TweenInfo.new(tweenDuration, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
								
								coinFarmState.tween = TweenService:Create(myRoot, tweenInfo, { CFrame = targetCFrame })
								pcall(function()
									coinFarmState.tween:Play()
								end)
							end
						end
					else
						stopCoinFarmTween()
					end
				end
			end
		end)
	end

	if flags.espRole then
		applyRoleESP()
	end

	if flags.espGunDrop then
		pcall(function()
			local gunFolder = Workspace:FindFirstChild("Guns")
			if gunFolder then
				for _, gun in pairs(gunFolder:GetChildren()) do
					if gun:IsA("BasePart") or gun:FindFirstChild("Handle") then
						local gunParent = gun
						if not gun:IsA("BasePart") then
							gunParent = gun:FindFirstChild("Handle") or gun
						end
						local hl = gunParent and gunParent:FindFirstChild("GunHighlight")
						if gunParent and gunParent.Parent and not hl then
							hl = Instance.new("Highlight")
							hl.Name = "GunHighlight"
							hl.FillColor = Color3.fromRGB(255, 200, 0)
							hl.OutlineColor = Color3.fromRGB(200, 160, 0)
							hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
							hl.FillTransparency = 0.4
							hl.OutlineTransparency = 0
							pcall(function() hl.Parent = gunParent end)
						end
					end
				end
			end
		end)
	end

	if flags.fly then
		if LocalPlayer.Character then
			local myRoot = getRoot(LocalPlayer.Character)
			local humanoid = getHumanoid(LocalPlayer.Character)
			if myRoot and humanoid then
				ensureFlyForces(myRoot)
				humanoid.AutoRotate = false
				pcall(function()
					humanoid:ChangeState(Enum.HumanoidStateType.Physics)
				end)

				local camera = Workspace.CurrentCamera
				local moveDirection = humanoid.MoveDirection
				local worldMove = camera.CFrame:VectorToWorldSpace(moveDirection)
				local vertical = 0
				if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
					vertical = vertical + 1
				end
				if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
					vertical = vertical - 1
				end

				if flyState.velocity then
					local desiredVelocity = (worldMove * cfg.flySpeed) + Vector3.new(0, vertical * cfg.flySpeed, 0)
					if desiredVelocity.Magnitude < 0.05 then
						desiredVelocity = Vector3.new(0, 0, 0)
					end
					flyState.velocity.Velocity = desiredVelocity
				end

				if flyState.gyro then
					flyState.gyro.CFrame = camera.CFrame
				end
			end
		end
	else
		clearFlyForces()
	end

	if flags.noclip then
		if LocalPlayer.Character then
			for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = false
				end
			end
		end
	end
end)

LocalPlayer.CharacterAdded:Connect(function(newCharacter)
	task.wait(0.2)
	clearFlyForces()
	stopCoinFarmTween()
	local humanoid = getHumanoid(newCharacter)
	if humanoid then
		humanoid.WalkSpeed = cfg.speedHack
		humanoid.JumpPower = cfg.jumpPower
	end
end)

notify("ZyphraxHub MM2", "Script loaded successfully!")
