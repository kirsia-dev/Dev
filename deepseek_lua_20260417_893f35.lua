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
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

LocalPlayer.Idled:Connect(function()
	pcall(function()
		VirtualUser:CaptureController()
		VirtualUser:ClickButton1(Vector2.new())
	end)
end)

local premium = false
pcall(function()
	if type(LRM_IsUserPremium) == "boolean" then
		premium = LRM_IsUserPremium
		return
	end
	if readfile and isfile and isfile("Zyphrax Hub/MM2/premium.txt") then
		local premiumData = readfile("Zyphrax Hub/MM2/premium.txt")
		premium = premiumData:find(LocalPlayer.Name) ~= nil
	end
end)

local uiSource = nil
local okUi = pcall(function()
	uiSource = game:HttpGet("https://raw.githubusercontent.com/Moonshall/ZyphraxHub/refs/heads/main/mainui.lua")
end)

if not okUi or not uiSource then return end
task.wait(0.1)

local ZyphraxHub = loadstring(uiSource)()
if not ZyphraxHub then return end

local version = LRM_ScriptVersion and ("v" .. table.concat(tostring(LRM_ScriptVersion):split(""), ".")) or "Engenesis Mode"

local isMobile = table.find({ Enum.Platform.Android, Enum.Platform.IOS }, UserInputService:GetPlatform()) ~= nil
local windowSize = isMobile and UDim2.fromOffset(528, 334) or UDim2.fromOffset(620, 370)

local Window = ZyphraxHub:CreateWindow({
	Title = "ZyphraxHub",
	Icon = "rbxassetid://125623993645104",
	Author = (premium and "Premium" or "MM2") .. " | " .. version,
	Folder = "Zyphrax Hub",
	Size = windowSize,
	LiveSearchDropdown = true,
	FileSaveName = "Zyphrax Hub/MM2.json",
})

local InfoTab, MainTab, VisualTab, MiscTab = nil, nil, nil, nil
pcall(function()
	InfoTab = Window:Tab({ Title = "Information", Icon = "info" })
	MainTab = Window:Tab({ Title = "Main", Icon = "landmark" })
	VisualTab = Window:Tab({ Title = "Visual", Icon = "eye" })
	MiscTab = Window:Tab({ Title = "Misc", Icon = "cog" })
end)

local flags = {
	killAll = false,
	autoShoot = false,
	autoTakeGun = false,
	autoFarmCoin = false,
	espGunDrop = false,
	fly = false,
	noclip = false,
	xray = false,
	aimbot = false,
	espRoleChams = false,
	espDistance = false,
}

local cfg = {
	selectedPlayer = nil,
	speedHack = 16,
	jumpPower = 50,
	flySpeed = 25,
	coinSpeed = 25,
	autoSaveSettings = true,
}

local playerDropdown = nil
local originalTransparencies = {}
local rolesCache = {}
local flyState = { velocity = nil, gyro = nil }
local distanceTexts = {}
local roleChamsPool = {}
local coinFarmConnection = nil
local currentCoinTarget = nil
local coinMoveTween = nil
local coinTweenTarget = nil
local lastSettingsSave = 0
local lastAutoShootAt = 0
local lastRoleChamsRefresh = 0
local lastKillAllAt = 0
local lastGunPickupAttempt = 0

local settingsRoot = "Zyphrax Hub"
local settingsDir = "Zyphrax Hub/MM2/Settings"
local settingsFile = string.format("%s/User-%s.json", settingsDir, LocalPlayer.Name)

local function getRoot(character)
	return character and character:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid(character)
	return character and character:FindFirstChildOfClass("Humanoid")
end

local function notify(title, text)
	pcall(function()
		ZyphraxHub:Notify({ Title = title, Content = text, Icon = "info", Duration = 3 })
	end)
end

local function ensureSettingsFolder()
	if not (isfolder and makefolder) then return false end
	if not isfolder(settingsRoot) then
		makefolder(settingsRoot)
	end
	if not isfolder("Zyphrax Hub/MM2") then
		makefolder("Zyphrax Hub/MM2")
	end
	if not isfolder(settingsDir) then
		makefolder(settingsDir)
	end
	return true
end

local function saveSettings(force)
	force = force == true
	if (not force) and (not cfg.autoSaveSettings) then return false end
	if not (writefile and HttpService and ensureSettingsFolder()) then return false end
	local payload = { flags = {}, cfg = {} }
	for key, value in pairs(flags) do
		payload.flags[key] = value
	end
	for key, value in pairs(cfg) do
		payload.cfg[key] = value
	end
	local ok = pcall(function()
		writefile(settingsFile, HttpService:JSONEncode(payload))
	end)
	return ok
end

local function loadSettings()
	if not (readfile and isfile and HttpService) then return end
	if not isfile(settingsFile) then return end

	pcall(function()
		local decoded = HttpService:JSONDecode(readfile(settingsFile))
		if type(decoded) ~= "table" then return end

		if type(decoded.flags) == "table" then
			for key, value in pairs(decoded.flags) do
				if flags[key] ~= nil and type(value) == "boolean" then
					flags[key] = value
				end
			end
		end

		if type(decoded.cfg) == "table" then
			for key, value in pairs(decoded.cfg) do
				if cfg[key] ~= nil then
					if type(cfg[key]) == "number" and type(value) == "number" then
						cfg[key] = value
					elseif type(cfg[key]) == "boolean" and type(value) == "boolean" then
						cfg[key] = value
					elseif key == "selectedPlayer" and (type(value) == "string" or value == nil) then
						cfg.selectedPlayer = value
					end
				end
			end
		end
	end)
end

loadSettings()
cfg.coinSpeed = math.clamp(tonumber(cfg.coinSpeed) or 25, 1, 75)

local function getRoles()
	local ok, data = pcall(function()
		local remote = ReplicatedStorage:FindFirstChild("GetPlayerData", true)
		return remote and remote:InvokeServer()
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
		if plr ~= LocalPlayer and plr.Name and plr.Name ~= "" then
			table.insert(names, plr.Name)
		end
	end
	table.sort(names)
	return names
end

local function safeTeleport(targetCFrame, offset)
	if not targetCFrame then return end
	offset = offset or Vector3.new(0, 0, 0)
	local character = LocalPlayer.Character
	local rootPart = character and getRoot(character)
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

local function clearAllESPHighlights()
	for _, plr in pairs(Players:GetPlayers()) do
		if plr.Character then
			pcall(function() plr.Character:FindFirstChild("RoleHighlight"):Destroy() end)
			pcall(function() plr.Character:FindFirstChild("GunHighlight"):Destroy() end)
		end
	end
	local gunFolder = Workspace:FindFirstChild("Guns")
	if gunFolder then
		for _, gun in pairs(gunFolder:GetChildren()) do
			pcall(function() gun:FindFirstChild("GunHighlight"):Destroy() end)
		end
	end
end

local function clearRoleChamsForPlayer(player)
	local hl = roleChamsPool[player]
	if hl then
		pcall(function() hl:Destroy() end)
	end
	roleChamsPool[player] = nil
end

local function clearRoleChams()
	for player in pairs(roleChamsPool) do
		clearRoleChamsForPlayer(player)
	end
end

local function stopCoinFarm()
	if coinFarmConnection then
		coinFarmConnection:Disconnect()
		coinFarmConnection = nil
	end
	if coinMoveTween then
		pcall(function() coinMoveTween:Cancel() end)
		coinMoveTween = nil
	end
	coinTweenTarget = nil
	currentCoinTarget = nil
end

local function setCharacterNoclip(character)
	if not character then return end
	for _, part in ipairs(character:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CanCollide = false
		end
	end
end

local function getNearestCoin(position)
	local nearest = nil
	local minDistance = math.huge
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("BasePart") and obj.Name == "Coin_Server" then
			local distance = (position - obj.Position).Magnitude
			if distance < minDistance then
				minDistance = distance
				nearest = obj
			end
		end
	end
	return nearest
end

local function startCoinFarm()
	stopCoinFarm()
	coinFarmConnection = RunService.Heartbeat:Connect(function()
		if not flags.autoFarmCoin then
			stopCoinFarm()
			return
		end
		pcall(function()
			local character = LocalPlayer.Character
			local root = getRoot(character)
			if not root then return end

			setCharacterNoclip(character)

			if currentCoinTarget then
				if (not currentCoinTarget.Parent) or (root.Position - currentCoinTarget.Position).Magnitude <= 0.25 then
					currentCoinTarget = nil
					coinTweenTarget = nil
				end
			end

			if not currentCoinTarget then
				currentCoinTarget = getNearestCoin(root.Position)
			end

			if not currentCoinTarget then
				if coinMoveTween then
					pcall(function() coinMoveTween:Cancel() end)
					coinMoveTween = nil
				end
				coinTweenTarget = nil
				return
			end

			local targetPosition = currentCoinTarget.Position + Vector3.new(0, 0.05, 0)
			local delta = targetPosition - root.Position
			local distance = delta.Magnitude
			if distance <= 0.2 then
				currentCoinTarget = nil
				coinTweenTarget = nil
				if coinMoveTween then
					pcall(function() coinMoveTween:Cancel() end)
					coinMoveTween = nil
				end
				return
			end

			if math.abs(delta.Y) > 35 then
				currentCoinTarget = nil
				return
			end

			if distance > 200 then
				currentCoinTarget = nil
				return
			end

			local speed = math.clamp(tonumber(cfg.coinSpeed) or 25, 1, 75)
			local duration = math.clamp(distance / (speed * 2.8), 0.04, 0.24)
			local desiredCFrame = CFrame.new(targetPosition, targetPosition + root.CFrame.LookVector)
			local tweenPlaying = coinMoveTween and coinMoveTween.PlaybackState == Enum.PlaybackState.Playing
			local targetChanged = (not coinTweenTarget) or ((coinTweenTarget - targetPosition).Magnitude > 0.2)

			if tweenPlaying and not targetChanged then
				return
			end

			if coinMoveTween then
				pcall(function() coinMoveTween:Cancel() end)
			end

			local targetRef = currentCoinTarget
			coinTweenTarget = targetPosition
			coinMoveTween = TweenService:Create(root, TweenInfo.new(duration, Enum.EasingStyle.Linear), { CFrame = desiredCFrame })
			coinMoveTween.Completed:Connect(function()
				if coinMoveTween and coinMoveTween.PlaybackState ~= Enum.PlaybackState.Playing then
					coinMoveTween = nil
				end
				if targetRef == currentCoinTarget then
					currentCoinTarget = nil
					coinTweenTarget = nil
				end
			end)
			coinMoveTween:Play()
		end)
	end)
end

local function clearFlyForces()
	if flyState.velocity then pcall(function() flyState.velocity:Destroy() end) flyState.velocity = nil end
	if flyState.gyro then pcall(function() flyState.gyro:Destroy() end) flyState.gyro = nil end
	local character = LocalPlayer.Character
	local humanoid = character and getHumanoid(character)
	if humanoid then humanoid.AutoRotate = true end
end

local function ensureFlyForces(rootPart)
	if not flyState.velocity or flyState.velocity.Parent ~= rootPart then
		if flyState.velocity then pcall(function() flyState.velocity:Destroy() end) end
		local bv = Instance.new("BodyVelocity")
		bv.Name = "FlyVelocity"
		bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
		bv.P = 25000
		bv.Velocity = Vector3.new(0, 0, 0)
		bv.Parent = rootPart
		flyState.velocity = bv
	end
	if not flyState.gyro or flyState.gyro.Parent ~= rootPart then
		if flyState.gyro then pcall(function() flyState.gyro:Destroy() end) end
		local bg = Instance.new("BodyGyro")
		bg.Name = "FlyGyro"
		bg.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
		bg.P = 30000
		bg.CFrame = rootPart.CFrame
		bg.Parent = rootPart
		flyState.gyro = bg
	end
end

local function setXray(enabled)
	if enabled then
		for _, obj in ipairs(Workspace:GetDescendants()) do
			if obj:IsA("BasePart") and not obj:IsDescendantOf(LocalPlayer.Character) then
				if not obj:FindFirstChild("HumanoidRootPart") and not obj.Parent:FindFirstChild("Humanoid") then
					if not originalTransparencies[obj] then
						originalTransparencies[obj] = obj.Transparency
					end
					obj.Transparency = 0.7
				end
			end
		end
	else
		for obj, originalTrans in pairs(originalTransparencies) do
			if obj and obj.Parent then
				pcall(function() obj.Transparency = originalTrans end)
			end
		end
		table.clear(originalTransparencies)
	end
end

local function getMurdererPlayer()
	for plrName, role in pairs(rolesCache) do
		if role == "Murderer" then
			local plr = Players:FindFirstChild(plrName)
			if plr and plr.Character then
				local humanoid = getHumanoid(plr.Character)
				if humanoid and humanoid.Health > 0 then
					return plr
				end
			end
		end
	end
	return nil
end

local function findGunToolIn(container)
	if not container then return nil end
	for _, item in pairs(container:GetChildren()) do
		if item:IsA("Tool") then
			local lower = item.Name:lower()
			if lower:find("gun") or lower:find("revolver") or lower:find("sheriff") then
				return item
			end
		end
	end
	return nil
end

local function equipGunTool()
	local character = LocalPlayer.Character
	if not character then return nil end

	local equipped = findGunToolIn(character)
	if equipped then return equipped end

	local backpack = LocalPlayer:FindFirstChild("Backpack")
	local stored = findGunToolIn(backpack)
	if not stored then return nil end

	local humanoid = getHumanoid(character)
	if humanoid then
		humanoid:EquipTool(stored)
		task.wait(0.03)
		return findGunToolIn(character) or stored
	end

	return stored
end

local function findKnifeToolIn(container)
	if not container then return nil end
	for _, item in pairs(container:GetChildren()) do
		if item:IsA("Tool") then
			local lower = item.Name:lower()
			if lower:find("knife") then
				return item
			end
		end
	end
	return nil
end

local function equipKnifeTool()
	local character = LocalPlayer.Character
	if not character then return nil end

	local equipped = findKnifeToolIn(character)
	if equipped then return equipped end

	local backpack = LocalPlayer:FindFirstChild("Backpack")
	local stored = findKnifeToolIn(backpack)
	if not stored then return nil end

	local humanoid = getHumanoid(character)
	if humanoid then
		humanoid:EquipTool(stored)
		task.wait(0.03)
		return findKnifeToolIn(character) or stored
	end

	return stored
end

local function pickupNearbyGun()
	local character = LocalPlayer.Character
	local root = getRoot(character)
	if not root then return end

	local gunFolder = Workspace:FindFirstChild("Guns")
	if not gunFolder then return end

	for _, gun in pairs(gunFolder:GetChildren()) do
		local part = gun:IsA("BasePart") and gun or gun:FindFirstChild("Handle")
		if part and part:IsA("BasePart") then
			local dist = (root.Position - part.Position).Magnitude
			if dist < 10 then
				firetouchinterest(root, part, 0)
				firetouchinterest(root, part, 1)
				task.wait(0.05)
				local prompt = part:FindFirstChildOfClass("ProximityPrompt")
				if prompt then
					prompt:InputHoldBegin()
					task.wait(0.05)
					prompt:InputHoldEnd()
				end
				return true
			end
		end
	end
	return false
end

local function performAimbot()
	if not flags.aimbot then return end
	local targetPlayer = getMurdererPlayer()
	if targetPlayer and targetPlayer.Character then
		local targetRoot = getRoot(targetPlayer.Character)
		if targetRoot then
			local camera = Workspace.CurrentCamera
			if not camera then return end

			local predictedPos = targetRoot.Position + (targetRoot.AssemblyLinearVelocity * 0.08)
			camera.CFrame = CFrame.lookAt(camera.CFrame.Position, predictedPos)
		end
	end
end

local function updateESP()
	local camera = Workspace.CurrentCamera
	if not camera then return end
	local myRoot = getRoot(LocalPlayer.Character)
	local now = os.clock()
	local shouldRefreshRoleChams = (now - lastRoleChamsRefresh) >= 0.12
	if shouldRefreshRoleChams then
		lastRoleChamsRefresh = now
	end

	for _, plr in pairs(Players:GetPlayers()) do
		if plr == LocalPlayer then continue end
		local character = plr.Character
		if not character then continue end

		if flags.espRoleChams then
			local role = rolesCache[plr.Name] or "Innocent"
			if role == "Hero" then role = "Sheriff" end
			local color = RoleColors[role] or RoleColors.Innocent
			local hl = roleChamsPool[plr]
			if (not hl) or (hl.Parent ~= character) then
				clearRoleChamsForPlayer(plr)
				hl = Instance.new("Highlight")
				hl.Name = "MM2_RoleChams"
				hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				hl.FillTransparency = 0.5
				hl.OutlineTransparency = 0
				hl.Parent = character
				roleChamsPool[plr] = hl
			end
			hl.Adornee = character
			if shouldRefreshRoleChams then
				hl.FillColor = color
				hl.OutlineColor = Color3.new(1, 1, 1)
			end
			if not hl.Enabled then
				hl.Enabled = true
			end
		else
			clearRoleChamsForPlayer(plr)
		end

		if flags.espDistance and myRoot then
			local root = getRoot(character)
			if root then
				local distance = (myRoot.Position - root.Position).Magnitude
				local role = rolesCache[plr.Name] or "Innocent"
				if role == "Hero" then role = "Sheriff" end
				local displayText = string.format("%s [%d studs]", role, distance)

				local textObj = distanceTexts[plr]
				if not textObj then
					textObj = Drawing.new("Text")
					textObj.Size = 14
					textObj.Center = true
					textObj.Outline = true
					textObj.OutlineColor = Color3.new(0, 0, 0)
					distanceTexts[plr] = textObj
				end

				local screenPos, onScreen = camera:WorldToViewportPoint(root.Position + Vector3.new(0, 3, 0))
				textObj.Visible = onScreen
				if onScreen then
					textObj.Text = displayText
					textObj.Position = Vector2.new(screenPos.X, screenPos.Y)
					textObj.Color = RoleColors[role] or RoleColors.Innocent
				end
			end
		else
			local textObj = distanceTexts[plr]
			if textObj then textObj.Visible = false end
		end
	end
end

Players.PlayerRemoving:Connect(function(player)
	local textObj = distanceTexts[player]
	if textObj then textObj:Remove() distanceTexts[player] = nil end
	clearRoleChamsForPlayer(player)
end)

local function cleanupAll()
	resetAllFlags()
	clearAllESPHighlights()
	clearRoleChams()
	clearFlyForces()
	stopCoinFarm()
	setXray(false)

	for _, textObj in pairs(distanceTexts) do
		if textObj then textObj:Remove() end
	end
	table.clear(distanceTexts)

	for _, plr in pairs(Players:GetPlayers()) do
		if plr.Character then
			local hlLegacy = plr.Character:FindFirstChild("RoleChams")
			if hlLegacy then hlLegacy:Destroy() end
			local hlCurrent = plr.Character:FindFirstChild("MM2_RoleChams")
			if hlCurrent then hlCurrent:Destroy() end
		end
	end

	for obj, originalTrans in pairs(originalTransparencies) do
		if obj and obj.Parent then pcall(function() obj.Transparency = originalTrans end) end
	end
	table.clear(originalTransparencies)
end

if Window.Instance then
	Window.Instance.AncestryChanged:Connect(function()
		if not Window.Instance.Parent then cleanupAll() end
	end)
end

do
	if InfoTab then
		pcall(function()
			InfoTab:Section({ Title = "Information" })
			InfoTab:Paragraph({ Title = "Murder Mystery 2", Desc = "Professional Exploit Script" })
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

	if MainTab then
		pcall(function()
			MainTab:Section({ Title = "Aim" })
			MainTab:Toggle({ Title = "Aimbot (Murder)", Callback = function(state) flags.aimbot = state end })
			MainTab:Toggle({ Title = "Auto Shoot (Murder)", Callback = function(state) flags.autoShoot = state end })
		end)
		pcall(function()
			MainTab:Section({ Title = "Murder" })
			MainTab:Toggle({ Title = "Kill All", Callback = function(state) flags.killAll = state end })

			local initialPlayers = getPlayerNames()
			local dropdownOptions = #initialPlayers > 0 and initialPlayers or {"No Players"}
			playerDropdown = MainTab:Dropdown({
				Title = "Select Player",
				Options = dropdownOptions,
				Default = dropdownOptions[1] or "No Players",
				Callback = function(selected)
					if type(selected) == "table" then selected = selected[1] or nil end
					cfg.selectedPlayer = (selected and selected ~= "No Players" and selected ~= "") and selected or nil
				end,
			})
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
									safeTeleport(targetRoot.CFrame, Vector3.new(0, 0, -1.5))
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
			MainTab:Toggle({ Title = "Auto Take Gun", Callback = function(state) flags.autoTakeGun = state end })
		end)
		pcall(function()
			MainTab:Section({ Title = "Farm" })
			MainTab:Toggle({
				Title = "Auto Farm Coin",
				Value = flags.autoFarmCoin,
				Callback = function(state)
					flags.autoFarmCoin = state
					if state then
						startCoinFarm()
					else
						stopCoinFarm()
					end
				end
			})
			MainTab:Slider({ Title = "Coin Speed", Step = 1, Value = { Min = 1, Max = 75, Default = math.clamp(cfg.coinSpeed, 1, 75) }, Callback = function(value) cfg.coinSpeed = value end })
		end)
	end

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
	task.delay(0.5, updatePlayerDropdown)
	task.delay(1, updatePlayerDropdown)

	if VisualTab then
		pcall(function()
			VisualTab:Section({ Title = "Player ESP" })
			VisualTab:Toggle({
				Title = "Role Chams",
				Callback = function(state)
					flags.espRoleChams = state
					if not state then
						clearRoleChams()
					else
						lastRoleChamsRefresh = 0
					end
				end
			})
			VisualTab:Toggle({ Title = "Distance", Callback = function(state) flags.espDistance = state end })
			VisualTab:Section({ Title = "Other ESP" })
			VisualTab:Toggle({ Title = "ESP Gun Drop", Callback = function(state) flags.espGunDrop = state end })
			VisualTab:Section({ Title = "World Visuals" })
			VisualTab:Toggle({ Title = "X-Ray", Callback = function(state) flags.xray = state; setXray(state) end })
		end)
	end

	if MiscTab then
		pcall(function()
			MiscTab:Section({ Title = "Save Settings" })
			MiscTab:Toggle({
				Title = "Auto Save Settings",
				Value = cfg.autoSaveSettings,
				Callback = function(state)
					cfg.autoSaveSettings = state
					if state then
						saveSettings(true)
					end
				end
			})

			MiscTab:Section({ Title = "Movement" })
			MiscTab:Slider({
				Title = "Speed", Step = 1, Value = { Min = 1, Max = 100, Default = cfg.speedHack },
				Callback = function(v)
					cfg.speedHack = v
					local h = getHumanoid(LocalPlayer.Character)
					if h then h.WalkSpeed = v end
				end
			})
			MiscTab:Slider({
				Title = "Jump Power", Step = 1, Value = { Min = 1, Max = 250, Default = cfg.jumpPower },
				Callback = function(v)
					cfg.jumpPower = v
					local h = getHumanoid(LocalPlayer.Character)
					if h then h.JumpPower = v end
				end
			})
			MiscTab:Slider({
				Title = "Fly Speed", Step = 1, Value = { Min = 5, Max = 200, Default = cfg.flySpeed },
				Callback = function(v) cfg.flySpeed = v end
			})
			MiscTab:Toggle({
				Title = "Fly",
				Callback = function(state)
					flags.fly = state
					if not state then clearFlyForces() end
				end
			})
			MiscTab:Toggle({ Title = "Noclip", Callback = function(state) flags.noclip = state end })

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
									if targetRoot then safeTeleport(targetRoot.CFrame, Vector3.new(5, 0, 0)) break end
								end
							end
						end
					end)
				end
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
									if targetRoot then safeTeleport(targetRoot.CFrame, Vector3.new(5, 0, 0)) break end
								end
							end
						end
					end)
				end
			})
			MiscTab:Button({
				Title = "Teleport to Gun Drop",
				Callback = function()
					pcall(function()
						local gunFolder = Workspace:FindFirstChild("Guns")
						if gunFolder then
							local nearest, minDist = nil, math.huge
							local myRoot = getRoot(LocalPlayer.Character)
							if myRoot then
								for _, gun in pairs(gunFolder:GetChildren()) do
									local gunPart = gun:FindFirstChild("Handle") or (gun:IsA("BasePart") and gun)
									if gunPart then
										local dist = (myRoot.Position - gunPart.Position).Magnitude
										if dist < minDist then minDist = dist; nearest = gunPart end
									end
								end
								if nearest then safeTeleport(nearest.CFrame, Vector3.new(5, 0, 0)) end
							end
						end
					end)
				end
			})
			MiscTab:Button({
				Title = "Teleport to Lobby",
				Callback = function()
					pcall(function()
						local lobby = Workspace:FindFirstChild("Lobby", true)
						if lobby then
							local part = lobby:FindFirstChildWhichIsA("BasePart", true)
							if part then safeTeleport(part.CFrame, Vector3.new(0, 3, 0)) end
						end
					end)
				end
			})

			MiscTab:Section({ Title = "Server" })
			MiscTab:Button({ Title = "Rejoin", Callback = function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end })
			MiscTab:Button({
				Title = "Server Hop",
				Callback = function()
					local servers = {}
					pcall(function()
						local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?limit=100"
						local data = HttpService:JSONDecode(game:HttpGet(url))
						for _, server in ipairs(data.data) do
							if server.playing < server.maxPlayers and server.id ~= game.JobId then
								table.insert(servers, server.id)
							end
						end
					end)
					if #servers > 0 then
						TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[1], LocalPlayer)
					else
						TeleportService:Teleport(game.PlaceId, LocalPlayer)
					end
				end
			})
		end)
	end

	if Window then pcall(function() Window:SelectTab(1) end) end
end

function resetAllFlags()
	flags.killAll, flags.autoShoot, flags.autoTakeGun, flags.autoFarmCoin = false, false, false, false
	flags.espRole, flags.espGunDrop, flags.fly, flags.noclip = false, false, false, false
	flags.xray, flags.aimbot, flags.espRoleChams, flags.espDistance = false, false, false, false
	setXray(false)
end

clearAllESPHighlights()

local currentHumanoid = getHumanoid(LocalPlayer.Character)
if currentHumanoid then
	currentHumanoid.WalkSpeed = cfg.speedHack
	currentHumanoid.JumpPower = cfg.jumpPower
end

RunService.Heartbeat:Connect(function()
	if cfg.autoSaveSettings then
		local now = os.clock()
		if now - lastSettingsSave >= 2 then
			lastSettingsSave = now
			saveSettings()
		end
	end

	getRoles()
	updateESP()

	if flags.killAll then
		pcall(function()
			local now = os.clock()
			if now - lastKillAllAt < 0.09 then return end

			local myRole = rolesCache[LocalPlayer.Name]
			if myRole ~= "Murderer" then return end

			local knife = equipKnifeTool()
			if not knife then return end

			pcall(function() knife:Activate() end)
			pcall(function()
				VirtualUser:CaptureController()
				VirtualUser:ClickButton1(Vector2.new())
			end)

			for _, plr in pairs(Players:GetPlayers()) do
				if plr ~= LocalPlayer and plr.Character then
					local targetRoot = getRoot(plr.Character)
					local targetHumanoid = getHumanoid(plr.Character)
					if targetRoot and targetHumanoid and targetHumanoid.Health > 0 then
						safeTeleport(targetRoot.CFrame, Vector3.new(0, 0, -1.5))
						pcall(function() knife:Activate() end)
						pcall(function()
							VirtualUser:CaptureController()
							VirtualUser:ClickButton1(Vector2.new())
						end)
						ReplicatedStorage.Remotes.Gameplay.MeleeHit:FireServer(targetHumanoid)
						task.wait(0.02)
					end
				end
			end

			lastKillAllAt = now
		end)
	end

	if flags.autoShoot then
		pcall(function()
			local now = os.clock()
			if now - lastAutoShootAt < 0.15 then return end

			local target = getMurdererPlayer()
			if not target or not target.Character then return end

			local targetRoot = getRoot(target.Character)
			local myRoot = getRoot(LocalPlayer.Character)
			if not targetRoot or not myRoot then return end

			local gunTool = equipGunTool()
			if not gunTool then return end

			local velocity = targetRoot.AssemblyLinearVelocity
			local behindOffset = -targetRoot.CFrame.LookVector * 4.5 + Vector3.new(0, 1.8, 0)
			safeTeleport(targetRoot.CFrame + behindOffset)

			myRoot = getRoot(LocalPlayer.Character)
			if not myRoot then return end

			local aimPos = targetRoot.Position + velocity * 0.08
			myRoot.CFrame = CFrame.new(myRoot.Position, aimPos)

			pcall(function()
				gunTool:Activate()
			end)
			pcall(function()
				VirtualUser:CaptureController()
				VirtualUser:ClickButton1(Vector2.new())
			end)

			local shootPositions = {
				aimPos,
				targetRoot.Position + velocity * 0.05,
				targetRoot.Position + velocity * 0.12
			}
			for _, shootPos in ipairs(shootPositions) do
				ReplicatedStorage.Remotes.Gameplay.ShootGun:FireServer(shootPos)
				task.wait(0.02)
			end

			lastAutoShootAt = now
		end)
	end

	if flags.aimbot then performAimbot() end

	if flags.autoTakeGun then
		pcall(function()
			local now = os.clock()
			if now - lastGunPickupAttempt < 0.5 then return end
			lastGunPickupAttempt = now

			local myRoot = getRoot(LocalPlayer.Character)
			if not myRoot then return end

			local gunFolder = Workspace:FindFirstChild("Guns")
			if not gunFolder then return end

			local nearestPart = nil
			local nearestDist = math.huge

			for _, gun in pairs(gunFolder:GetChildren()) do
				local part = gun:IsA("BasePart") and gun or gun:FindFirstChild("Handle")
				if part and part:IsA("BasePart") then
					local dist = (myRoot.Position - part.Position).Magnitude
					if dist < nearestDist then
						nearestDist = dist
						nearestPart = part
					end
				end
			end

			if nearestPart then
				safeTeleport(nearestPart.CFrame, Vector3.new(0, 2, 0))
				task.wait(0.05)
				pickupNearbyGun()
			end
		end)
	end

	if flags.espGunDrop then
		pcall(function()
			local gunFolder = Workspace:FindFirstChild("Guns")
			if gunFolder then
				for _, gun in pairs(gunFolder:GetChildren()) do
					if gun:IsA("BasePart") or gun:FindFirstChild("Handle") then
						local gunParent = gun:IsA("BasePart") and gun or gun:FindFirstChild("Handle")
						if gunParent and gunParent.Parent and not gunParent:FindFirstChild("GunHighlight") then
							local hl = Instance.new("Highlight")
							hl.Name = "GunHighlight"
							hl.FillColor = Color3.fromRGB(255, 200, 0)
							hl.OutlineColor = Color3.fromRGB(200, 160, 0)
							hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
							hl.FillTransparency = 0.4
							hl.Parent = gunParent
						end
					end
				end
			end
		end)
	end

	if flags.fly and LocalPlayer.Character then
		local myRoot, humanoid = getRoot(LocalPlayer.Character), getHumanoid(LocalPlayer.Character)
		if myRoot and humanoid then
			ensureFlyForces(myRoot)
			humanoid.AutoRotate = false
			pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.Physics) end)
			local camera = Workspace.CurrentCamera
			local moveDirection = humanoid.MoveDirection
			local worldMove = camera.CFrame:VectorToWorldSpace(moveDirection)
			local vertical = (UserInputService:IsKeyDown(Enum.KeyCode.Space) and 1 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) and 1 or 0)
			if flyState.velocity then
				local desiredVelocity = (worldMove * cfg.flySpeed) + Vector3.new(0, vertical * cfg.flySpeed, 0)
				if desiredVelocity.Magnitude < 0.05 then desiredVelocity = Vector3.new(0, 0, 0) end
				flyState.velocity.Velocity = desiredVelocity
			end
			if flyState.gyro then flyState.gyro.CFrame = camera.CFrame end
		end
	else
		clearFlyForces()
	end

	if flags.noclip and LocalPlayer.Character then
		for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
			if part:IsA("BasePart") then part.CanCollide = false end
		end
	end
end)

if flags.autoFarmCoin then
	startCoinFarm()
end

if flags.xray then
	setXray(true)
end

LocalPlayer.CharacterAdded:Connect(function(newCharacter)
	task.wait(0.2)

	clearFlyForces()
	if flags.autoFarmCoin then
		stopCoinFarm()
		startCoinFarm()
	end

	local humanoid = getHumanoid(newCharacter)
	if humanoid then
		humanoid.WalkSpeed = cfg.speedHack
		humanoid.JumpPower = cfg.jumpPower
	end
end)

notify("ZyphraxHub MM2", "Script loaded successfully!")