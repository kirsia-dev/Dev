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
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

-- Anti-AFK
LocalPlayer.Idled:Connect(function()
	pcall(function()
		VirtualUser:CaptureController()
		VirtualUser:ClickButton1(Vector2.new())
	end)
end)

-- Premium Check
local premium = false
pcall(function()
	if readfile and isfile and isfile("Zyphrax Hub/MM2/premium.txt") then
		local premiumData = readfile("Zyphrax Hub/MM2/premium.txt")
		premium = premiumData:find(LocalPlayer.Name) ~= nil
	end
end)

-- Load UI Library
local uiSource = nil
local okUi = pcall(function()
	uiSource = game:HttpGet("https://raw.githubusercontent.com/Moonshall/ZyphraxHub/refs/heads/main/mainui.lua")
end)

if not okUi or not uiSource then return end
task.wait(0.1)

local ZyphraxHub = loadstring(uiSource)()
if not ZyphraxHub then return end

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

local InfoTab, MainTab, VisualTab, MiscTab = nil, nil, nil, nil
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
	espGunDrop = false, 
	fly = false, 
	noclip = false,
	xray = false, 
	aimbot = false, 
	espRoleChams = false, 
	espDistance = false,
}

-- Config
local cfg = {
	selectedPlayer = nil, 
	speedHack = 16, 
	jumpPower = 50,
	flySpeed = 25, 
	coinSpeed = 25,
}

local playerDropdown = nil
local originalTransparencies = {}
local rolesCache = {}
local flyState = { velocity = nil, gyro = nil }
local coinFarmState = { tween = nil, target = nil, lastCollect = 0 }
local distanceTexts = {}

-- Helper Functions
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

local function isBagFull()
	local backpack = LocalPlayer:FindFirstChild("Backpack")
	if not backpack then return false end
	local coinCount, maxCoins = 0, 40
	pcall(function()
		if MarketplaceService:UserOwnsAsset(LocalPlayer.UserId, 3878455) then maxCoins = 50 end
	end)
	for _, item in pairs(backpack:GetChildren()) do
		if item.Name == "Coin" or item.Name:lower():find("coin") then
			coinCount = coinCount + 1
		end
	end
	return coinCount >= maxCoins
end

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

local function applyRoleESP()
	if not flags.espRole then return end
	pcall(function()
		local roles = getRoles()
		for _, plr in pairs(Players:GetPlayers()) do
			if plr ~= LocalPlayer and plr.Character then
				local role = roles[plr.Name] or "Innocent"
				if role == "Hero" then role = "Sheriff" end
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
		if obj.Name == "KnifeStabbed" then return obj end
	end
	return nil
end

local function stopCoinFarmTween()
	if coinFarmState.tween then
		pcall(function() coinFarmState.tween:Cancel() end)
		coinFarmState.tween = nil
	end
	coinFarmState.target = nil
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

local function performAimbot()
	if not flags.aimbot then return end
	local roles = getRoles()
	local targetPlayer = nil
	for plrName, role in pairs(roles) do
		if role == "Murderer" then targetPlayer = Players:FindFirstChild(plrName) break end
	end
	if targetPlayer and targetPlayer.Character then
		local targetRoot = getRoot(targetPlayer.Character)
		local myRoot = getRoot(LocalPlayer.Character)
		if targetRoot and myRoot then
			local camera = Workspace.CurrentCamera
			camera.CFrame = CFrame.lookAt(myRoot.Position, targetRoot.Position)
		end
	end
end

-- ESP Update
local function updateESP()
	local camera = Workspace.CurrentCamera
	if not camera then return end
	local myRoot = getRoot(LocalPlayer.Character)

	for _, plr in pairs(Players:GetPlayers()) do
		if plr == LocalPlayer then continue end
		local character = plr.Character
		if not character then continue end

		-- Role Chams (Full Body Highlight)
		if flags.espRoleChams then
			local role = rolesCache[plr.Name] or "Innocent"
			if role == "Hero" then role = "Sheriff" end
			local color = RoleColors[role] or RoleColors.Innocent
			local hl = character:FindFirstChild("RoleChams")
			if not hl then
				hl = Instance.new("Highlight")
				hl.Name = "RoleChams"
				hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				hl.FillTransparency = 0.5
				hl.OutlineTransparency = 0
				hl.Parent = character
			end
			hl.FillColor = color
			hl.OutlineColor = Color3.new(1, 1, 1)
			hl.Enabled = true
		else
			local hl = character:FindFirstChild("RoleChams")
			if hl then hl.Enabled = false end
		end

		-- Distance Text
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
end)

-- Cleanup on UI close
local function cleanupAll()
	resetAllFlags()
	clearAllESPHighlights()
	clearFlyForces()
	stopCoinFarmTween()
	setXray(false)

	for _, textObj in pairs(distanceTexts) do
		if textObj then textObj:Remove() end
	end
	table.clear(distanceTexts)

	for _, plr in pairs(Players:GetPlayers()) do
		if plr.Character then
			local hl = plr.Character:FindFirstChild("RoleChams")
			if hl then hl:Destroy() end
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

-- UI Construction
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
				Title = "Select Player", Options = dropdownOptions, Default = "No Players",
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
			MainTab:Toggle({ Title = "Auto Take Gun", Callback = function(state) flags.autoTakeGun = state end })
		end)
        pcall(function()
	        MainTab:Section({ Title = "Farm" })

	        MainTab:Toggle({
		        Title = "Auto Farm Coin",
		        Callback = function(state)
			        flags.autoFarmCoin = state

			        if not state then
				        if stopCoinFarmTween then
					        pcall(stopCoinFarmTween)
				        end
			        end
		        end
	         })

	        MainTab:Slider({
		        Title = "Coin Speed",
		        Step = 1,
		        Value = { Min = 1, Max = 100, Default = 25 },
		        Callback = function(value)
			        cfg.coinSpeed = value
		        end
	        })
        end)

	local function updatePlayerDropdown()
		if not playerDropdown then return end
		local names = getPlayerNames()
		pcall(function() playerDropdown:Set(#names > 0 and names or {"No Players"}) end)
	end
	Players.PlayerAdded:Connect(function() task.wait(0.2) updatePlayerDropdown() end)
	Players.PlayerRemoving:Connect(function() task.wait(0.1) updatePlayerDropdown() end)
	task.delay(0.5, updatePlayerDropdown)

	if VisualTab then
		pcall(function()
			VisualTab:Section({ Title = "Player ESP" })
			VisualTab:Toggle({ Title = "Role Chams", Callback = function(state) flags.espRoleChams = state end })
			VisualTab:Toggle({ Title = "Distance", Callback = function(state) flags.espDistance = state end })
			VisualTab:Section({ Title = "Other ESP" })
			VisualTab:Toggle({ Title = "ESP Gun Drop", Callback = function(state) flags.espGunDrop = state end })
			VisualTab:Section({ Title = "World Visuals" })
			VisualTab:Toggle({ Title = "X-Ray", Callback = function(state) flags.xray = state; setXray(state) end })
		end)
	end

	if MiscTab then
		pcall(function()
			MiscTab:Section({ Title = "Movement" })
			MiscTab:Slider({
				Title = "Speed", Step = 1, Value = { Min = 1, Max = 100, Default = 16 },
				Callback = function(v)
					cfg.speedHack = v
					local h = getHumanoid(LocalPlayer.Character)
					if h then h.WalkSpeed = v end
				end
			})
			MiscTab:Slider({
				Title = "Jump Power", Step = 1, Value = { Min = 1, Max = 250, Default = 50 },
				Callback = function(v)
					cfg.jumpPower = v
					local h = getHumanoid(LocalPlayer.Character)
					if h then h.JumpPower = v end
				end
			})
			MiscTab:Slider({
				Title = "Fly Speed", Step = 1, Value = { Min = 5, Max = 200, Default = 25 },
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

resetAllFlags()
clearAllESPHighlights()

-- Main Loop
RunService.Heartbeat:Connect(function()
	getRoles()
	updateESP()

    if flags.killAll then
	    pcall(function()
		    for _, plr in pairs(Players:GetPlayers()) do
			    if plr ~= LocalPlayer and plr.Character then
				    local targetRoot = getRoot(plr.Character)
				    local targetHumanoid = getHumanoid(plr.Character)
				    if targetRoot and targetHumanoid and targetHumanoid.Health > 0 then
					    safeTeleport(targetRoot.CFrame)
					    task.wait(0.1)
					    ReplicatedStorage.Remotes.Gameplay.MeleeHit:FireServer(targetHumanoid)
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
				    local target = Players:FindFirstChild(plr)
				    if target and target.Character then
					    local root = getRoot(target.Character)
					    if root then
						    ReplicatedStorage.Remotes.Gameplay.ShootGun:FireServer(root.Position)
					    end
				    end
				    break
			    end
		    end
	    end)
	end

	if flags.aimbot then performAimbot() end

    if flags.autoTakeGun then
	    pcall(function()
		    local myRoot = getRoot(LocalPlayer.Character)
		    if myRoot then
			    for _, obj in pairs(Workspace:GetDescendants()) do
				    if obj.Name:lower():find("gun") then
					    local part = obj:IsA("BasePart") and obj or obj:FindFirstChild("Handle")
					    if part then
						    safeTeleport(part.CFrame)
					    end
				    end
			    end
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

LocalPlayer.CharacterAdded:Connect(function(newCharacter)
	task.wait(0.2)
	clearFlyForces()
	stopCoinFarmTween()
	local humanoid = getHumanoid(newCharacter)
	if humanoid then humanoid.WalkSpeed, humanoid.JumpPower = cfg.speedHack, cfg.jumpPower end
end)

notify("ZyphraxHub MM2", "Script loaded successfully!")
