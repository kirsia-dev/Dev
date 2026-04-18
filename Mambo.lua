if not game:IsLoaded() then game.Loaded:Wait() end
cloneref = cloneref or function(o) return o end
HttpService = cloneref(game:GetService("HttpService"))
StarterGui = cloneref(game:GetService("StarterGui"))
Players = cloneref(game:GetService("Players"))
RbxAnalyticsService = cloneref(game:GetService("RbxAnalyticsService"))
LocalPlayer = Players.LocalPlayer
local API_ENDPOINT = "https://api.vorahub.xyz/redeem"
local _original_request = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
if restorefunction then pcall(function() restorefunction(_original_request) end) end
function is_tampered(func) if not func then return false end; local isCKey = false; pcall(function() if iscclosure and iscclosure(func) then isCKey = true end end); if islclosure and islclosure(func) then return true end; return false end
function makeRequest(url, payload) local req = _original_request; if not req then return "unsupported" end; local success, response = pcall(function() return req({Url = url, Method = "POST", Headers = {["Content-Type"] = "application/json", ["User-Agent"] = "VoraHub-Client/1.0"}, Body = payload}) end); if success and response and type(response) == "table" then if not response.StatusCode or not response.Body then return nil end end; return (success and response) and response.Body or nil end
function getExecutorName() local ok, name = pcall(function() if identifyexecutor then return identifyexecutor() end; return nil end); return (ok and name and type(name) == "string" and name ~= "" and name) or "Unknown" end
function redeem(key) key = (key or ""):gsub("%s+", ""):upper(); if #key < 6 then return false end; task.wait(math.random(1,4)/10); local HWID = RbxAnalyticsService:GetClientId(); local payload = HttpService:JSONEncode({key = key, hwid = HWID, username = LocalPlayer.Name, executor = getExecutorName(), gameId = game.GameId, placeId = game.PlaceId, timestamp = tick()}); local response = makeRequest(API_ENDPOINT, payload); if not response then return "connection_error" end; if response == "unsupported" then return "unsupported" end; local ok, data = pcall(function() return HttpService:JSONDecode(response) end); if not ok or not data or not data.status then return "invalid_response" end; if data.status == "premium" then return true end; if data.status == "kick" or data.reason == "HWID_LIMIT" then return "hwid_limit" end; return false end
key = (_G.script_key and tostring(_G.script_key)) or ""
if is_tampered and is_tampered(_original_request) then LocalPlayer:Kick("Security Breach: Request Hook Detected (Code: TAMPER-01)"); while true do end end
if #key < 6 then StarterGui:SetCore("SendNotification", {Title = "VORAHUB", Text = "Key Invalid / Expired", Duration = 5}); task.wait(2); LocalPlayer:Kick("[VORAHUB] INVALID KEY\nGet key at: discord.gg/vorahub"); task.wait(9e9); return end
function generateFakeKey() local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"; local k = ""; for i = 1, 16 do local r = math.random(1, #chars); k = k .. chars:sub(r, r) end; return k end
StarterGui:SetCore("SendNotification", {Title = "VORAHUB", Text = "Validating Key...", Duration = 3})
realKeyData = {type = "REAL", payload = key}
local fakeKeyData = {type = "FAKE", payload = generateFakeKey()}
local securityChecks = {realKeyData, fakeKeyData}
for i = #securityChecks, 2, -1 do local j = math.random(i); securityChecks[i], securityChecks[j] = securityChecks[j], securityChecks[i] end
local finalRealResult = nil; local securityBreach = false
for i, check in ipairs(securityChecks) do local res = redeem(check.payload); if check.type == "FAKE" then if res == true then securityBreach = true end elseif check.type == "REAL" then finalRealResult = res end end
if securityBreach then LocalPlayer:Kick("Security Breach: Hook Detected (Error H-02)"); task.wait(9e9); return end
local result = finalRealResult
if result == true then StarterGui:SetCore("SendNotification", {Title = "VORAHUB PREMIUM", Text = "Key Valid! Loading...", Duration = 5})
elseif result == "hwid_limit" then LocalPlayer:Kick("[VORAHUB] HWID LIMIT REACHED"); task.wait(9e9); return
elseif result == "connection_error" then LocalPlayer:Kick("[VORAHUB] CONNECTION ERROR"); task.wait(9e9); return
else StarterGui:SetCore("SendNotification", {Title = "VORAHUB", Text = "Key Invalid / Expired", Duration = 5}); task.wait(2); LocalPlayer:Kick("[VORAHUB] INVALID KEY\nGet key at: discord.gg/vorahub"); task.wait(9e9); return end
if getgenv().vorahub_Running then warn("Script already running!"); return end
repeat task.wait() until game.GameId ~= 0
function missing(t, f, fb) if type(f) == t then return f end; return fb end
cloneref = missing("function", cloneref, function(...) return ... end)
getgc = missing("function", getgc or get_gc_objects)
getconnections = missing("function", getconnections or get_signal_cons)
Services = setmetatable({}, {__index = function(self, name) local success, cache = pcall(function() return cloneref(game:GetService(name)) end); if success then rawset(self, name, cache); return cache else error("Invalid Service: "..tostring(name)) end end})
local Players = Services.Players
local Plr = Players.LocalPlayer
local Char = Plr.Character or Plr.CharacterAdded:Wait()
local PGui = Plr:WaitForChild("PlayerGui")
local Lighting = game:GetService("Lighting")
local RS = Services.ReplicatedStorage
local RunService = Services.RunService
local HttpService = Services.HttpService
local GuiService = Services.GuiService
local TeleportService = Services.TeleportService
local Marketplace = Services.MarketplaceService
local UIS = Services.UserInputService
local VirtualUser = Services.VirtualUser
local v, Asset = pcall(function() return Marketplace:GetProductInfo(game.PlaceId) end)
local assetName = "Sailor Piece"
if v and Asset then assetName = Asset.Name end
local Support = {Webhook = (typeof(request) == "function" or typeof(http_request) == "function"), Clipboard = (typeof(setclipboard) == "function"), ClipboardRead = (typeof(getclipboard) == "function" or typeof(clipboard) == "function"), FileIO = (typeof(writefile) == "function" and typeof(isfile) == "function"), QueueOnTeleport = (typeof(queue_on_teleport) == "function"), Connections = (typeof(getconnections) == "function"), FPS = (typeof(setfpscap) == "function"), Proximity = (typeof(fireproximityprompt) == "function")}
local executorName = (identifyexecutor and identifyexecutor() or "Unknown"):lower()
local isXeno = string.find(executorName, "xeno") ~= nil
local LimitedExecutors = {"xeno"}
local isLimitedExecutor = false
for _, name in ipairs(LimitedExecutors) do if string.find(executorName, name) then isLimitedExecutor = true break end end
local repo = "https://raw.githubusercontent.com/Andrazx23/voralib/refs/heads/main/"
local FlowUI = loadstring(game:HttpGet(repo .. "flow%20ui/ui.lua"))()
local Library = FlowUI.new({Name = "VoraHub", AccentColor = Color3.fromRGB(0, 140, 210), AutoConfig = false})
getgenv().vorahub_Running = true
local Toggles = {}
local Options = {}
function AddSliderToggle(group, id, text, defaultToggle, defaultSlider, min, max, rounding, disabled)
    local toggle = group:AddToggle({Name = text, Default = defaultToggle or false, Disabled = disabled, Callback = function(v) Toggles[id] = v; if slider then slider:SetVisible(v) end end})
    local slider = group:AddSlider({Name = text .. " Value", Min = min or 0, Max = max or 100, Default = defaultSlider or 0, Increment = rounding and (10^(-rounding)) or 1, Visible = defaultToggle or false, Disabled = disabled, Callback = function(v) Options[id .. "Value"] = v end})
    Toggles[id] = defaultToggle or false
    Options[id .. "Value"] = defaultSlider or 0
    return toggle, slider
end
local Shared = {GlobalPrio = "FARM", Cached = {Inv = {}, Accessories = {}, RawWeapCache = {Sword = {}, Melee = {}}}, Farm = true, Recovering = false, MovingIsland = false, Island = "", Target = nil, KillTick = 0, TargetValid = false, QuestNPC = "", MobIdx = 1, AllMobIdx = 1, BossIdx = 1, WeapRotationIdx = 1, ComboIdx = 1, ParsedCombo = {}, RawWeapCache = {Sword = {}, Melee = {}}, ActiveWeap = "", ArmHaki = false, BossTIMap = {}, BossInternalName = {}, InventorySynced = false, Stats = {}, Settings = {}, GemStats = {}, SkillTree = {Nodes = {}, Points = 0}, Passives = {}, SpecStatsSlider = {}, ArtifactSession = {Inventory = {}, Dust = 0, InvCount = 0}, UpBlacklist = {}, MerchantBusy = false, LocalMerchantTime = 0, LastTimerTick = tick(), FreezeApplied = false, MerchantExecute = false, FirstMerchantSync = false, CurrentStock = {}, LastM1 = 0, LastWRSwitch = 0, LastSwitch = {Title = "", Rune = ""}, LastBuildSwitch = 0, LastDungeon = 0, FarmMoveTween = nil, AutoDashLast = 0, AutoDashFwdSlot = 0, AutoDashPhysicsConn = nil, AltDamage = {}, AltActive = false, TradeState = {}}
local Script_Start_Time = tick()
local StartStats = {Level = Plr.Data.Level.Value, Money = Plr.Data.Money.Value, Gems = Plr.Data.Gems.Value, Bounty = (Plr:FindFirstChild("leaderstats") and Plr.leaderstats:FindFirstChild("Bounty") and Plr.leaderstats.Bounty.Value) or 0}
local function GetSessionTime() local seconds = math.floor(tick() - Script_Start_Time); local hours = math.floor(seconds / 3600); local mins = math.floor((seconds % 3600) / 60); return string.format("%dh %02dm", hours, mins) end
local function GetSafeModule(parent, name) local obj = parent:FindFirstChild(name); if obj and obj:IsA("ModuleScript") then local success, result = pcall(require, obj); if success then return result end end; return nil end
local function GetRemote(parent, pathString) local current = parent; for _, name in ipairs(pathString:split(".")) do if not current then return nil end; current = current:FindFirstChild(name) end; return current end
local function SafeInvoke(remote, ...) local args = {...}; local result = nil; task.spawn(function() local success, res = pcall(function() return remote:InvokeServer(table.unpack(args)) end); result = res end); local start = tick(); repeat task.wait() until result ~= nil or (tick() - start) > 2; return result end
local function fire_event(signal, ...) if firesignal then return firesignal(signal, ...) elseif getconnections then for _, connection in ipairs(getconnections(signal)) do if connection.Function then task.spawn(connection.Function, ...) end end else warn("Your executor does not support firesignal or getconnections.") end end
local _DR = GetRemote(RS, "RemoteEvents.DashRemote")
local _FS = (_DR and _DR.FireServer)
local Remotes = {
    SettingsToggle = GetRemote(RS, "RemoteEvents.SettingsToggle"), SettingsSync = GetRemote(RS, "RemoteEvents.SettingsSync"), UseCode = GetRemote(RS, "RemoteEvents.CodeRedeem"),
    M1 = GetRemote(RS, "CombatSystem.Remotes.RequestHit"), EquipWeapon = GetRemote(RS, "Remotes.EquipWeapon"), UseSkill = GetRemote(RS, "AbilitySystem.Remotes.RequestAbility"), UseFruit = GetRemote(RS, "RemoteEvents.FruitPowerRemote"),
    QuestAccept = GetRemote(RS, "RemoteEvents.QuestAccept"), QuestAbandon = GetRemote(RS, "RemoteEvents.QuestAbandon"), UseItem = GetRemote(RS, "Remotes.UseItem"), SlimeCraft = GetRemote(RS, "Remotes.RequestSlimeCraft"), GrailCraft = GetRemote(RS, "Remotes.RequestGrailCraft"),
    RerollSingleStat = GetRemote(RS, "Remotes.RerollSingleStat"), SkillTreeUpgrade = GetRemote(RS, "RemoteEvents.SkillTreeUpgrade"), Enchant = GetRemote(RS, "Remotes.EnchantAccessory"), Blessing = GetRemote(RS, "Remotes.BlessWeapon"),
    ArtifactSync = GetRemote(RS, "RemoteEvents.ArtifactDataSync"), ArtifactClaim = GetRemote(RS, "RemoteEvents.ArtifactMilestoneClaimReward"), MassDelete = GetRemote(RS, "RemoteEvents.ArtifactMassDeleteByUUIDs"), MassUpgrade = GetRemote(RS, "RemoteEvents.ArtifactMassUpgrade"),
    ArtifactLock = GetRemote(RS, "RemoteEvents.ArtifactLock"), ArtifactUnequip = GetRemote(RS, "RemoteEvents.ArtifactUnequip"), ArtifactEquip = GetRemote(RS, "RemoteEvents.ArtifactEquip"),
    Roll_Trait = GetRemote(RS, "RemoteEvents.TraitReroll"), TraitAutoSkip = GetRemote(RS, "RemoteEvents.TraitUpdateAutoSkip"), TraitConfirm = GetRemote(RS, "RemoteEvents.TraitConfirm"), SpecPassiveReroll = GetRemote(RS, "RemoteEvents.SpecPassiveReroll"),
    ArmHaki = GetRemote(RS, "RemoteEvents.HakiRemote"), ObserHaki = GetRemote(RS, "RemoteEvents.ObservationHakiRemote"), ConquerorHaki = GetRemote(RS, "Remotes.ConquerorHakiRemote"),
    TP_Portal = GetRemote(RS, "Remotes.TeleportToPortal"), OpenDungeon = GetRemote(RS, "Remotes.RequestDungeonPortal"), DungeonWaveVote = GetRemote(RS, "Remotes.DungeonWaveVote"), DungeonWaveReplayVote = GetRemote(RS, "Remotes.DungeonWaveReplayVote"),
    EquipTitle = GetRemote(RS, "RemoteEvents.TitleEquip"), TitleUnequip = GetRemote(RS, "RemoteEvents.TitleUnequip"), EquipRune = GetRemote(RS, "Remotes.EquipRune"), LoadoutLoad = GetRemote(RS, "RemoteEvents.LoadoutLoad"), AddStat = GetRemote(RS, "RemoteEvents.AllocateStat"),
    OpenMerchant = GetRemote(RS, "Remotes.MerchantRemotes.OpenMerchantUI"), MerchantBuy = GetRemote(RS, "Remotes.MerchantRemotes.PurchaseMerchantItem"), ValentineBuy = GetRemote(RS, "Remotes.ValentineMerchantRemotes.PurchaseValentineMerchantItem"), StockUpdate = GetRemote(RS, "Remotes.MerchantRemotes.MerchantStockUpdate"),
    SummonBoss = GetRemote(RS, "Remotes.RequestSummonBoss"), JJKSummonBoss = GetRemote(RS, "Remotes.RequestSpawnStrongestBoss"), RimuruBoss = GetRemote(RS, "RemoteEvents.RequestSpawnRimuru"), AnosBoss = GetRemote(RS, "Remotes.RequestSpawnAnosBoss"), TrueAizenBoss = GetRemote(RS, "RemoteEvents.RequestSpawnTrueAizen"), AtomicBoss = GetRemote(RS, "RemoteEvents.RequestSpawnAtomic"),
    ReqInventory = GetRemote(RS, "Remotes.RequestInventory"), Ascend = GetRemote(RS, "RemoteEvents.RequestAscend"), ReqAscend = GetRemote(RS, "RemoteEvents.GetAscendData"), CloseAscend = GetRemote(RS, "RemoteEvents.CloseAscendUI"),
    TradeRespond = GetRemote(RS, "Remotes.TradeRemotes.RespondToRequest"), TradeSend = GetRemote(RS, "Remotes.TradeRemotes.SendTradeRequest"), TradeAddItem = GetRemote(RS, "Remotes.TradeRemotes.AddItemToTrade"), TradeReady = GetRemote(RS, "Remotes.TradeRemotes.SetReady"), TradeConfirm = GetRemote(RS, "Remotes.TradeRemotes.ConfirmTrade"), TradeUpdated = GetRemote(RS, "Remotes.TradeRemotes.TradeUpdated"),
    HakiStateUpdate = GetRemote(RS, "RemoteEvents.HakiStateUpdate"), UpCurrency = GetRemote(RS, "RemoteEvents.UpdateCurrency"), UpInventory = GetRemote(RS, "Remotes.UpdateInventory"), UpPlayerStats = GetRemote(RS, "RemoteEvents.UpdatePlayerStats"), UpAscend = GetRemote(RS, "RemoteEvents.AscendDataUpdate"), UpStatReroll = GetRemote(RS, "RemoteEvents.StatRerollUpdate"),
    SpecPassiveUpdate = GetRemote(RS, "RemoteEvents.SpecPassiveDataUpdate"), SpecPassiveSkip = GetRemote(RS, "RemoteEvents.SpecPassiveUpdateAutoSkip"), UpSkillTree = GetRemote(RS, "RemoteEvents.SkillTreeUpdate"), BossUIUpdate = GetRemote(RS, "Remotes.BossUIUpdate"), TitleSync = GetRemote(RS, "RemoteEvents.TitleDataSync"),
}
local Modules = {
    BossConfig = GetSafeModule(RS.Modules, "BossConfig") or {Bosses = {}}, TimedConfig = GetSafeModule(RS.Modules, "TimedBossConfig"), SummonConfig = GetSafeModule(RS.Modules, "SummonableBossConfig"),
    Merchant = GetSafeModule(RS.Modules, "MerchantConfig") or {ITEMS = {}}, ValentineConfig = GetSafeModule(RS.Modules, "ValentineMerchantConfig"),
    Title = GetSafeModule(RS.Modules, "TitlesConfig") or {}, Quests = GetSafeModule(RS.Modules, "QuestConfig") or {RepeatableQuests = {}, Questlines = {}},
    WeaponClass = GetSafeModule(RS.Modules, "WeaponClassification") or {Tools = {}}, Fruits = GetSafeModule(RS:FindFirstChild("FruitPowerSystem") or game, "FruitPowerConfig") or {Powers = {}}, ArtifactConfig = GetSafeModule(RS.Modules, "ArtifactConfig"),
    Stats = GetSafeModule(RS.Modules, "StatRerollConfig"), Codes = GetSafeModule(RS, "CodesConfig") or {Codes = {}}, ItemRarity = GetSafeModule(RS.Modules, "ItemRarityConfig"), Trait = GetSafeModule(RS.Modules, "TraitConfig") or {Traits = {}},
    Race = GetSafeModule(RS.Modules, "RaceConfig") or {Races = {}}, Clan = GetSafeModule(RS.Modules, "ClanConfig") or {Clans = {}}, SpecPassive = GetSafeModule(RS.Modules, "SpecPassiveConfig"),
}
local MerchantItemList = Modules.Merchant.ITEMS
local SortedTitleList = Modules.Title:GetSortedTitleIds()
local PATH = {Mobs = workspace:WaitForChild('NPCs'), InteractNPCs = workspace:WaitForChild('ServiceNPCs')}
local function GetServiceNPC(name) return PATH.InteractNPCs:FindFirstChild(name) end
local NPCs = {Merchant = {Regular = GetServiceNPC("MerchantNPC"), Dungeon = GetServiceNPC("DungeonMerchantNPC"), Valentine = GetServiceNPC("ValentineMerchantNPC")}}
local UI = {Merchant = {Regular = PGui:WaitForChild("MerchantUI"), Dungeon = PGui:WaitForChild("DungeonMerchantUI"), Valentine = PGui:FindFirstChild("ValentineMerchantUI")}}
local pingUI = PGui:WaitForChild("QuestPingUI")
local SummonMap = {}
local function GetRemoteBossArg(name) local RemoteBossMap = {["strongestinhistory"] = "StrongestHistory", ["strongestoftoday"] = "StrongestToday", ["strongesthistory"] = "StrongestHistory", ["strongesttoday"] = "StrongestToday"}; return RemoteBossMap[name:lower()] or name end
local IslandCrystals = {
    ["Starter"] = workspace:FindFirstChild("StarterIsland") and workspace.StarterIsland:FindFirstChild("SpawnPointCrystal_Starter"), ["Jungle"] = workspace:FindFirstChild("JungleIsland") and workspace.JungleIsland:FindFirstChild("SpawnPointCrystal_Jungle"),
    ["Desert"] = workspace:FindFirstChild("DesertIsland") and workspace.DesertIsland:FindFirstChild("SpawnPointCrystal_Desert"), ["Snow"] = workspace:FindFirstChild("SnowIsland") and workspace.SnowIsland:FindFirstChild("SpawnPointCrystal_Snow"),
    ["Sailor"] = workspace:FindFirstChild("SailorIsland") and workspace.SailorIsland:FindFirstChild("SpawnPointCrystal_Sailor"), ["Shibuya"] = workspace:FindFirstChild("ShibuyaStation") and workspace.ShibuyaStation:FindFirstChild("SpawnPointCrystal_Shibuya"),
    ["HuecoMundo"] = workspace:FindFirstChild("HuecoMundo") and workspace.HuecoMundo:FindFirstChild("SpawnPointCrystal_HuecoMundo"), ["Boss"] = workspace:FindFirstChild("BossIsland") and workspace.BossIsland:FindFirstChild("SpawnPointCrystal_Boss"),
    ["Dungeon"] = workspace:FindFirstChild("Main Temple") and workspace["Main Temple"]:FindFirstChild("SpawnPointCrystal_Dungeon"), ["Shinjuku"] = workspace:FindFirstChild("ShinjukuIsland") and workspace.ShinjukuIsland:FindFirstChild("SpawnPointCrystal_Shinjuku"),
    ["Valentine"] = workspace:FindFirstChild("ValentineIsland") and workspace.ValentineIsland:FindFirstChild("SpawnPointCrystal_Valentine"), ["Slime"] = workspace:FindFirstChild("SlimeIsland") and workspace.SlimeIsland:FindFirstChild("SpawnPointCrystal_Slime"),
    ["Academy"] = workspace:FindFirstChild("AcademyIsland") and workspace.AcademyIsland:FindFirstChild("SpawnPointCrystal_Academy"), ["Judgement"] = workspace:FindFirstChild("JudgementIsland") and workspace.JudgementIsland:FindFirstChild("SpawnPointCrystal_Judgement"),
    ["SoulSociety"] = workspace:FindFirstChild("SoulSocietyIsland") and workspace.SoulSocietyIsland:FindFirstChild("SpawnPointCrystal_SoulSociety"), ["Ninja"] = workspace:FindFirstChild("NinjaIsland") and workspace.NinjaIsland:FindFirstChild("SpawnPointCrystal_Ninja"),
    ["Lawless"] = workspace:FindFirstChild("LawlessIsland") and workspace.LawlessIsland:FindFirstChild("SpawnPointCrystal_Lawless"), ["Tower"] = workspace:FindFirstChild("TowerIsland") and workspace.TowerIsland:FindFirstChild("SpawnPointCrystal_Tower"),
}
local Connections = {Player_General = nil, Idled = nil, Merchant = nil, Dash = nil, Knockback = {}, Reconnect = nil}
local Tables = {
    AscendLabels = {}, DiffList = {"Normal", "Medium", "Hard", "Extreme"}, MobList = {}, MiniBossList = {"ThiefBoss", "MonkeyBoss", "DesertBoss", "SnowBoss", "PandaMiniBoss"}, BossList = {}, AllBossList = {}, AllNPCList = {}, AllEntitiesList = {}, SummonList = {},
    OtherSummonList = {"StrongestHistory", "StrongestToday", "Rimuru", "Anos", "TrueAizen", "Atomic"}, Weapon = {"Melee", "Sword", "Power"}, ManualWeaponClass = {["Invisible"] = "Power", ["Bomb"] = "Power", ["Quake"] = "Power"},
    MerchantList = {}, ValentineMerchantList = {}, Rarities = {"Common", "Rare", "Epic", "Legendary", "Mythical", "Secret", "Aura Crate", "Cosmetic Crate"}, CraftItemList = {"SlimeKey", "DivineGrail"}, UnlockedTitle = {}, TitleCategory = {"None", "Best EXP", "Best Money & Gem", "Best Luck", "Best DMG"}, TitleList = {},
    BuildList = {"1", "2", "3", "4", "5", "None"}, TraitList = {}, RarityWeight = {["Secret"] = 1, ["Mythical"] = 2, ["Legendary"] = 3, ["Epic"] = 4, ["Rare"] = 5, ["Uncommon"] = 6, ["Common"] = 7}, RaceList = {}, ClanList = {}, RuneList = {"None"}, SpecPassive = {},
    GemStat = Modules.Stats.StatKeys, GemRank = Modules.Stats.RankOrder, OwnedWeapon = {}, AllOwnedWeapons = {}, OwnedAccessory = {}, QuestlineList = {}, OwnedItem = {},
    IslandList = {"Starter", "Jungle", "Desert", "Snow", "Sailor", "Shibuya", "HuecoMundo", "Boss", "Dungeon", "Shinjuku", "Valentine", "Slime", "Academy", "Judgement", "SoulSociety", "Ninja", "Lawless", "Tower"},
    NPC_QuestList = {"DungeonUnlock", "SlimeKeyUnlock"}, NPC_MiscList = {"Artifacts", "Blessing", "Enchant", "SkillTree", "Cupid", "ArmHaki", "Observation", "Conqueror"}, DungeonList = {"CidDungeon", "RuneDungeon", "DoubleDungeon", "BossRush"},
    NPC_MovesetList = {}, NPC_MasteryList = {}, MobToIsland = {}
}
local allSets = {}
for setName, _ in pairs(Modules.ArtifactConfig.Sets) do table.insert(allSets, setName) end
local allStats = {}
for statKey, data in pairs(Modules.ArtifactConfig.Stats) do table.insert(allStats, statKey) end
if Modules.TimedConfig and Modules.TimedConfig.Bosses then
    for internalName, data in pairs(Modules.TimedConfig.Bosses) do
        table.insert(Tables.BossList, data.displayName)
        local tpName = data.spawnLocation:gsub(" Island", ""):gsub(" Station", "")
        if data.spawnLocation == "Hueco Mundo Island" then tpName = "HuecoMundo" end
        if data.spawnLocation == "Judgement Island" then tpName = "Judgement" end
        Shared.BossTIMap[data.displayName] = tpName
        Shared.BossInternalName[data.displayName] = internalName
    end
    table.sort(Tables.BossList)
end
if Modules.SummonConfig and Modules.SummonConfig.Bosses then
    table.clear(Tables.SummonList)
    for internalId, data in pairs(Modules.SummonConfig.Bosses) do
        table.insert(Tables.SummonList, data.displayName)
        SummonMap[data.displayName] = data.bossId
    end
    table.sort(Tables.SummonList)
end
for bossInternalName, _ in pairs(Modules.BossConfig.Bosses) do local clean = bossInternalName:gsub("Boss$", ""); table.insert(Tables.AllBossList, clean) end
table.sort(Tables.AllBossList)
for itemName in pairs(MerchantItemList) do table.insert(Tables.MerchantList, itemName) end
local function GetBestOwnedTitle(category)
    if #Tables.UnlockedTitle == 0 then return nil end
    local bestTitleId = nil; local highestValue = -1
    local statMap = {["Best EXP"] = "XPPercent", ["Best Money & Gem"] = "MoneyPercent", ["Best Luck"] = "LuckPercent", ["Best DMG"] = "DamagePercent"}
    local targetStat = statMap[category]; if not targetStat then return nil end
    for _, titleId in ipairs(Tables.UnlockedTitle) do
        local data = Modules.Title.Titles[titleId]
        if data and data.statBonuses and data.statBonuses[targetStat] then
            local val = data.statBonuses[targetStat]
            if val > highestValue then highestValue = val; bestTitleId = titleId end
        end
    end
    return bestTitleId
end
for _, v in ipairs(SortedTitleList) do table.insert(Tables.TitleList, v) end
local CombinedTitleList = {}
for _, cat in ipairs(Tables.TitleCategory) do table.insert(CombinedTitleList, cat) end
for _, title in ipairs(Tables.TitleList) do table.insert(CombinedTitleList, title) end
table.clear(Tables.TraitList)
for name, _ in pairs(Modules.Trait.Traits) do table.insert(Tables.TraitList, name) end
table.sort(Tables.TraitList, function(a, b) local rarityA = Modules.Trait.Traits[a].Rarity; local rarityB = Modules.Trait.Traits[b].Rarity; if rarityA ~= rarityB then return (Tables.RarityWeight[rarityA] or 99) < (Tables.RarityWeight[rarityB] or 99) end; return a < b end)
table.clear(Tables.RaceList)
for name, _ in pairs(Modules.Race.Races) do table.insert(Tables.RaceList, name) end
table.sort(Tables.RaceList, function(a, b) local rarityA = Modules.Race.Races[a].rarity; local rarityB = Modules.Race.Races[b].rarity; if rarityA ~= rarityB then return (Tables.RarityWeight[rarityA] or 99) < (Tables.RarityWeight[rarityB] or 99) end; return a < b end)
table.clear(Tables.ClanList)
for name, _ in pairs(Modules.Clan.Clans) do table.insert(Tables.ClanList, name) end
table.sort(Tables.ClanList, function(a, b) local rarityA = Modules.Clan.Clans[a].rarity; local rarityB = Modules.Clan.Clans[b].rarity; if rarityA ~= rarityB then return (Tables.RarityWeight[rarityA] or 99) < (Tables.RarityWeight[rarityB] or 99) end; return a < b end)
if Modules.SpecPassive and Modules.SpecPassive.Passives then for name, _ in pairs(Modules.SpecPassive.Passives) do table.insert(Tables.SpecPassive, name) end; table.sort(Tables.SpecPassive) end
for k, _ in pairs(Modules.Quests.Questlines) do table.insert(Tables.QuestlineList, k) end
table.sort(Tables.QuestlineList)
for _, v in ipairs(PATH.InteractNPCs:GetChildren()) do table.insert(Tables.AllNPCList, v.Name) end
local function Cleanup(tbl) for key, value in pairs(tbl) do if typeof(value) == "RBXScriptConnection" then value:Disconnect(); tbl[key] = nil elseif typeof(value) == 'thread' then task.cancel(value); tbl[key] = nil elseif type(value) == 'table' then Cleanup(value) end end end
local Flags = {}
function Thread(featurePath, featureFunc, isEnabled, ...)
    local pathParts = featurePath:split("."); local currentTable = Flags
    for i = 1, #pathParts - 1 do local part = pathParts[i]; if not currentTable[part] then currentTable[part] = {} end; currentTable = currentTable[part] end
    local flagKey = pathParts[#pathParts]; local activeThread = currentTable[flagKey]
    if isEnabled then
        if not activeThread or coroutine.status(activeThread) == "dead" then
            local newThread = task.spawn(featureFunc, ...)
            currentTable[flagKey] = newThread
        end
    else
        if activeThread and typeof(activeThread) == 'thread' then task.cancel(activeThread); currentTable[flagKey] = nil end
    end
end
local function SafeLoop(name, func) return function() local success, err = pcall(func); if not success then Library:Notify({Title = "Error", Description = "Error in ["..name.."]: "..tostring(err), Duration = 10}); warn("Error in ["..name.."]: "..tostring(err)) end end end
local function CommaFormat(n) local s = tostring(n); return s:reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "") end
local function Abbreviate(n) local abbrev = {{1e12, "T"}, {1e9, "B"}, {1e6, "M"}, {1e3, "K"}}; for _, v in ipairs(abbrev) do if n >= v[1] then return string.format("%.1f%s", n / v[1], v[2]) end end; return tostring(n) end
local function GetFormattedItemSections(itemSourceTable, isNewItems)
    local categories = {Chests = {}, Rerolls = {}, Keys = {}, Materials = {}, Gears = {}, Accessories = {}, Runes = {}, Others = {}}
    local chestOrder = {"Common", "Rare", "Epic", "Legendary", "Mythical", "Secret", "Aura Crate", "Cosmetic Crate"}
    local matOrder = {["Wood"] = 1, ["Iron"] = 2, ["Obsidian"] = 3, ["Mythril"] = 4, ["Adamantite"] = 5}
    local rarityOrder = {["Common"] = 1, ["Rare"] = 2, ["Epic"] = 3, ["Legendary"] = 4}
    local gearTypeOrder = {["Helmet"] = 1, ["Gloves"] = 2, ["Body"] = 3, ["Boots"] = 4}
    local totalDust = 0
    for key, data in pairs(itemSourceTable) do
        local name, qty
        if type(data) == "table" and data.name then name = tostring(data.name); qty = tonumber(data.quantity) or 1 else name = tostring(key); qty = tonumber(data) or 1 end
        if name:find("Auto%-deleted") then local dustValue = name:match("%+(%d+) dust"); if dustValue then totalDust = totalDust + (qty * tonumber(dustValue)) end; continue end
        local totalInInv = 0
        if isNewItems then for _, item in pairs(Shared.Cached.Inv or {}) do if item.name == name then totalInInv = item.quantity break end end end
        local entryText = isNewItems and string.format("+ [%d] %s [Total: %s]", qty, name, CommaFormat(totalInInv)) or string.format("- %s: %s", name, CommaFormat(qty))
        if name:find("Chest") or name == "Aura Crate" or name == "Cosmetic Crate" then
            local weight = 99; for i, v in ipairs(chestOrder) do if name:find(v) then weight = i break end end; table.insert(categories.Chests, {Text = entryText, Weight = weight})
        elseif name:find("Reroll") then table.insert(categories.Rerolls, entryText)
        elseif name:find("Key") then table.insert(categories.Keys, entryText)
        elseif matOrder[name] then table.insert(categories.Materials, {Text = entryText, Weight = matOrder[name]})
        elseif name:find("Helmet") or name:find("Gloves") or name:find("Body") or name:find("Boots") then
            local rWeight, tWeight = 99, 99; for k, v in pairs(rarityOrder) do if name:find(k) then rWeight = v break end end; for k, v in pairs(gearTypeOrder) do if name:find(k) then tWeight = v break end end; table.insert(categories.Gears, {Text = entryText, Rarity = rWeight, Type = tWeight})
        elseif name:find("Rune") then table.insert(categories.Runes, entryText)
        else table.insert(categories.Others, entryText) end
    end
    if totalDust > 0 then local dustText = isNewItems and string.format("+ [%d] Dust", totalDust) or string.format("- Dust: %s", CommaFormat(totalDust)); table.insert(categories.Materials, 1, {Text = dustText, Weight = 0}) end
    local result = ""
    local function process(title, tbl, sortFunc)
        if #tbl > 0 then
            if sortFunc then table.sort(tbl, sortFunc) end
            result = result .. "**< " .. title .. " >**\n```"
            for _, v in ipairs(tbl) do result = result .. (type(v) == "table" and v.Text or v) .. "\n" end
            result = result .. "```\n"
        end
    end
    process("Chests", categories.Chests, function(a,b) return a.Weight < b.Weight end)
    process("Rerolls", categories.Rerolls)
    process("Keys", categories.Keys)
    process("Materials", categories.Materials, function(a,b) return a.Weight < b.Weight end)
    process("Gears", categories.Gears, function(a,b) if a.Rarity ~= b.Rarity then return a.Rarity < b.Rarity end; return a.Type < b.Type end)
    process("Runes", categories.Runes)
    process("Others", categories.Others)
    return result
end
Remotes.UpInventory.OnClientEvent:Connect(function(category, data)
    Shared.InventorySynced = true
    if category == "Items" then
        Shared.Cached.Inv = data or {}
        table.clear(Tables.OwnedItem); for _, item in pairs(data) do if not table.find(Tables.OwnedItem, item.name) then table.insert(Tables.OwnedItem, item.name) end end; table.sort(Tables.OwnedItem)
        if Options.SelectedTradeItems then local dd = Options.SelectedTradeItems_dd; if dd then dd:SetOptions(Tables.OwnedItem) end end
    elseif category == "Runes" then
        table.clear(Tables.RuneList); table.insert(Tables.RuneList, "None"); for name, _ in pairs(data) do table.insert(Tables.RuneList, name) end; table.sort(Tables.RuneList)
        for _, dd in ipairs({"DefaultRune", "Rune_Mob", "Rune_Boss", "Rune_BossHP"}) do
            if Options[dd] then local ddObj = Options[dd.."_dd"]; if ddObj then local cur = ddObj.Value; ddObj:SetOptions(Tables.RuneList); if cur then ddObj:SetValue(cur) end end end
        end
    elseif category == "Accessories" then
        table.clear(Shared.Cached.Accessories); if type(data) == "table" then for _, accInfo in ipairs(data) do if accInfo.name and accInfo.quantity then Shared.Cached.Accessories[accInfo.name] = accInfo.quantity end end end
        table.clear(Tables.OwnedAccessory); local processed = {}; for _, item in ipairs(data) do if (item.enchantLevel or 0) < 10 and not processed[item.name] then table.insert(Tables.OwnedAccessory, item.name); processed[item.name] = true end end; table.sort(Tables.OwnedAccessory)
        if Options.SelectedEnchant then local dd = Options.SelectedEnchant_dd; if dd then dd:SetOptions(Tables.OwnedAccessory) end end
    elseif category == "Sword" or category == "Melee" then
        Shared.Cached.RawWeapCache[category] = data or {}
        table.clear(Tables.OwnedWeapon); local processed = {}
        for _, cat in pairs({"Sword", "Melee"}) do for _, item in ipairs(Shared.Cached.RawWeapCache[cat]) do if (item.blessingLevel or 0) < 10 and not processed[item.name] then table.insert(Tables.OwnedWeapon, item.name); processed[item.name] = true end end end; table.sort(Tables.OwnedWeapon)
        if Options.SelectedBlessing then local dd = Options.SelectedBlessing_dd; if dd then dd:SetOptions(Tables.OwnedWeapon) end end
        table.clear(Tables.AllOwnedWeapons); local allProcessed = {}
        for _, cat in pairs({"Sword", "Melee"}) do for _, item in ipairs(Shared.Cached.RawWeapCache[cat]) do if not allProcessed[item.name] then table.insert(Tables.AllOwnedWeapons, item.name); allProcessed[item.name] = true end end end; table.sort(Tables.AllOwnedWeapons)
        if Options.SelectedPassive then local dd = Options.SelectedPassive_dd; if dd then dd:SetOptions(Tables.AllOwnedWeapons) end end
    end
end)
RS.Remotes.NotifyItemDrop.OnClientEvent:Connect(function(data) if not data or type(data) ~= "table" or not data.name then return end; local name = data.name; local qty = data.quantity or 1; NewItemsBuffer[name] = (NewItemsBuffer[name] or 0) + qty end)
Remotes.StockUpdate.OnClientEvent:Connect(function(itemName, stockLeft) Shared.CurrentStock[itemName] = tonumber(stockLeft); if stockLeft == 0 then Library:Notify({Title = "Merchant", Description = "Bought: "..tostring(itemName), Duration = 2}) end end)
Remotes.UpSkillTree.OnClientEvent:Connect(function(data) if data then Shared.SkillTree.Nodes = data.Nodes or {}; Shared.SkillTree.SkillPoints = data.SkillPoints or 0 end end)
if Remotes.SettingsSync then Remotes.SettingsSync.OnClientEvent:Connect(function(data) Shared.Settings = data end) end
Remotes.ArtifactSync.OnClientEvent:Connect(function(data)
    Shared.ArtifactSession.Inventory = data.Inventory; Shared.ArtifactSession.Dust = data.Dust
    local counts = {Helmet = 0, Gloves = 0, Body = 0, Boots = 0}
    for _, item in pairs(data.Inventory) do if counts[item.Category] ~= nil then counts[item.Category] = counts[item.Category] + 1 end end
    if DustLabel then DustLabel:SetText("Dust: "..CommaFormat(data.Dust)) end
    if InvLabel_Helmet then InvLabel_Helmet:SetText("Helmet: "..counts.Helmet.."/500") end
    if InvLabel_Gloves then InvLabel_Gloves:SetText("Gloves: "..counts.Gloves.."/500") end
    if InvLabel_Body then InvLabel_Body:SetText("Body: "..counts.Body.."/500") end
    if InvLabel_Boots then InvLabel_Boots:SetText("Boots: "..counts.Boots.."/500") end
end)
Remotes.TitleSync.OnClientEvent:Connect(function(data) if data and data.unlocked then Tables.UnlockedTitle = data.unlocked end end)
Remotes.HakiStateUpdate.OnClientEvent:Connect(function(arg1, arg2) if arg1 == false then Shared.ArmHaki = false; return end; if arg1 == Plr then Shared.ArmHaki = arg2 end end)
if Remotes.BossUIUpdate then Remotes.BossUIUpdate.OnClientEvent:Connect(function(mode, data) if mode == "DamageStats" and data.stats then for _, info in pairs(data.stats) do if info.player and info.player:IsA("Player") then Shared.AltDamage[info.player.Name] = tonumber(info.percent) or 0 end end end end) end
Remotes.TradeUpdated.OnClientEvent:Connect(function(data) Shared.TradeState = data end)
PATH.Mobs.ChildRemoved:Connect(function(child) if child:IsA("Model") and child.Name:lower():find("boss") then table.clear(Shared.AltDamage); Shared.AltActive = false end end)
local function HandleUpgradeResult(res) if not res then return end; if res.success == false and res.message then end end
if Remotes.EnchantResult then Remotes.EnchantResult.OnClientEvent:Connect(HandleUpgradeResult) end
if Remotes.BlessingResult then Remotes.BlessingResult.OnClientEvent:Connect(HandleUpgradeResult) end
local NewItemsBuffer = {}
local function PostToWebhook()
    local url = Options.WebhookURL or ""
    if url == "" or not url:find("discord.com/api/webhooks/") then return end
    local selected = Options.SelectedData or {}
    local allowedRarity = Options.SelectedItemRarity or {}
    local data = Plr.Data
    local lstats = Plr:FindFirstChild("leaderstats")
    local bounty = lstats and lstats:FindFirstChild("Bounty") and lstats.Bounty.Value or 0
    local desc = "### Sailor Piece\n"
    if selected["Name"] then desc = desc .. string.format("\n👤 **Player:** ||%s||\n", Plr.Name) end
    if selected["Stats"] then
        local gainedLvl = data.Level.Value - StartStats.Level
        local gainedMoney = data.Money.Value - StartStats.Money
        local gainedGems = data.Gems.Value - StartStats.Gems
        local gainedBounty = bounty - StartStats.Bounty
        desc = desc .. string.format("📈 **Level:** `%s` (+%d)\n", CommaFormat(data.Level.Value), gainedLvl)
        desc = desc .. string.format("💰 **Currency:** 💵 %s (+%s) | 💎 %s (+%s)\n", Abbreviate(data.Money.Value), Abbreviate(gainedMoney), CommaFormat(data.Gems.Value), CommaFormat(gainedGems))
        desc = desc .. string.format("☠️ **Bounty:** %s (+%s)\n", Abbreviate(bounty), Abbreviate(gainedBounty))
    end
    desc = desc .. "\n"
    local function IsAllowed(itemName) local rarity = Modules.ItemRarity and Modules.ItemRarity.Items[itemName] or "Common"; return allowedRarity[rarity] == true end
    if selected["New Items"] and next(NewItemsBuffer) then
        local filteredNew = {}; for name, qty in pairs(NewItemsBuffer) do if IsAllowed(name) then filteredNew[name] = qty end end
        if next(filteredNew) then desc = desc .. "✨ **New Items**\n" .. GetFormattedItemSections(filteredNew, true) .. "\n" end
    end
    if selected["All Items"] then
        local filteredInv = {}; for _, item in pairs(Shared.Cached.Inv or {}) do if IsAllowed(item.name) then table.insert(filteredInv, item) end end
        if #filteredInv > 0 then desc = desc .. "---\n🎒 **Inventory**\n" .. GetFormattedItemSections(filteredInv, false) end
    end
    local fire = {"https://i.pinimg.com/736x/9b/d2/5f/9bd25f7e1d6e95c6253ef5e5f075f643.jpg", "https://i.pinimg.com/736x/f8/4d/c7/f84dc705b8f23ecdb8c650ec931b43c3.jpg"}
    local catLink = fire[math.random(1, #fire)] or ""
    local payload = {["embeds"] = {{["description"] = desc, ["color"] = tonumber("ffff77", 16), ["footer"] = {["text"] = string.format("VoraHub • Session: %s • %s", GetSessionTime(), DateTime.now():FormatLocalTime("L LT", "en-us"))}, ["thumbnail"] = {["url"] = catLink}}}}
    if Toggles.PingUser then payload["content"] = (Options.UID and Options.UID ~= "" and "<@"..Options.UID..">" or "@everyone") end
    task.spawn(function() pcall(function() request({Url = url, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = HttpService:JSONEncode(payload)}) end); NewItemsBuffer = {} end)
end
function gsc(guiObject) if not guiObject then return false end; local success = false; pcall(function() if Services.GuiService and Services.VirtualInputManager then Services.GuiService.SelectedObject = guiObject; task.wait(0.05); local keys = {Enum.KeyCode.Return, Enum.KeyCode.KeypadEnter, Enum.KeyCode.ButtonA}; for _, key in ipairs(keys) do Services.VirtualInputManager:SendKeyEvent(true, key, false, game); task.wait(0.03); Services.VirtualInputManager:SendKeyEvent(false, key, false, game); task.wait(0.03) end; Services.GuiService.SelectedObject = nil; success = true end end); return success end
local function UpdateAscendUI(data)
    if data.isMaxed then Tables.AscendLabels[1]:SetText("⭐ Max Ascension Reached!"); Tables.AscendLabels[1]:SetVisible(true); for i=2,10 do Tables.AscendLabels[i]:SetVisible(false) end; return end
    local reqs = data.requirements or {}
    for i=1,10 do
        local req = reqs[i]; local label = Tables.AscendLabels[i]
        if req then local displayText = req.display:gsub("<[^>]+>", ""); local status = req.completed and " ✅" or " ❌"; local progress = string.format(" (%s/%s)", CommaFormat(req.current), CommaFormat(req.needed)); label:SetText("- "..displayText..progress..status); label:SetVisible(true)
        else label:SetVisible(false) end
    end
end
local StatsLabel, SpecPassiveLabel
local function UpdateStatsLabel()
    if not StatsLabel then return end; local text = ""; local hasData = false
    for _, statName in ipairs(Tables.GemStat) do local data = Shared.GemStats[statName]; if data then hasData = true; text = text .. string.format("<b>%s:</b> %s\n", statName, tostring(data.Rank)) end end
    if not hasData then StatsLabel:SetText("<i>No data. Reroll once to sync.</i>") else StatsLabel:SetText(text) end
end
local function UpdateSpecPassiveLabel()
    if not SpecPassiveLabel then return end
    local text = ""; local selectedWeapons = Options.SelectedPassive or {}; local hasAny = false
    if type(Shared.Passives) ~= "table" then Shared.Passives = {} end
    for weaponName, isEnabled in pairs(selectedWeapons) do
        if isEnabled then hasAny = true; local data = Shared.Passives[weaponName]; local displayName = "None"
            if type(data) == "table" then displayName = tostring(data.Name or "None") elseif type(data) == "string" then displayName = data end
            text = text .. string.format("<b>%s:</b> %s\n", tostring(weaponName), displayName)
        end
    end
    if not hasAny then SpecPassiveLabel:SetText("<i>No weapons selected.</i>") else SpecPassiveLabel:SetText(text) end
end
local function GetCharacter() local c = Plr.Character; return (c and c:FindFirstChild("HumanoidRootPart") and c:FindFirstChildOfClass("Humanoid")) and c or nil end
local function PanicStop() Shared.Farm = false; Shared.AltActive = false; Shared.GlobalPrio = "FARM"; Shared.Target = nil; Shared.MovingIsland = false; if Shared.FarmMoveTween then pcall(function() Shared.FarmMoveTween:Cancel() end); Shared.FarmMoveTween = nil end; for _, toggle in pairs(Toggles) do if toggle.SetValue then toggle:SetValue(false) end end; local char = GetCharacter(); local root = char and char:FindFirstChild("HumanoidRootPart"); if root then root.AssemblyLinearVelocity = Vector3.zero; root.AssemblyAngularVelocity = Vector3.zero; root.CFrame = root.CFrame * CFrame.new(0,2,0) end; task.delay(0.5, function() Shared.Farm = true end); Library:Notify({Title = "VoraHub", Description = "Stopped.", Duration = 5}) end
local function FuncTPW() while true do local delta = RunService.Heartbeat:Wait(); local char = GetCharacter(); local hum = char and char:FindFirstChildOfClass("Humanoid"); if char and hum and hum.Health > 0 then if hum.MoveDirection.Magnitude > 0 then local speed = Options.TPWValue or 1; char:TranslateBy(hum.MoveDirection * speed * delta * 10) end end end end
local function FuncNoclip() while Toggles.Noclip do RunService.Stepped:Wait(); local char = GetCharacter(); if char then for _, part in pairs(char:GetDescendants()) do if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end end end end end
local function Func_AntiKnockback()
    if type(Connections.Knockback) == "table" then for _, conn in pairs(Connections.Knockback) do if conn then conn:Disconnect() end end; table.clear(Connections.Knockback) else Connections.Knockback = {} end
    local function ApplyAntiKB(character) if not character then return end; local root = character:WaitForChild("HumanoidRootPart", 10); if root then local conn = root.ChildAdded:Connect(function(child) if not Toggles.AntiKnockback then return end; if child:IsA("BodyVelocity") and child.MaxForce == Vector3.new(40000,40000,40000) then child:Destroy() end end); table.insert(Connections.Knockback, conn) end end
    if Plr.Character then ApplyAntiKB(Plr.Character) end
    local charAddedConn = Plr.CharacterAdded:Connect(ApplyAntiKB); table.insert(Connections.Knockback, charAddedConn)
    repeat task.wait(1) until not Toggles.AntiKnockback
    for _, conn in pairs(Connections.Knockback) do if conn then conn:Disconnect() end end; table.clear(Connections.Knockback)
end
local function DisableIdled() pcall(function() local cons = getconnections or get_signal_cons; if cons then for _, v in pairs(cons(Plr.Idled)) do if v.Disable then v:Disable() elseif v.Disconnect then v:Disconnect() end end end end) end
local LastDisconnectWebhookAt = 0
local function SendDisconnectedWebhook(reasonText)
    if not (Toggles.WebhookDisconnected) then return end
    local url = Options.WebhookURL; if url == "" or not url:find("discord.com/api/webhooks/") then return end
    local reason = tostring(reasonText or "Unknown")
    local payload = {["embeds"] = {{["title"] = "🔌 Disconnected", ["description"] = "Client disconnected from server.", ["color"] = 16744192, ["fields"] = {{["name"] = "Player", ["value"] = "`"..Plr.Name.."`", ["inline"] = true}, {["name"] = "PlaceId", ["value"] = "`"..tostring(game.PlaceId).."`", ["inline"] = true}, {["name"] = "JobId", ["value"] = "```"..tostring(game.JobId).."```", ["inline"] = false}, {["name"] = "Reason", ["value"] = "```"..reason.."```", ["inline"] = false}}, ["footer"] = {["text"] = "VoraHub • "..DateTime.now():FormatLocalTime("L LT", "en-us")}}}}
    if Toggles.PingUser then payload["content"] = (Options.UID and Options.UID ~= "" and "<@"..Options.UID..">" or "@everyone") end
    task.spawn(function() pcall(function() request({Url = url, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = HttpService:JSONEncode(payload)}) end) end)
end
local function Func_AutoReconnect()
    if Connections.Reconnect then Connections.Reconnect:Disconnect() end
    Connections.Reconnect = GuiService.ErrorMessageChanged:Connect(function(msg)
        if not Toggles.AutoReconnect then return end
        task.delay(2, function()
            pcall(function()
                local promptOverlay = game:GetService("CoreGui"):FindFirstChild("RobloxPromptGui")
                if promptOverlay then
                    local errorPrompt = promptOverlay.promptOverlay:FindFirstChild("ErrorPrompt")
                    if errorPrompt and errorPrompt.Visible then
                        local now = tick(); if now - LastDisconnectWebhookAt >= 15 then LastDisconnectWebhookAt = now; SendDisconnectedWebhook(msg or GuiService.ErrorMessage) end
                        task.wait(5); TeleportService:Teleport(game.PlaceId, Plr)
                    end
                end
            end)
        end)
    end)
end
local function Func_NoGameplayPaused() while Toggles.NoGameplayPaused do pcall(function() local pauseGui = game:GetService("CoreGui").RobloxGui:FindFirstChild("CoreScripts/NetworkPause"); if pauseGui then pauseGui:Destroy() end end); task.wait(1) end end
local function ApplyFPSBoost(state) if not state then return end; pcall(function() Lighting.GlobalShadows = false; Lighting.FogEnd = 9e9; Lighting.Brightness = 1; for _, v in pairs(Lighting:GetChildren()) do if v:IsA("PostProcessEffect") or v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("SunRaysEffect") then v.Enabled = false end end; task.spawn(function() for i, v in pairs(workspace:GetDescendants()) do if not Toggles.FPSBoost then break end; pcall(function() if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic; v.CastShadow = false elseif v:IsA("Decal") or v:IsA("Texture") then v:Destroy() elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") then v.Enabled = false end end); if i % 500 == 0 then task.wait() end end end) end) end
local function ApplyIslandWipe() if not Toggles.FPSBoost_AF then return end; task.spawn(function() local totalDeleted = 0; local protectKeywords = {"SpawnPointCrystal_", "Portal_"}; pcall(function() for _, folder in pairs(workspace:GetChildren()) do local name = folder.Name; local isIsland = name:lower():find("island") or name == "HuecoMundo" or name == "ShibuyaStation"; if folder:IsA("Folder") and isIsland then local descendants = folder:GetDescendants(); for i, obj in ipairs(descendants) do if obj:IsA("Model") or obj:IsA("BasePart") then local objName = obj.Name; local isProtected = false; for _, kw in ipairs(protectKeywords) do if objName:find(kw) then isProtected = true break end end; if not isProtected then pcall(function() obj:Destroy() end); totalDeleted = totalDeleted + 1 end end; if i % 300 == 0 then task.wait() end end end end; local wsChildren = workspace:GetChildren(); for i, v in ipairs(wsChildren) do local isProtected = v.Name:find("TimedBossSpawn_") or v.Name == Plr.Name or v.Name == "Main Temple" or v.Name == "NPCs" or v.Name == "ServiceNPCs" or v.Name:find("QuestNPC") or v:IsA("Camera") or v:IsA("Terrain") or v.Name:find("Portal_"); if not isProtected then if v:IsA("Model") or v:IsA("BasePart") then pcall(function() v:Destroy() end); totalDeleted = totalDeleted + 1 end end; if i % 100 == 0 then task.wait() end end end) end) end
local function SendSafetyWebhook(targetPlayer, reason)
    local url = Options.WebhookURL; if url == "" or not url:find("discord.com/api/webhooks/") then return end
    local payload = {["embeds"] = {{["title"] = "⚠️ Auto Kick", ["description"] = "Someone joined you blud", ["color"] = 16711680, ["fields"] = {{["name"] = "Username", ["value"] = "`"..targetPlayer.Name.."`", ["inline"] = true}, {["name"] = "Type", ["value"] = reason, ["inline"] = true}, {["name"] = "ID", ["value"] = "```"..game.JobId.."```", ["inline"] = false}}, ["footer"] = {["text"] = "VoraHub • "..DateTime.now():FormatLocalTime("L LT", "en-us")}}}}
    task.spawn(function() pcall(function() request({Url = url, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = HttpService:JSONEncode(payload)}) end) end)
end
local TargetGroupId = 1002185259
local BannedRanks = {255,254,175,150}
local function CheckServerTypeSafety()
    if not Toggles.AutoKick then return end
    local kickTypes = Options.SelectedKickType or {}
    if kickTypes["Public Server"] then
        local success, serverType = pcall(function() local remote = RS:WaitForChild("GetServerType",2); if remote then return remote:InvokeServer() end; return "Unknown" end)
        if success and serverType ~= "VIPServer" then
            local url = Options.WebhookURL; if url ~= "" and url:find("discord.com/api/webhooks/") then local payload = {["embeds"] = {{["title"] = "⚠️ Auto Kick", ["description"] = "Kicked because in Public server.", ["color"] = 16753920, ["fields"] = {{["name"] = "Username", ["value"] = "`"..Plr.Name.."`", ["inline"] = true}, {["name"] = "JobId", ["value"] = "```"..game.JobId.."```", ["inline"] = false}}, ["footer"] = {["text"] = "VoraHub"}}}}; task.spawn(function() pcall(function() request({Url = url, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = HttpService:JSONEncode(payload)}) end) end) end
            task.wait(0.8); Plr:Kick("\n[VoraHub]\nReason: You are in a public server.")
        end
    end
end
local function CheckPlayerForSafety(targetPlayer)
    if not Toggles.AutoKick then return end; if targetPlayer == Plr then return end
    local kickTypes = Options.SelectedKickType or {}
    if kickTypes["Player Join"] then SendSafetyWebhook(targetPlayer, "Player Join Detection"); task.wait(0.5); Plr:Kick("\n[VoraHub]\nReason: A player joined the server ("..targetPlayer.Name..")"); return end
    if kickTypes["Mod"] then local success, rank = pcall(function() return targetPlayer:GetRankInGroup(TargetGroupId) end); if success and table.find(BannedRanks, rank) then SendSafetyWebhook(targetPlayer, "Moderator Detection (Rank: "..tostring(rank)..")"); task.wait(0.5); Plr:Kick("\n[VoraHub]\nReason: Moderator Detected ("..targetPlayer.Name..")") end end
end
local function ACThing(state)
    if Connections.Dash then Connections.Dash:Disconnect(); Connections.Dash = nil end
    if state and _DR and _FS then local zero = Vector3.new(0,0,0); local nanVec = Vector3.new(0/0,0/0,0/0); Connections.Dash = RunService.Heartbeat:Connect(function() pcall(function() _FS(_DR, zero, 0, false) end); pcall(function() _FS(_DR, nanVec, math.huge, true) end) end) end
end
local function DashClient_GetDirection48(humanoid, hrp)
    local cam = workspace.CurrentCamera; local v = Vector3.zero
    if cam then local cf = cam.CFrame; if UIS:IsKeyDown(Enum.KeyCode.W) then v = v + cf.LookVector end; if UIS:IsKeyDown(Enum.KeyCode.S) then v = v - cf.LookVector end; if UIS:IsKeyDown(Enum.KeyCode.A) then v = v - cf.RightVector end; if UIS:IsKeyDown(Enum.KeyCode.D) then v = v + cf.RightVector end end
    if v.Magnitude < 0.1 then v = humanoid.MoveDirection end
    if v.Magnitude < 0.1 then if not hrp then return nil end; local lv = hrp.CFrame.LookVector; return Vector3.new(lv.X,0,lv.Z).Unit end
    local flat = Vector3.new(v.X,0,v.Z); if flat.Magnitude >= 0.1 then return flat.Unit end
    if not hrp then return nil end; local lv = hrp.CFrame.LookVector; return Vector3.new(lv.X,0,lv.Z).Unit
end
local function DashModule_CheckDashPath(character, directionUnit, dashDistance)
    local hrp = character:FindFirstChild("HumanoidRootPart"); if not hrp then return false,0 end
    local startPos = hrp.Position; local rayVec = directionUnit * dashDistance; local params = RaycastParams.new(); params.FilterDescendantsInstances = {character}; params.FilterType = Enum.RaycastFilterType.Exclude
    local hit = workspace:Raycast(startPos, rayVec, params); if not hit then return true, dashDistance end
    local dist = (hit.Position - startPos).Magnitude - 2; return true, math.max(dist,0)
end
local function DashModule_IsBackwardDash(character, dashDirUnit) local hrp = character:FindFirstChild("HumanoidRootPart"); if not hrp then return false end; return hrp.CFrame.LookVector:Dot(dashDirUnit) < -0.5 end
local gameDashModule = nil
local lastDeepDashModuleScan = 0
local function findDashModuleScriptShallow() local ms = RS:FindFirstChild("DashModule"); if ms and ms:IsA("ModuleScript") then return ms end; local sh = RS:FindFirstChild("ShadowX_Dash"); if sh then ms = sh:FindFirstChild("DashModule"); if ms and ms:IsA("ModuleScript") then return ms end end; return nil end
local function getGameDashModule()
    if gameDashModule ~= nil then return gameDashModule end
    local ms = findDashModuleScriptShallow()
    if not ms and tick() - lastDeepDashModuleScan >= 2 then lastDeepDashModuleScan = tick(); for _, d in RS:GetDescendants() do if d.Name == "DashModule" and d:IsA("ModuleScript") then ms = d; break end end end
    if ms then local ok, mod = pcall(require, ms); if ok and typeof(mod) == "table" then gameDashModule = mod end end
    return gameDashModule
end
local function flatDashDir3(v) local f = Vector3.new(v.X,0,v.Z); if f.Magnitude < 0.05 then return nil end; return f.Unit end
local function Dash_GetDirection(character, humanoid, hrp)
    local mod = getGameDashModule()
    if mod and mod.GetDashDirection then local ok, d = pcall(function() return mod.GetDashDirection(character, humanoid) end); if ok and typeof(d) == "Vector3" then local u = flatDashDir3(d); if u then return u end end; ok, d = pcall(function() return mod.GetDashDirection(humanoid, character) end); if ok and typeof(d) == "Vector3" then local u = flatDashDir3(d); if u then return u end end end
    return DashClient_GetDirection48(humanoid, hrp)
end
local function Dash_CheckPath(character, directionUnit, dashDistance) local mod = getGameDashModule(); if mod and mod.CheckDashPath then return mod.CheckDashPath(character, directionUnit, dashDistance) end; return DashModule_CheckDashPath(character, directionUnit, dashDistance) end
local function Dash_IsBackward(character, dashDirUnit) local mod = getGameDashModule(); if mod and mod.IsBackwardDash then return mod.IsBackwardDash(character, dashDirUnit) end; return DashModule_IsBackwardDash(character, dashDirUnit) end
local DASH_MODULE_SPEED = 110
local DASH_OVERRIDE_GRAVITY = true
local DASH_VERTICAL_LIFT = 1
local function DashClient_StopAutoDashPhysics() if Shared.AutoDashPhysicsConn then pcall(function() Shared.AutoDashPhysicsConn:Disconnect() end); Shared.AutoDashPhysicsConn = nil end; local r = Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart"); local bv = r and r:FindFirstChild("VoraHub_AutoDashBV"); if bv then bv:Destroy() end end
local function DashClient_ApplyDashMovement(hrp, humanoid, dirUnit, pathDistance)
    if not hrp or not humanoid or pathDistance <= 0 then return end
    DashClient_StopAutoDashPhysics()
    local mod = getGameDashModule(); local cfg = mod and mod.Config
    local dashSpeed = (cfg and cfg.DashSpeed) or DASH_MODULE_SPEED
    local ov = (cfg and cfg.OverrideGravity ~= nil) and cfg.OverrideGravity or DASH_OVERRIDE_GRAVITY
    local vlift = (cfg and cfg.VerticalLift) or DASH_VERTICAL_LIFT
    local grounded = humanoid.FloorMaterial ~= Enum.Material.Air
    local vy0 = hrp.AssemblyLinearVelocity.Y
    local hold = pathDistance / dashSpeed; local endT = tick() + hold
    Shared.AutoDashPhysicsConn = RunService.Heartbeat:Connect(function()
        if tick() >= endT or not hrp.Parent or hrp.Parent ~= humanoid.Parent then DashClient_StopAutoDashPhysics(); return end
        local vy = hrp.AssemblyLinearVelocity.Y; local useY = (ov and not grounded) and vlift or vy
        local target = dirUnit * dashSpeed + Vector3.new(0, useY, 0); hrp.AssemblyLinearVelocity = target
    end)
    local bv = Instance.new("BodyVelocity"); bv.Name = "VoraHub_AutoDashBV"; bv.P = 125000; bv.MaxForce = (ov and not grounded) and Vector3.new(1e7,1e7,1e7) or Vector3.new(1e7,0,1e7); bv.Velocity = dirUnit * dashSpeed + Vector3.new(0, (ov and not grounded) and vlift or vy0, 0); bv.Parent = hrp
    task.delay(hold, function() if bv.Parent then bv:Destroy() end end)
end
local DASH_CLIENT_SFX_ID = "rbxassetid://6128977275"
local DASH_CLIENT_SFX_VOLUME = 0.65
local function DashClient_PlayDashEffects(humanoid, hrp, backward)
    if not humanoid or not hrp then return end
    local mod = getGameDashModule(); local cfg = mod and mod.Config; if not cfg then return end
    local animId = nil
    if backward and cfg.BackwardDashAnim then animId = cfg.BackwardDashAnim
    elseif type(cfg.ForwardDashAnims) == "table" then local t = cfg.ForwardDashAnims; local n = #t; if n >= 1 then Shared.AutoDashFwdSlot = Shared.AutoDashFwdSlot + 1; animId = t[((Shared.AutoDashFwdSlot-1)%n)+1] end end
    if animId == nil then return end
    local idStr = (type(animId) == "string" and string.find(animId, "rbxassetid", 1, true)) and animId or ("rbxassetid://"..tostring(animId))
    local animSpeed = 1
    if mod and mod.CalculateAnimationSpeed then
        local ok, s = pcall(function() return mod.CalculateAnimationSpeed(humanoid) end); if not ok or typeof(s) ~= "number" or s <= 0 then ok, s = pcall(function() return mod.CalculateAnimationSpeed() end) end
        if ok and typeof(s) == "number" and s > 0 then local lo = cfg.MinAnimationSpeed or 0.5; local hi = cfg.MaxAnimationSpeed or 2; animSpeed = math.clamp(s, lo, hi)
        elseif cfg.BaseAnimationSpeed then animSpeed = cfg.BaseAnimationSpeed end
    elseif cfg.UseAnimationSpeed and cfg.BaseAnimationSpeed then animSpeed = cfg.BaseAnimationSpeed end
    pcall(function()
        local animator = humanoid:FindFirstChildOfClass("Animator"); if not animator then animator = Instance.new("Animator"); animator.Parent = humanoid end
        local oldHolder = humanoid:FindFirstChild("VoraHub_AutoDashAnimHolder"); if oldHolder then oldHolder:Destroy() end
        local holder = Instance.new("Folder"); holder.Name = "VoraHub_AutoDashAnimHolder"; holder.Parent = humanoid
        local anim = Instance.new("Animation"); anim.AnimationId = idStr; anim.Parent = holder
        local track = animator:LoadAnimation(anim); track.Priority = Enum.AnimationPriority.Action; track:Play(0.08); track:AdjustSpeed(animSpeed)
        local fadeOut = math.clamp((cfg.VFXDuration or 1.2) * 0.45, 0.25, 1.2); task.delay(fadeOut, function() pcall(function() track:Stop(0.1) end) end)
        task.delay(4, function() if holder.Parent then holder:Destroy() end end)
    end)
    pcall(function()
        local oldS = hrp:FindFirstChild("VoraHub_DashSfx"); if oldS then oldS:Destroy() end
        local snd = Instance.new("Sound"); snd.Name = "VoraHub_DashSfx"; snd.SoundId = DASH_CLIENT_SFX_ID; snd.Volume = DASH_CLIENT_SFX_VOLUME; snd.RollOffMode = Enum.RollOffMode.Linear; snd.MaxDistance = 100; snd.Parent = hrp; snd:Play()
        snd.Ended:Connect(function() if snd.Parent then snd:Destroy() end end)
    end)
end
Plr.CharacterAdded:Connect(function() pcall(DashClient_StopAutoDashPhysics) end)
local function InitAutoKick() CheckServerTypeSafety(); for _, p in ipairs(Players:GetPlayers()) do CheckPlayerForSafety(p) end; Players.PlayerAdded:Connect(CheckPlayerForSafety) end
local function HybridMove(targetCF)
    local character = GetCharacter(); local root = character and character:FindFirstChild("HumanoidRootPart"); if not root then return end
    local distance = (root.Position - targetCF.Position).Magnitude; local tweenSpeed = Options.TweenSpeed or 180
    if distance > tonumber(Options.TargetDistTP or 0) then
        if not Toggles.InstantTPBypass then local oldNoclip = Toggles.Noclip; Toggles.Noclip = true
            local tweenTarget = targetCF * CFrame.new(0,0,150); local tweenDist = (root.Position - tweenTarget.Position).Magnitude; local duration = tweenDist / tweenSpeed
            local tween = game:GetService("TweenService"):Create(root, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = tweenTarget}); tween:Play(); tween.Completed:Wait()
            Toggles.Noclip = oldNoclip; task.wait(0.1)
        end
    end
    root.CFrame = targetCF; root.AssemblyLinearVelocity = Vector3.new(0,0.01,0); task.wait(0.2)
end
local function GetNearestIsland(targetPos, npcName) if npcName and Shared.BossTIMap[npcName] then return Shared.BossTIMap[npcName] end; local nearestIslandName = "Starter"; local minDistance = math.huge; for islandName, crystal in pairs(IslandCrystals) do if crystal then local dist = (targetPos - crystal:GetPivot().Position).Magnitude; if dist < minDistance then minDistance = dist; nearestIslandName = islandName end end end; return nearestIslandName end
local function UpdateNPCLists()
    local specialMobs = {"ThiefBoss", "MonkeyBoss", "DesertBoss", "SnowBoss", "PandaMiniBoss"}; local currentList = {}; for _, name in pairs(Tables.MobList) do currentList[name] = true end
    for _, v in pairs(PATH.Mobs:GetChildren()) do local cleanName = v.Name:gsub("%d+$", ""); local isSpecial = table.find(specialMobs, cleanName); if (isSpecial or not cleanName:find("Boss")) and not currentList[cleanName] then table.insert(Tables.MobList, cleanName); currentList[cleanName] = true; local npcPos = v:GetPivot().Position; local closestIsland = "Unknown"; local minShot = math.huge; for islandName, crystal in pairs(IslandCrystals) do if crystal then local dist = (npcPos - crystal:GetPivot().Position).Magnitude; if dist < minShot then minShot = dist; closestIsland = islandName end end end; Tables.MobToIsland[cleanName] = closestIsland end end
    if Options.SelectedMob_dd then Options.SelectedMob_dd:SetOptions(Tables.MobList) end
end
local function UpdateAllEntities() table.clear(Tables.AllEntitiesList); local unique = {}; for _, v in pairs(PATH.Mobs:GetChildren()) do local cleanName = v.Name:gsub("%d+$", ""); if not unique[cleanName] then unique[cleanName] = true; table.insert(Tables.AllEntitiesList, cleanName) end end; table.sort(Tables.AllEntitiesList); if Options.SelectedQuestline_DMGTaken_dd then Options.SelectedQuestline_DMGTaken_dd:SetOptions(Tables.AllEntitiesList) end end
local function PopulateNPCLists()
    for _, child in ipairs(workspace:GetChildren()) do if child.Name:match("^QuestNPC%d+$") then if not table.find(Tables.NPC_QuestList, child.Name) then table.insert(Tables.NPC_QuestList, child.Name) end end end
    for _, child in ipairs(PATH.InteractNPCs:GetChildren()) do if child.Name:match("^QuestNPC%d+$") then if not table.find(Tables.NPC_QuestList, child.Name) then table.insert(Tables.NPC_QuestList, child.Name) end end end
    table.sort(Tables.NPC_QuestList, function(a,b) local numA = tonumber(a:match("%d+$")) or 0; local numB = tonumber(b:match("%d+$")) or 0; return (numA == numB) and (a < b) or (numA < numB) end)
    for _, v in pairs(PATH.InteractNPCs:GetChildren()) do local name = v.Name; if (name:find("Moveset") or name:find("Buyer")) and not name:find("Observation") then table.insert(Tables.NPC_MovesetList, name) end; if (name:find("Mastery") or name:find("Questline") or name:find("Craft")) and not (name:find("Grail") or name:find("Slime")) then table.insert(Tables.NPC_MasteryList, name) end end
    table.sort(Tables.NPC_MovesetList); table.sort(Tables.NPC_MasteryList)
end
local function GetCurrentPity() local pityLabel = PGui.BossUI.MainFrame.BossHPBar.Pity; local current, max = pityLabel.Text:match("Pity: (%d+)/(%d+)"); return tonumber(current) or 0, tonumber(max) or 25 end
PopulateNPCLists()
local function findNPCByDistance(dist) local bestMatch = nil; local tolerance = 2; local char = GetCharacter(); for _, npc in ipairs(workspace:GetDescendants()) do if npc:IsA("Model") and npc.Name:find("QuestNPC") then local npcPos = npc:GetPivot().Position; local actualDist = (char.HumanoidRootPart.Position - npcPos).Magnitude; if math.abs(actualDist - dist) <= tolerance then bestMatch = npc; break end end end; return bestMatch end
local function IsSmartMatch(npcName, targetMobType) local n = npcName:gsub("%d+$", ""):lower(); local t = targetMobType:lower(); if n == t then return true end; if t:find(n) == 1 then return true end; if n:find(t) == 1 then return true end; return false end
local function SafeTeleportToNPC(targetName, customMap)
    local character = GetCharacter(); local root = character and character:FindFirstChild("HumanoidRootPart"); if not root then return end
    local actualName = customMap and customMap[targetName] or targetName
    local target = workspace:FindFirstChild(actualName) or PATH.InteractNPCs:FindFirstChild(actualName); if not target then for _, v in pairs(PATH.InteractNPCs:GetChildren()) do if v.Name:find(actualName) then target = v; break end end end
    if target then local npcPivot = target:GetPivot(); root.CFrame = npcPivot * CFrame.new(0,3,0); root.AssemblyLinearVelocity = Vector3.new(0,0.01,0); root.AssemblyAngularVelocity = Vector3.zero else Library:Notify({Title = "Error", Description = "NPC not found: "..tostring(actualName), Duration = 3}) end
end
local function Clean(str) return str:gsub("%s+", ""):lower() end
local function GetToolTypeFromModule(toolName)
    local cleanedTarget = Clean(toolName)
    for manualName, toolType in pairs(Tables.ManualWeaponClass) do if Clean(manualName) == cleanedTarget then return toolType end end
    if Modules.WeaponClass and Modules.WeaponClass.Tools then for moduleName, toolType in pairs(Modules.WeaponClass.Tools) do if Clean(moduleName) == cleanedTarget then return toolType end end end
    if toolName:lower():find("fruit") then return "Power" end
    return "Melee"
end
local function GetWeaponsByType()
    local available = {}; local enabledTypes = Options.SelectedWeaponType or {}; local char = GetCharacter()
    local containers = {Plr.Backpack}; if char then table.insert(containers, char) end
    for _, container in ipairs(containers) do for _, tool in ipairs(container:GetChildren()) do if tool:IsA("Tool") then local toolType = GetToolTypeFromModule(tool.Name); if enabledTypes[toolType] then if not table.find(available, tool.Name) then table.insert(available, tool.Name) end end end end end
    return available
end
local function UpdateWeaponRotation()
    local weaponList = GetWeaponsByType()
    if #weaponList == 0 then Shared.ActiveWeap = ""; return end
    local switchDelay = Options.SwitchWeaponCD or 4
    if tick() - Shared.LastWRSwitch >= switchDelay then Shared.WeapRotationIdx = Shared.WeapRotationIdx + 1; if Shared.WeapRotationIdx > #weaponList then Shared.WeapRotationIdx = 1 end; Shared.ActiveWeap = weaponList[Shared.WeapRotationIdx]; Shared.LastWRSwitch = tick() end
    local exists = false; for _, name in ipairs(weaponList) do if name == Shared.ActiveWeap then exists = true break end end
    if not exists then Shared.ActiveWeap = weaponList[1] end
end
local function EquipWeapon()
    UpdateWeaponRotation(); if Shared.ActiveWeap == "" then return end
    local char = GetCharacter(); local hum = char and char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    if char:FindFirstChild(Shared.ActiveWeap) then return end
    local tool = Plr.Backpack:FindFirstChild(Shared.ActiveWeap) or char:FindFirstChild(Shared.ActiveWeap); if tool then hum:EquipTool(tool) end
end
local function CheckObsHaki() local PlayerGui = Plr:FindFirstChild("PlayerGui"); if PlayerGui then local DodgeUI = PlayerGui:FindFirstChild("DodgeCounterUI"); if DodgeUI and DodgeUI:FindFirstChild("MainFrame") then return DodgeUI.MainFrame.Visible end end; return false end
local function CheckArmHaki() if Shared.ArmHaki == true then return true end; local char = GetCharacter(); if char then local leftArm = char:FindFirstChild("Left Arm") or char:FindFirstChild("LeftUpperArm"); local rightArm = char:FindFirstChild("Right Arm") or char:FindFirstChild("RightUpperArm"); local hasVisual = (leftArm and leftArm:FindFirstChild("Lightning Strike")) or (rightArm and rightArm:FindFirstChild("Lightning Strike")); if hasVisual then Shared.ArmHaki = true; return true end end; return false end
local function IsBusy() return Plr.Character and Plr.Character:FindFirstChildOfClass("ForceField") ~= nil end
local function IsSkillReady(key)
    local char = GetCharacter(); local tool = char and char:FindFirstChildOfClass("Tool"); if not tool then return true end
    local mainFrame = PGui:FindFirstChild("CooldownUI") and PGui.CooldownUI:FindFirstChild("MainFrame"); if not mainFrame then return true end
    local cleanTool = Clean(tool.Name); local foundFrame = nil
    for _, frame in pairs(mainFrame:GetChildren()) do if not frame:IsA("Frame") then continue end; local fname = frame.Name:lower(); if fname:find("cooldown") and (fname:find(cleanTool) or fname:find("skill")) then local mapped = "none"; if fname:find("skill 1") or fname:find("_z") then mapped = "Z" elseif fname:find("skill 2") or fname:find("_x") then mapped = "X" elseif fname:find("skill 3") or fname:find("_c") then mapped = "C" elseif fname:find("skill 4") or fname:find("_v") then mapped = "V" elseif fname:find("skill 5") or fname:find("_f") then mapped = "F" end; if mapped == key then foundFrame = frame break end end end
    if not foundFrame then return true end; local cdLabel = foundFrame:FindFirstChild("WeaponNameAndCooldown", true); return (cdLabel and cdLabel.Text:find("Ready"))
end
local function GetSecondsFromTimer(text) local min, sec = text:match("(%d+):(%d+)"); if min and sec then return (tonumber(min)*60)+tonumber(sec) end; return nil end
local function FormatSecondsToTimer(s) local minutes = math.floor(s/60); local seconds = s%60; return string.format("<b>Refresh:</b> %02d:%02d", minutes, seconds) end
local function OpenMerchantInterface()
    if isXeno then local npc = workspace:FindFirstChild("ServiceNPCs") and workspace.ServiceNPCs:FindFirstChild("MerchantNPC"); local prompt = npc and npc:FindFirstChild("HumanoidRootPart") and npc.HumanoidRootPart:FindFirstChild("MerchantPrompt")
        if prompt then local char = GetCharacter(); local root = char:FindFirstChild("HumanoidRootPart"); if root then local oldCF = root.CFrame; root.CFrame = npc.HumanoidRootPart.CFrame * CFrame.new(0,0,3); task.wait(0.2)
            if Support.Proximity then fireproximityprompt(prompt) else prompt:InputHoldBegin(); task.wait(prompt.HoldDuration+0.1); prompt:InputHoldEnd() end
            task.wait(0.5); root.CFrame = oldCF
        end
    end
    else if firesignal then firesignal(Remotes.OpenMerchant.OnClientEvent) elseif getconnections then for _, v in pairs(getconnections(Remotes.OpenMerchant.OnClientEvent)) do if v.Function then task.spawn(v.Function) end end end end
end
local function SyncRaceSettings()
    if not Toggles.AutoRace then return end
    pcall(function()
        local selected = Options.SelectedRace or {}; local hasEpic, hasLegendary = false, false
        for name, data in pairs(Modules.Race.Races) do local rarity = tostring(data.rarity or data.Rarity or ""):lower(); local isEpic = rarity == "epic"; local isLegendary = rarity == "legendary"; local isMythic = (rarity == "mythical" or rarity == "mythic")
            if isMythic then local shouldSkip = not selected[name]; if Shared.Settings["SkipRace_"..name] ~= shouldSkip then Remotes.SettingsToggle:FireServer("SkipRace_"..name, shouldSkip); Shared.Settings["SkipRace_"..name] = shouldSkip end end
            if selected[name] then if isEpic then hasEpic = true end; if isLegendary then hasLegendary = true end end
        end
        if Shared.Settings["SkipEpicReroll"] ~= not hasEpic then Remotes.SettingsToggle:FireServer("SkipEpicReroll", not hasEpic); Shared.Settings["SkipEpicReroll"] = not hasEpic end
        if Shared.Settings["SkipLegendaryReroll"] ~= not hasLegendary then Remotes.SettingsToggle:FireServer("SkipLegendaryReroll", not hasLegendary); Shared.Settings["SkipLegendaryReroll"] = not hasLegendary end
    end)
end
local function SyncClanSettings()
    if not Toggles.AutoClan then return end
    pcall(function()
        local selected = Options.SelectedClan or {}; local hasEpic, hasLegendary = false, false
        for name, data in pairs(Modules.Clan.Clans) do local rarity = data.rarity or data.Rarity
            if rarity == "Legendary" then local shouldSkip = not selected[name]; if Shared.Settings["SkipClan_"..name] ~= shouldSkip then Remotes.SettingsToggle:FireServer("SkipClan_"..name, shouldSkip) end end
            if selected[name] then if rarity == "Epic" then hasEpic = true end; if rarity == "Legendary" then hasLegendary = true end end
        end
        if Shared.Settings["SkipEpicClan"] ~= not hasEpic then Remotes.SettingsToggle:FireServer("SkipEpicClan", not hasEpic) end
        if Shared.Settings["SkipLegendaryClan"] ~= not hasLegendary then Remotes.SettingsToggle:FireServer("SkipLegendaryClan", not hasLegendary) end
    end)
end
local function SyncSpecPassiveAutoSkip() pcall(function() if Remotes.SpecPassiveSkip then Remotes.SpecPassiveSkip:FireServer({Epic=true, Legendary=true, Mythical=true}) end end) end
local function SyncTraitAutoSkip()
    if not Toggles.AutoTrait then return end
    pcall(function()
        local selected = Options.SelectedTrait or {}; local rarityHierarchy = {["Epic"]=1, ["Legendary"]=2, ["Mythical"]=3, ["Secret"]=4}; local lowestTargetValue = 99
        for traitName, enabled in pairs(selected) do if enabled then local data = Modules.Trait.Traits[traitName]; if data then local val = rarityHierarchy[data.Rarity] or 0; if val > 0 and val < lowestTargetValue then lowestTargetValue = val end end end end
        if lowestTargetValue == 99 then return end
        local skipData = {["Epic"] = 1 < lowestTargetValue, ["Legendary"] = 2 < lowestTargetValue, ["Mythical"] = 3 < lowestTargetValue, ["Secret"] = 4 < lowestTargetValue}
        Remotes.TraitAutoSkip:FireServer(skipData)
    end)
end
local function GetMatches(data, subStatFilter) local count = 0; for _, sub in pairs(data.Substats or {}) do if subStatFilter[sub.Stat] then count = count + 1 end end; return count end
local function GetPotential(data, subStatFilter) local currentMatches = GetMatches(data, subStatFilter); local currentCount = #(data.Substats or {}); local remainingReveals = math.max(0, 4 - currentCount); if data.Level >= 12 then remainingReveals = 0 end; return currentMatches + remainingReveals end
local function IsMainStatGood(data, mainStatFilter) if data.Category == "Helmet" or data.Category == "Gloves" then return true end; return mainStatFilter[data.MainStat.Stat] == true end
local function EvaluateArtifact2(uuid, data)
    local actions = {lock = false, delete = false, upgrade = false}
    local function GetFilterStatus(filter, value) if not filter or next(filter) == nil then return nil end; return filter[value] == true end
    local function IsWhitelisted(filter, value) local status = GetFilterStatus(filter, value); if status == nil then return true end; return status end
    if Toggles.ArtifactUpgrade and data.Level < (Options.UpgradeLimit or 15) then if IsWhitelisted(Options.Up_MS, data.MainStat.Stat) then actions.upgrade = true end end
    local lockMinSS = Options.Lock_MinSS or 0
    if Toggles.ArtifactLock and not data.Locked and data.Level >= (lockMinSS * 3) then if IsWhitelisted(Options.Lock_MS, data.MainStat.Stat) and IsWhitelisted(Options.Lock_Type, data.Category) and IsWhitelisted(Options.Lock_Set, data.Set) then if GetMatches(data, Options.Lock_SS) >= lockMinSS then actions.lock = true end end end
    if not data.Locked and not actions.lock then
        if Toggles.DeleteUnlock then actions.delete = true
        elseif Toggles.ArtifactDelete then
            local typeMatch = GetFilterStatus(Options.Del_Type, data.Category); local setMatch = GetFilterStatus(Options.Del_Set, data.Set)
            local msDropdownName = "Del_MS_"..data.Category; local specificMSFilter = Options[msDropdownName] or {}; local msMatch = GetFilterStatus(specificMSFilter, data.MainStat.Stat)
            local isTarget = true
            if typeMatch == false then isTarget = false end; if setMatch == false then isTarget = false end
            if typeMatch == nil and setMatch == nil and msMatch == nil then isTarget = false end
            if isTarget then
                local trashCount = GetMatches(data, Options.Del_SS); local minTrash = Options.Del_MinSS or 0; local isMaxLevel = data.Level >= (Options.UpgradeLimit or 15)
                if msMatch == true then actions.delete = true
                elseif minTrash == 0 then actions.delete = true
                elseif isMaxLevel and trashCount >= minTrash then actions.delete = true end
            end
        end
    end
    return actions
end
local function AutoEquipArtifacts()
    if not Toggles.ArtifactEquip then return end
    local bestItems = {Helmet = nil, Gloves = nil, Body = nil, Boots = nil}; local bestScores = {Helmet = -1, Gloves = -1, Body = -1, Boots = -1}
    local targetTypes = Options.Eq_Type or {}; local targetMS = Options.Eq_MS or {}; local targetSS = Options.Eq_SS or {}
    for uuid, data in pairs(Shared.ArtifactSession.Inventory) do
        if targetTypes[data.Category] and IsMainStatGood(data, targetMS) then local score = (GetMatches(data, targetSS) * 10) + data.Level; if score > bestScores[data.Category] then bestScores[data.Category] = score; bestItems[data.Category] = {UUID = uuid, Equipped = data.Equipped} end end
    end
    for category, item in pairs(bestItems) do if item and not item.Equipped then Remotes.ArtifactEquip:FireServer(item.UUID); task.wait(0.2) end end
end
local function IsStrictBossMatch(npcName, targetDisplayName)
    local n = npcName:lower():gsub("%s+", ""); local t = targetDisplayName:lower():gsub("%s+", "")
    if n:find("true") and not t:find("true") then return false end
    if t:find("strongest") then local era = t:find("history") and "history" or "today"; return n:find("strongest") and n:find(era) end
    if n:find(t) then return true end
    local internal = Shared.BossInternalName[targetDisplayName]; if internal then local i = internal:lower():gsub("%s+", ""); if n:find(i) then return true end end
    return false
end
local function AutoUpgradeLoop(mode)
    local toggle = Toggles["Auto"..mode]; local allToggle = Toggles["Auto"..mode.."All"]; local remote = (mode == "Enchant") and Remotes.Enchant or Remotes.Blessing; local sourceTable = (mode == "Enchant") and Tables.OwnedAccessory or Tables.OwnedWeapon
    while (toggle or allToggle) do
        local selection = Options["Selected"..mode] or {}; local workDone = false
        for _, itemName in ipairs(sourceTable) do if Shared.UpBlacklist[itemName] then continue end; local isSelected = false; if allToggle then isSelected = true else isSelected = selection[itemName] or table.find(selection, itemName) end
            if isSelected then workDone = true; pcall(function() remote:FireServer(itemName) end); task.wait(1.5); break end
        end
        if not workDone then Library:Notify({Title = "Info", Description = "Stopping..", Duration = 5}); if toggle then toggle:SetValue(false) end; if allToggle then allToggle:SetValue(false) end; break end
        task.wait(0.1)
    end
end
local function FireBossRemote(bossName, diff)
    local lowerName = bossName:lower():gsub("%s+", ""); local remoteArg = GetRemoteBossArg(bossName); table.clear(Shared.AltDamage)
    local function GetInternalSummonId(name) local cleanTarget = name:lower():gsub("%s+", ""); for displayName, internalId in pairs(SummonMap) do if displayName:lower():gsub("%s+", "") == cleanTarget then return internalId end end; return name:gsub("%s+", "").."Boss" end
    pcall(function()
        if lowerName:find("rimuru") then Remotes.RimuruBoss:FireServer(diff)
        elseif lowerName:find("anos") then Remotes.AnosBoss:FireServer("Anos", diff)
        elseif lowerName:find("trueaizen") then if Remotes.TrueAizenBoss then Remotes.TrueAizenBoss:FireServer(diff) end
        elseif lowerName:find("atomic") then if Remotes.AtomicBoss then Remotes.AtomicBoss:FireServer(diff) end
        elseif lowerName:find("strongest") then Remotes.JJKSummonBoss:FireServer(remoteArg, diff)
        else local summonId = GetInternalSummonId(bossName); Remotes.SummonBoss:FireServer(summonId, diff) end
    end)
end
local function HandleSummons()
    if Shared.MerchantBusy then return end
    local function MatchName(name1, name2) if not name1 or not name2 then return false end; return name1:lower():gsub("%s+", "") == name2:lower():gsub("%s+", "") end
    local function IsSummonable(name) local cleanName = name:lower():gsub("%s+", ""); for _, boss in ipairs(Tables.SummonList) do if MatchName(boss, cleanName) then return true end end; for _, boss in ipairs(Tables.OtherSummonList) do if MatchName(boss, cleanName) then return true end end; return false end
    if Toggles.PityBossFarm then
        local current, max = GetCurrentPity(); local buildOptions = Options.SelectedBuildPity or {}; local useName = Options.SelectedUsePity
        if useName and next(buildOptions) then
            local isUseTurn = (current >= (max - 1))
            if isUseTurn then
                local found = false; for _, v in pairs(PATH.Mobs:GetChildren()) do if MatchName(v.Name, useName) or v.Name:lower():find(useName:lower():gsub("%s+", "")) then found = true break end end
                if not found and IsSummonable(useName) then FireBossRemote(useName, Options.SelectedPityDiff or "Normal"); task.wait(0.5); return end
            else
                local anyBuildBossSpawned = false; for bossName, enabled in pairs(buildOptions) do if enabled then for _, v in pairs(PATH.Mobs:GetChildren()) do if MatchName(v.Name, bossName) or v.Name:lower():find(bossName:lower():gsub("%s+", "")) then anyBuildBossSpawned = true; break end end end; if anyBuildBossSpawned then break end end
                if not anyBuildBossSpawned then for bossName, enabled in pairs(buildOptions) do if enabled and IsSummonable(bossName) then FireBossRemote(bossName, "Normal"); task.wait(0.5); return end end end
            end
        end
    end
    if Toggles.AutoOtherSummon then local selected = Options.SelectedOtherSummon; local diff = Options.SelectedOtherSummonDiff; if selected and diff then local keyword = selected:gsub("Strongest", ""):lower(); local found = false; for _, v in pairs(PATH.Mobs:GetChildren()) do local npcName = v.Name:lower(); if npcName:find(selected:lower()) or (npcName:find("strongest") and npcName:find(keyword)) then found = true break end end; if not found then FireBossRemote(selected, diff); task.wait(0.5) end end end
    if Toggles.AutoSummon then local selected = Options.SelectedSummon; if selected then local found = false; for _, v in pairs(PATH.Mobs:GetChildren()) do if IsStrictBossMatch(v.Name, selected) then found = true break end end; if not found then FireBossRemote(selected, Options.SelectedSummonDiff or "Normal"); task.wait(0.5) end end end
end
local function UpdateSwitchState(target, farmType)
    if Shared.GlobalPrio == "COMBO" then return end
    local types = {{id = "Title", remote = Remotes.EquipTitle, method = function(val) return val end}, {id = "Rune", remote = Remotes.EquipRune, method = function(val) return {"Equip", val} end}, {id = "Build", remote = Remotes.LoadoutLoad, method = function(val) return tonumber(val) end}}
    for _, switch in ipairs(types) do
        if not Toggles["Auto"..switch.id] then continue end
        if switch.id == "Build" and tick() - Shared.LastBuildSwitch < 3.1 then continue end
        local toEquip = ""; local threshold = Options[switch.id.."_BossHPAmt"] or 15; local isLow = false
        if farmType == "Boss" and target then local hum = target:FindFirstChildOfClass("Humanoid"); if hum and (hum.Health / hum.MaxHealth) * 100 <= threshold then isLow = true end end
        if farmType == "None" then toEquip = Options["Default"..switch.id]
        elseif farmType == "Mob" then toEquip = Options[switch.id.."_Mob"]
        elseif farmType == "Boss" then toEquip = isLow and Options[switch.id.."_BossHP"] or Options[switch.id.."_Boss"] end
        if not toEquip or toEquip == "" or toEquip == "None" then continue end
        local finalEquipValue = toEquip
        if switch.id == "Title" and toEquip:find("Best ") then local bestId = GetBestOwnedTitle(toEquip); if bestId then finalEquipValue = bestId else continue end end
        if finalEquipValue ~= Shared.LastSwitch[switch.id] then
            local args = switch.method(finalEquipValue)
            pcall(function() if type(args) == "table" then switch.remote:FireServer(table.unpack(args)) else switch.remote:FireServer(args) end end)
            Shared.LastSwitch[switch.id] = finalEquipValue
            if switch.id == "Build" then Shared.LastBuildSwitch = tick() end
        end
    end
end
local NotificationBlacklist = {"You don't have this item!", "Not enough "}
local function ProcessNotification(frame)
    task.delay(0.01, function()
        if not Toggles.AutoDeleteNotif then return end; if not frame or not frame.Parent then return end
        local txtLabel = frame:FindFirstChild("Txt", true)
        if txtLabel and txtLabel:IsA("TextLabel") then local incomingText = txtLabel.Text:lower(); for _, blacklistedPhrase in ipairs(NotificationBlacklist) do if incomingText:find(blacklistedPhrase:lower()) then frame.Visible = false; break end end end
    end)
end
local function UniversalPuzzleSolver(puzzleType)
    local moduleMap = {["Dungeon"] = RS.Modules:FindFirstChild("DungeonConfig"), ["Slime"] = RS.Modules:FindFirstChild("SlimePuzzleConfig"), ["Demonite"] = RS.Modules:FindFirstChild("DemoniteCoreQuestConfig"), ["Hogyoku"] = RS.Modules:FindFirstChild("HogyokuQuestConfig")}
    local hogyokuIslands = {"Snow", "Shibuya", "HuecoMundo", "Shinjuku", "Slime", "Judgement"}; local targetModule = moduleMap[puzzleType]; if not targetModule then return end
    local data = require(targetModule); local settings = data.PuzzleSettings or data.PieceSettings; local piecesToCollect = data.Pieces or settings.IslandOrder; local pieceModelName = settings and settings.PieceModelName or "DungeonPuzzlePiece"
    Library:Notify({Title = "Puzzle", Description = "Starting "..puzzleType.." Puzzle...", Duration = 5})
    for i, islandOrPiece in ipairs(piecesToCollect) do
        local piece = nil; local tpTarget = nil
        if puzzleType == "Demonite" then tpTarget = "Academy" elseif puzzleType == "Hogyoku" then tpTarget = hogyokuIslands[i] else tpTarget = islandOrPiece:gsub("Island", ""):gsub("Station", ""); if islandOrPiece == "HuecoMundo" then tpTarget = "HuecoMundo" end end
        if tpTarget then Remotes.TP_Portal:FireServer(tpTarget); task.wait(2.5) end
        if puzzleType == "Slime" and i == #piecesToCollect then local char = GetCharacter(); local root = char and char:FindFirstChild("HumanoidRootPart"); if root then Remotes.TP_Portal:FireServer("Shinjuku"); task.wait(2); Remotes.TP_Portal:FireServer("Slime"); task.wait(2); root.CFrame = CFrame.new(788,68,-2309); task.wait(1.5) end end
        if puzzleType == "Demonite" or puzzleType == "Hogyoku" then piece = workspace:FindFirstChild(islandOrPiece, true)
        else local islandFolder = workspace:FindFirstChild(islandOrPiece); piece = islandFolder and islandFolder:FindFirstChild(pieceModelName, true) or workspace:FindFirstChild(pieceModelName, true) end
        if piece then
            HybridMove(piece:GetPivot() * CFrame.new(0,3,0)); task.wait(0.5)
            local prompt = piece:FindFirstChildOfClass("ProximityPrompt") or piece:FindFirstChild("PuzzlePrompt", true) or piece:FindFirstChild("ProximityPrompt", true)
            if prompt then fireproximityprompt(prompt); Library:Notify({Title = "Puzzle", Description = string.format("Collected Piece %d/%d", i, #piecesToCollect), Duration = 2}); task.wait(1.5)
            else Library:Notify({Title = "Puzzle", Description = "Found piece but no interaction prompt.", Duration = 3}) end
        else Library:Notify({Title = "Puzzle", Description = "Failed to find piece "..i.." on "..tostring(tpTarget or "Island"), Duration = 3}) end
    end
    Library:Notify({Title = "Puzzle", Description = puzzleType.." Puzzle Completed!", Duration = 5})
end
local function GetCurrentQuestUI() local holder = PGui.QuestUI.Quest.Quest.Holder.Content; local info = holder.QuestInfo; return {Title = info.QuestTitle.QuestTitle.Text, Description = info.QuestDescription.Text, SwitchVisible = holder.QuestSwitchButton.Visible, SwitchBtn = holder.QuestSwitchButton, IsVisible = PGui.QuestUI.Quest.Visible} end
local function AutoQuestlineLoop()
    while Toggles.AutoQuestline do
        task.wait(0.1)
        local selectedId = Options.SelectedQuestline; if not selectedId then continue end
        local questData = Modules.Quests.Questlines[selectedId]; if not questData then continue end
        local ui = GetCurrentQuestUI(); local actualNPCName = questData.npcName
        local isMatchingStage = false; for _, stage in ipairs(questData.stages) do if stage.title == ui.Title then isMatchingStage = true break end end
        if not ui.IsVisible or not isMatchingStage then
            if ui.SwitchVisible and not isMatchingStage then gsc(ui.SwitchBtn); task.wait(1); ui = GetCurrentQuestUI() end
            if not isMatchingStage then Remotes.QuestAccept:FireServer(actualNPCName); task.wait(1.5); continue end
        end
        local currentStage = nil; for _, stage in ipairs(questData.stages) do if stage.title == ui.Title then currentStage = stage break end end
        if currentStage then
            local taskType = currentStage.trackingType
            if taskType == "CombatNPCKills" or taskType == "CombatPunches" or taskType == "GroundSmashUses" then
                local character = GetCharacter(); local hasCombat = Plr.Backpack:FindFirstChild("Combat") or (character and character:FindFirstChild("Combat"))
                if not hasCombat then Remotes.EquipWeapon:FireServer("Equip", "Combat"); local timeout = 0; repeat task.wait(0.2); timeout = timeout + 1; hasCombat = Plr.Backpack:FindFirstChild("Combat") or (GetCharacter() and GetCharacter():FindFirstChild("Combat")) until hasCombat or timeout > 15 end
                Options.SelectedWeaponType = {["Melee"] = true}; Options.SelectedMob = {["Thief"] = true}; Toggles.MobFarm = true
                if taskType == "GroundSmashUses" then Remotes.UseSkill:FireServer(1); task.wait(1) elseif taskType == "CombatPunches" then Remotes.M1:FireServer(); task.wait(0.2) end
            elseif taskType:find("Kills") and taskType ~= "PlayerKills" and not taskType:find("Boss") then
                local mobName = taskType:gsub("Kills", "")
                if mobName == "AnyNPC" then Toggles.LevelFarm = true elseif mobName == "HakiNPC" then Toggles.ArmHaki = true; Toggles.LevelFarm = true else Options.SelectedMob = {[mobName] = true}; Toggles.MobFarm = true end
            elseif taskType == "DamageTaken" then
                local targetName = Options.SelectedQuestline_DMGTaken; if targetName then local targetEntity = nil; for _, v in pairs(PATH.Mobs:GetChildren()) do if v.Name:find(targetName) and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then targetEntity = v; break end end
                    if targetEntity then local root = GetCharacter().HumanoidRootPart; root.CFrame = targetEntity:GetPivot() * CFrame.new(0,0,3); root.AssemblyLinearVelocity = Vector3.zero else local island = Tables.MobToIsland[targetName]; if island then Remotes.TP_Portal:FireServer(island) end end
                end
            elseif taskType == "PlayerKills" then local targetName = Options.SelectedQuestline_Player; local targetPlayer = Players:FindFirstChild(targetName); if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then local tRoot = targetPlayer.Character.HumanoidRootPart; local root = GetCharacter().HumanoidRootPart; if targetPlayer.Character.Humanoid.Health > 0 then root.CFrame = tRoot.CFrame * CFrame.new(0,0,3); EquipWeapon(); Remotes.M1:FireServer(); Remotes.UseSkill:FireServer(math.random(1,4)) end end
            elseif taskType:find("BossKills") or taskType == "AnyBossKills" then
                if taskType == "AnyBossKills" then Toggles.AllBossesFarm = true
                else local bossName = ""; local diff = "Normal"; for _, d in ipairs(Tables.DiffList) do if taskType:find(d) then diff = d; bossName = taskType:gsub(d, ""):gsub("BossKills", ""); break end end; if bossName == "" then bossName = taskType:gsub("BossKills", "") end
                    local lowerB = bossName:lower(); if lowerB:find("strongest") then if lowerB:find("history") then bossName = "StrongestHistory" elseif lowerB:find("today") then bossName = "StrongestToday" end end
                    if table.find(Tables.MiniBossList, bossName) then Options.SelectedMob = {[bossName] = true}; Toggles.MobFarm = true
                    else local isRegular = table.find(Tables.SummonList, bossName); local isOther = table.find(Tables.OtherSummonList, bossName)
                        if isRegular then Options.SelectedSummon = bossName; Options.SelectedSummonDiff = diff; Toggles.AutoSummon = true; Toggles.SummonBossFarm = true
                        elseif isOther then Options.SelectedOtherSummon = bossName; Options.SelectedOtherSummonDiff = diff; Toggles.AutoOtherSummon = true; Toggles.OtherSummonFarm = true
                        else Options.SelectedBosses = {[bossName] = true}; Toggles.BossesFarm = true end
                    end
                end
            elseif taskType:find("Piece") or taskType:find("Found") then local pType = taskType:find("Dungeon") and "Dungeon" or (taskType:find("Slime") and "Slime" or "Demonite" or "Hogyoku"); UniversalPuzzleSolver(pType)
            elseif taskType:find("Has") and taskType:find("Race") then local race = taskType:gsub("Has", ""):gsub("Race", ""); if Plr:GetAttribute("CurrentRace") ~= race then Remotes.UseItem:FireServer("Use", "Race Reroll", 1) end
            elseif taskType == "MonarchClanCheck" then if Plr:GetAttribute("CurrentClan") ~= "Monarch" then Remotes.UseItem:FireServer("Use", "Clan Reroll", 1) end
            elseif taskType == "DeemedWorthy" then Remotes.UseItem:FireServer("Use", "Worthiness Fragment", 1) end
        end
    end
end
local function IsValidTarget(npc) if not npc or not npc.Parent then return false end; local hum = npc:FindFirstChildOfClass("Humanoid"); if not hum then return false end; if npc:FindFirstChild("IK_Active") then return true end; local minMaxHP = tonumber(Options.InstaKillMinHP or 0); local isEligible = Toggles.InstaKill and hum.MaxHealth >= minMaxHP; if isEligible then return (hum.Health > 0) or (npc == Shared.Target) else return (hum.Health > 0) end end
local function GetBestMobCluster(mobNamesDictionary)
    local allMobs = {}; local clusterRadius = 35; if type(mobNamesDictionary) ~= "table" then return nil end
    for _, npc in pairs(PATH.Mobs:GetChildren()) do if npc:IsA("Model") and npc:FindFirstChildOfClass("Humanoid") then local cleanName = npc.Name:gsub("%d+$", ""); if mobNamesDictionary[cleanName] and IsValidTarget(npc) then table.insert(allMobs, npc) end end end
    if #allMobs == 0 then return nil end
    local bestMob = allMobs[1]; local maxNearby = 0
    for _, mobA in ipairs(allMobs) do local nearbyCount = 0; local posA = mobA:GetPivot().Position; for _, mobB in ipairs(allMobs) do if (posA - mobB:GetPivot().Position).Magnitude <= clusterRadius then nearbyCount = nearbyCount + 1 end end; if nearbyCount > maxNearby then maxNearby = nearbyCount; bestMob = mobA end end
    return bestMob, maxNearby
end
local function EnsureQuestSettings()
    local settings = PGui.SettingsUI.MainFrame.Frame.Content.SettingsTabFrame
    local tog1 = settings:FindFirstChild("Toggle_EnableQuestRepeat", true); if tog1 and tog1.SettingsHolder.Off.Visible then Remotes.SettingsToggle:FireServer("EnableQuestRepeat", true); task.wait(0.3) end
    local tog2 = settings:FindFirstChild("Toggle_AutoQuestRepeat", true); if tog2 and tog2.SettingsHolder.Off.Visible then Remotes.SettingsToggle:FireServer("AutoQuestRepeat", true) end
end
local function GetBestQuestNPC()
    local QuestModule = Modules.Quests; local playerLevel = Plr.Data.Level.Value; local bestNPC = "QuestNPC1"; local highestLevel = -1
    for npcId, questData in pairs(QuestModule.RepeatableQuests) do local reqLevel = questData.recommendedLevel or 0; if playerLevel >= reqLevel and reqLevel > highestLevel then highestLevel = reqLevel; bestNPC = npcId end end
    return bestNPC
end
local function UpdateQuest()
    if not Toggles.LevelFarm then return end
    EnsureQuestSettings(); local targetNPC = GetBestQuestNPC(); local questUI = PGui.QuestUI.Quest
    if Shared.QuestNPC ~= targetNPC or not questUI.Visible then
        Remotes.QuestAbandon:FireServer("repeatable")
        local abandonTimeout = 0; while questUI.Visible and abandonTimeout < 15 do task.wait(0.2); abandonTimeout = abandonTimeout + 1 end
        Remotes.QuestAccept:FireServer(targetNPC)
        local acceptTimeout = 0; while not questUI.Visible and acceptTimeout < 20 do task.wait(0.2); acceptTimeout = acceptTimeout + 1; if acceptTimeout % 5 == 0 then Remotes.QuestAccept:FireServer(targetNPC) end end
        if questUI.Visible then Shared.QuestNPC = targetNPC end
    end
end
local function GetPityTarget()
    if not Toggles.PityBossFarm then return nil end
    local current, max = GetCurrentPity(); local buildBosses = Options.SelectedBuildPity or {}; local useName = Options.SelectedUsePity; if not useName then return nil end
    local isUseTurn = (current >= (max - 1))
    if isUseTurn then for _, npc in pairs(PATH.Mobs:GetChildren()) do if IsStrictBossMatch(npc.Name, useName) and IsValidTarget(npc) then local island = Shared.BossTIMap[useName] or "Boss"; return npc, island, "Boss" end end
    else for bossName, enabled in pairs(buildBosses) do if enabled then for _, npc in pairs(PATH.Mobs:GetChildren()) do if IsStrictBossMatch(npc.Name, bossName) and IsValidTarget(npc) then local island = Shared.BossTIMap[bossName] or "Boss"; return npc, island, "Boss" end end end end end
    return nil
end
local function GetAllMobTarget()
    if not Toggles.AllMobFarm then Shared.AllMobIdx = 1; return nil end
    local rotateList = {}; for _, mobName in ipairs(Tables.MobList) do if mobName ~= "TrainingDummy" then table.insert(rotateList, mobName) end end
    if #rotateList == 0 then return nil end
    if Shared.AllMobIdx > #rotateList then Shared.AllMobIdx = 1 end
    local targetMobName = rotateList[Shared.AllMobIdx]; local target, count = GetBestMobCluster({[targetMobName] = true})
    if target then local island = GetNearestIsland(target:GetPivot().Position, target.Name); return target, island, "Mob"
    else Shared.AllMobIdx = Shared.AllMobIdx + 1; if Shared.AllMobIdx > #rotateList then Shared.AllMobIdx = 1 end; return nil end
end
local function GetLevelFarmTarget()
    if not Toggles.LevelFarm then return nil end
    UpdateQuest()
    if not PGui.QuestUI.Quest.Visible then return nil end
    local questData = Modules.Quests.RepeatableQuests[Shared.QuestNPC]; if not questData or not questData.requirements[1] then return nil end
    local targetMobType = questData.requirements[1].npcType; local matches = {}
    for _, npc in pairs(PATH.Mobs:GetChildren()) do if npc:IsA("Model") and npc:FindFirstChildOfClass("Humanoid") then if IsSmartMatch(npc.Name, targetMobType) then local cleanName = npc.Name:gsub("%d+$", ""); matches[cleanName] = true end end end
    local bestMob, count = GetBestMobCluster(matches)
    if bestMob then local island = GetNearestIsland(bestMob:GetPivot().Position, bestMob.Name); return bestMob, island, "Mob" end
    return nil
end
local function GetOtherTarget()
    if not Toggles.OtherSummonFarm then return nil end
    local selected = Options.SelectedOtherSummon; if not selected then return nil end
    local lowerSelected = selected:lower()
    for _, npc in pairs(PATH.Mobs:GetChildren()) do local name = npc.Name:lower(); local isMatch = false
        if lowerSelected:find("strongest") then if name:find("strongest") and ((lowerSelected:find("history") and name:find("history")) or (lowerSelected:find("today") and name:find("today"))) then isMatch = true end
        elseif name:find(lowerSelected) then isMatch = true end
        if isMatch and IsValidTarget(npc) then local island = GetNearestIsland(npc:GetPivot().Position, npc.Name); return npc, island, "Boss" end
    end
    return nil
end
local function GetSummonTarget()
    if not Toggles.SummonBossFarm then return nil end
    local selected = Options.SelectedSummon; if not selected then return nil end
    local workspaceName = SummonMap[selected] or (selected.."Boss")
    for _, npc in pairs(PATH.Mobs:GetChildren()) do if npc.Name:lower():find(workspaceName:lower()) then if IsValidTarget(npc) then return npc, "Boss", "Boss" end end end
    return nil
end
local function GetWorldBossTarget()
    if Toggles.AllBossesFarm then for _, npc in pairs(PATH.Mobs:GetChildren()) do local name = npc.Name; if name:find("Boss") and not table.find(Tables.MiniBossList, name) then if IsValidTarget(npc) then local island = "Boss"; for dName, iName in pairs(Shared.BossTIMap) do if IsStrictBossMatch(name, dName) then island = iName; break end end; return npc, island, "Boss" end end end end
    if Toggles.BossesFarm then local selected = Options.SelectedBosses or {}; for bossDisplayName, isEnabled in pairs(selected) do if isEnabled then for _, npc in pairs(PATH.Mobs:GetChildren()) do if IsStrictBossMatch(npc.Name, bossDisplayName) and not table.find(Tables.MiniBossList, npc.Name) then if IsValidTarget(npc) then local island = Shared.BossTIMap[bossDisplayName] or "Boss"; return npc, island, "Boss" end end end end end end
    return nil
end
local function GetMobTarget()
    if not Toggles.MobFarm then Shared.MobIdx = 1; return nil end
    local selectedDict = Options.SelectedMob or {}; local enabledMobs = {}
    for mob, enabled in pairs(selectedDict) do if enabled then table.insert(enabledMobs, mob) end end; table.sort(enabledMobs)
    if #enabledMobs == 0 then return nil end
    if Shared.MobIdx > #enabledMobs then Shared.MobIdx = 1 end
    local targetMobName = enabledMobs[Shared.MobIdx]; local target, count = GetBestMobCluster({[targetMobName] = true})
    if target then local island = GetNearestIsland(target:GetPivot().Position, target.Name); return target, island, "Mob"
    else Shared.MobIdx = Shared.MobIdx + 1; return nil end
end
local function ShouldMainWait()
    if not Toggles.AltBossFarm then return false end
    local selectedAlts = {}
    for i=1,5 do local val = Options["SelectedAlt_"..i]; local name = (typeof(val) == "Instance" and val:IsA("Player")) and val.Name or tostring(val); if name and name ~= "" and name ~= "nil" and name ~= "None" then table.insert(selectedAlts, name) end end
    if #selectedAlts == 0 then return false end
    for _, altName in ipairs(selectedAlts) do local currentDmg = Shared.AltDamage[altName] or 0; if currentDmg < 10 then return true end end
    return false
end
local function GetAltHelpTarget()
    if not Toggles.AltBossFarm then return nil end
    local targetBossName = Options.SelectedAltBoss; if not targetBossName then return nil end
    local targetNPC = nil
    for _, npc in pairs(PATH.Mobs:GetChildren()) do if IsStrictBossMatch(npc.Name, targetBossName) then if IsValidTarget(npc) then targetNPC = npc; break end end end
    if not targetNPC then FireBossRemote(targetBossName, Options.SelectedAltDiff or "Normal"); task.wait(0.5); return nil end
    Shared.AltActive = ShouldMainWait()
    local island = Shared.BossTIMap[targetBossName] or "Boss"; return targetNPC, island, "Boss"
end
local PriorityTasks = {"Boss", "Pity Boss", "Summon [Other]", "Summon", "Level Farm", "All Mob Farm", "Mob", "Merchant", "Alt Help"}
local function CheckTask(taskType)
    if taskType == "Merchant" then if Toggles.AutoMerchant and Shared.MerchantBusy then return true, nil, "None" end; return nil
    elseif taskType == "Pity Boss" then return GetPityTarget()
    elseif taskType == "Summon [Other]" then return GetOtherTarget()
    elseif taskType == "Summon" then return GetSummonTarget()
    elseif taskType == "Boss" then return GetWorldBossTarget()
    elseif taskType == "Level Farm" then return GetLevelFarmTarget()
    elseif taskType == "All Mob Farm" then return GetAllMobTarget()
    elseif taskType == "Mob" then return GetMobTarget()
    elseif taskType == "Alt Help" then return GetAltHelpTarget()
    end
    return nil
end
local function GetNearestAuraTarget()
    local nearest = nil; local maxRange = tonumber(Options.KillAuraRange or 200); local lastDist = maxRange
    local char = Plr.Character; local root = char and char:FindFirstChild("HumanoidRootPart"); if not root then return nil end
    local myPos = root.Position; local mobFolder = workspace:FindFirstChild("NPCs"); if not mobFolder then return nil end
    for _, v in ipairs(mobFolder:GetChildren()) do if v:IsA("Model") then local npcPos = v:GetPivot().Position; local dist = (myPos - npcPos).Magnitude; if dist <= lastDist then local hum = v:FindFirstChildOfClass("Humanoid"); if hum and hum.Health > 0 then nearest = v; lastDist = dist end end end end
    return nearest
end
local function Func_KillAura()
    while Toggles.KillAura do
        if IsBusy() then task.wait(0.1); continue end
        local target = GetNearestAuraTarget()
        if target then EquipWeapon(); local targetPos = target:GetPivot().Position; pcall(function() Remotes.M1:FireServer(targetPos) end) end
        task.wait(tonumber(Options.KillAuraCD or 0.12))
    end
end
local function FarmUsesTeleportMovement() return Toggles.InstantTPBypass or (Options.SelectedMovementType == "Teleport") end
local function ExecuteFarmLogic(target, island, farmType)
    local char = GetCharacter(); local root = char and char:FindFirstChild("HumanoidRootPart"); if not char or not target or Shared.Recovering or not root then return end
    if Shared.MovingIsland then return end; Shared.Target = target
    if Toggles.AltBossFarm and farmType == "Boss" then Shared.AltActive = ShouldMainWait() else Shared.AltActive = false end
    if Toggles.IslandTP then if island and island ~= "" and island ~= "Unknown" and island ~= Shared.Island then Shared.MovingIsland = true; Remotes.TP_Portal:FireServer(island); task.wait(tonumber(Options.IslandTPCD or 0.8)); Shared.Island = island; Shared.MovingIsland = false; return end end
    local targetPivot = target:GetPivot(); local targetPos = targetPivot.Position; local distVal = tonumber(Options.Distance or 10); local posType = Options.SelectedFarmType or "Behind"
    local finalPos; local ikTag = target:FindFirstChild("IK_Active")
    if ikTag and Options.InstaKillType == "V2" and Toggles.InstaKill then local startTime = ikTag:GetAttribute("TriggerTime") or 0; if tick() - startTime >= 3 then root.CFrame = CFrame.new(targetPos + Vector3.new(0,300,0)); root.AssemblyLinearVelocity = Vector3.zero; return end end
    if Shared.AltActive then finalPos = targetPos + Vector3.new(0,120,0)
    elseif posType == "Above" then finalPos = targetPos + Vector3.new(0,distVal,0)
    elseif posType == "Below" then finalPos = targetPos + Vector3.new(0,-distVal,0)
    else finalPos = (targetPivot * CFrame.new(0,0,distVal)).Position end
    local finalDestination = CFrame.lookAt(finalPos, targetPos)
    local distToSlot = (root.Position - finalPos).Magnitude; local moveDeadzone = (farmType == "Boss") and math.max(10, distVal*0.45) or math.max(3, distVal*0.22)
    if distToSlot > moveDeadzone then
        if FarmUsesTeleportMovement() then if Shared.FarmMoveTween then Shared.FarmMoveTween:Cancel(); Shared.FarmMoveTween = nil end; root.CFrame = finalDestination
        else local distance = distToSlot; local speed = tonumber(Options.TweenSpeed or 180); if Shared.FarmMoveTween then Shared.FarmMoveTween:Cancel(); Shared.FarmMoveTween = nil end; local ts = game:GetService("TweenService"); local tw = ts:Create(root, TweenInfo.new(distance/speed, Enum.EasingStyle.Linear), {CFrame = finalDestination}); Shared.FarmMoveTween = tw; tw.Completed:Connect(function() if Shared.FarmMoveTween == tw then Shared.FarmMoveTween = nil end end); tw:Play() end
    end
    root.AssemblyLinearVelocity = Vector3.zero; root.AssemblyAngularVelocity = Vector3.zero
end
local function Func_WebhookLoop() while Toggles.SendWebhook do PostToWebhook(); task.wait(math.max(Options.WebhookDelay or 5, 0.5)*60) end end
local function Func_AutoHaki()
    while task.wait(0.5) do
        if Toggles.ObserHaki and not CheckObsHaki() then Remotes.ObserHaki:FireServer("Toggle") end
        if Toggles.ArmHaki and not CheckArmHaki() then Remotes.ArmHaki:FireServer("Toggle"); task.wait(0.5) end
        if Toggles.ConquerorHaki then if Toggles.OnlyTarget then if not Shared.Farm or not Shared.Target or not Shared.Target.Parent then continue end end; Remotes.ConquerorHaki:FireServer("Activate") end
    end
end
local function Func_AutoM1() while task.wait(Options.M1Speed or 0.2) do if Toggles.AutoM1 then Remotes.M1:FireServer() end end end
local function Func_AutoSkill()
    local keyToEnum = {Z=Enum.KeyCode.Z, X=Enum.KeyCode.X, C=Enum.KeyCode.C, V=Enum.KeyCode.V, F=Enum.KeyCode.F}; local keyToSlot = {Z=1, X=2, C=3, V=4, F=5}; local priority = {"Z","X","C","V","F"}
    while task.wait() do
        if not Toggles.AutoSkill then continue end
        local target = Shared.Target
        if Toggles.OnlyTarget and (not Shared.Farm or not target or not target.Parent) then continue end
        local canExecute = true
        if Toggles.AutoSkill_BossOnly then if not target or not target.Parent then canExecute = false else local npcHum = target:FindFirstChildOfClass("Humanoid"); local isRealBoss = target.Name:find("Boss") and not table.find(Tables.MiniBossList, target.Name); local hpPercent = npcHum and (npcHum.Health/npcHum.MaxHealth*100) or 101; local threshold = tonumber(Options.AutoSkill_BossHP or 100); if not isRealBoss or hpPercent > threshold then canExecute = false end end end
        if canExecute and target and target.Parent then if target:FindFirstChild("IK_Active") and Options.InstaKillType == "V1" then canExecute = false end end
        if not canExecute then continue end
        local char = GetCharacter(); local tool = char and char:FindFirstChildOfClass("Tool"); if not tool then continue end
        local toolName = tool.Name; local toolType = GetToolTypeFromModule(toolName); local useMode = Options.AutoSkillType or "Normal"; local selected = Options.SelectedSkills or {}
        if useMode == "Instant" then for _, key in ipairs(priority) do if selected[key] then if toolType == "Power" then Remotes.UseFruit:FireServer("UseAbility", {["FruitPower"] = toolName:gsub(" Fruit", ""), ["KeyCode"] = keyToEnum[key]}) else Remotes.UseSkill:FireServer(keyToSlot[key]) end end end; task.wait(.01)
        else local mainFrame = PGui:FindFirstChild("CooldownUI") and PGui.CooldownUI:FindFirstChild("MainFrame"); if not mainFrame then continue end
            for _, key in ipairs(priority) do if selected[key] then if IsSkillReady(key) then if toolType == "Power" then Remotes.UseFruit:FireServer("UseAbility", {["FruitPower"] = toolName:gsub(" Fruit", ""), ["KeyCode"] = keyToEnum[key]}) else Remotes.UseSkill:FireServer(keyToSlot[key]) end; task.wait(0.1); break end end end
        end
    end
end
local function Func_AutoCombo()
    Shared.ComboIdx = 1
    while Toggles.AutoCombo do
        task.wait(0.1)
        local rawPattern = Options.ComboPattern; if not rawPattern or rawPattern == "" then continue end; Shared.ParsedCombo = {}; for item in string.gmatch(rawPattern:upper():gsub("%s+", ""), "([^,>]+)") do table.insert(Shared.ParsedCombo, item) end; if #Shared.ParsedCombo == 0 then continue end; if Shared.ComboIdx > #Shared.ParsedCombo then Shared.ComboIdx = 1 end
        if IsBusy() then local waitStart = tick(); repeat task.wait(0.1) until not IsBusy() or (tick()-waitStart > 8) end; task.wait(0.4)
        if Toggles.ComboBossOnly then if not Shared.Target or not Shared.Target.Parent or not Shared.Target.Name:lower():find("boss") then Shared.ComboIdx = 1; task.wait(0.5); continue end end
        local currentAction = Shared.ParsedCombo[Shared.ComboIdx]
        local waitTime = tonumber(currentAction)
        if waitTime then if Options.ComboMode == "Normal" then task.wait(waitTime) end; Shared.ComboIdx = Shared.ComboIdx + 1; continue end
        if IsSkillReady(currentAction) then
            local isF = (currentAction == "F")
            if isF then
                Shared.GlobalPrio = "COMBO"
                local cTitle = Options.Title_Combo; local cRune = Options.Rune_Combo; if cTitle and cTitle ~= "None" then Remotes.EquipTitle:FireServer(cTitle) end; if cRune and cRune ~= "None" then Remotes.EquipRune:FireServer("Equip", cRune) end
                Shared.LastSwitch.Title = cTitle; Shared.LastSwitch.Rune = cRune; task.wait(0.7)
                local uiConfirmed = false
                repeat EquipWeapon(); Remotes.UseSkill:FireServer(5); local check = tick(); repeat task.wait(0.1); if not IsSkillReady("F") then uiConfirmed = true end until uiConfirmed or (tick()-check > 1.0) until uiConfirmed or not Toggles.AutoCombo
                local ffStarted = false; local catchTimer = tick()
                repeat task.wait(); if IsBusy() then ffStarted = true end until ffStarted or (tick()-catchTimer > 2.0)
                if ffStarted then repeat task.wait(0.1) until not IsBusy() or (tick()-catchTimer > 15) else task.wait(2.5) end
                Shared.GlobalPrio = "FARM"; Shared.LastSwitch.Title = ""; Shared.LastSwitch.Rune = ""; Shared.ComboIdx = Shared.ComboIdx + 1; task.wait(0.3)
            else
                local slot = ({Z=1, X=2, C=3, V=4})[currentAction] or 1
                local stepDone = false
                repeat Remotes.UseSkill:FireServer(slot); local check = tick(); repeat task.wait(0.1); if not IsSkillReady(currentAction) or IsBusy() then stepDone = true end until stepDone or (tick()-check > 1.2) until stepDone or not Toggles.AutoCombo
                if stepDone then Shared.ComboIdx = Shared.ComboIdx + 1; task.wait(0.2) end
            end
        else task.wait(0.2) end
    end
end
local function Func_AutoStats()
    local pointsPath = Plr:WaitForChild("Data"):WaitForChild("StatPoints"); local MAX_STAT_LEVEL = 13000
    while task.wait(1) do
        if Toggles.AutoStats then
            local availablePoints = pointsPath.Value
            if availablePoints > 0 then
                local selectedStats = Options.SelectedStats or {}; local activeStats = {}
                for statName, enabled in pairs(selectedStats) do if enabled then local currentLevel = Shared.Stats[statName] or 0; if currentLevel < MAX_STAT_LEVEL then table.insert(activeStats, statName) end end end
                local statCount = #activeStats
                if statCount > 0 then local pointsPerStat = math.floor(availablePoints/statCount); if pointsPerStat > 0 then for _, stat in ipairs(activeStats) do Remotes.AddStat:FireServer(stat, pointsPerStat) end else Remotes.AddStat:FireServer(activeStats[1], availablePoints) end end
            end
        end
        if not Toggles.AutoStats then break end
    end
end
local function AutoRollStatsLoop()
    local selectedStats = Options.SelectedGemStats or {}; local selectedRanks = Options.SelectedRank or {}
    local hasStat, hasRank = false, false; for _ in pairs(selectedStats) do hasStat = true break end; for _ in pairs(selectedRanks) do hasRank = true break end
    if not hasStat or not hasRank then Library:Notify({Title = "Error", Description = "Select at least one Stat and one Rank first!", Duration = 5}); Toggles.AutoRollStats = false; return end
    while Toggles.AutoRollStats do
        if not next(Shared.GemStats) then task.wait(0.1); continue end
        local workDone = true
        for _, statName in ipairs(Tables.GemStat) do
            if selectedStats[statName] then local currentData = Shared.GemStats[statName]; if currentData then local currentRank = currentData.Rank; if not selectedRanks[currentRank] then workDone = false; pcall(function() Remotes.RerollSingleStat:InvokeServer(statName) end); task.wait(tonumber(Options.StatsRollCD or 0.1)); break end end
        end
        if workDone then Library:Notify({Title = "Success", Description = "Successfully rolled selected stats.", Duration = 5}); Toggles.AutoRollStats = false; break end
        task.wait()
    end
end
local function Func_UnifiedRollManager()
    while task.wait() do
        if Toggles.AutoTrait then
            local traitUI = PGui:WaitForChild("TraitRerollUI").MainFrame.Frame.Content.TraitPage.TraitGottenFrame.Holder.Trait.TraitGotten; local confirmFrame = PGui.TraitRerollUI.MainFrame.Frame.Content:FindFirstChild("AreYouSureYouWantToRerollFrame")
            local currentTrait = traitUI.Text; local selected = Options.SelectedTrait or {}
            if selected[currentTrait] then Library:Notify({Title = "Success", Description = "Success! Got Trait: "..currentTrait, Duration = 5}); Toggles.AutoTrait = false
            else pcall(SyncTraitAutoSkip); if confirmFrame and confirmFrame.Visible then Remotes.TraitConfirm:FireServer(true); task.wait(0.1) end; Remotes.Roll_Trait:FireServer(); task.wait(Options.RollCD or 0.3) end
            continue
        end
        if Toggles.AutoRace then
            local currentRace = Plr:GetAttribute("CurrentRace"); local selected = Options.SelectedRace or {}
            if selected[currentRace] then Library:Notify({Title = "Success", Description = "Success! Got Race: "..currentRace, Duration = 5}); Toggles.AutoRace = false
            else pcall(SyncRaceSettings); Remotes.UseItem:FireServer("Use", "Race Reroll", 1); task.wait(Options.RollCD or 0.3) end
            continue
        end
        if Toggles.AutoClan then
            local currentClan = Plr:GetAttribute("CurrentClan"); local selected = Options.SelectedClan or {}
            if selected[currentClan] then Library:Notify({Title = "Success", Description = "Success! Got Clan: "..currentClan, Duration = 5}); Toggles.AutoClan = false
            else pcall(SyncClanSettings); Remotes.UseItem:FireServer("Use", "Clan Reroll", 1); task.wait(Options.RollCD or 0.3) end
            continue
        end
        task.wait(0.4)
    end
end
local function EnsureRollManager() Thread("UnifiedRollManager", Func_UnifiedRollManager, Toggles.AutoTrait or Toggles.AutoRace or Toggles.AutoClan) end
local function AutoSpecPassiveLoop()
    pcall(SyncSpecPassiveAutoSkip); task.wait(Options.SpecRollCD or 0.1)
    while Toggles.AutoSpec do
        local targetWeapons = Options.SelectedPassive or {}; local targetPassives = Options.SelectedSpec or {}; local workDone = false
        if type(Shared.Passives) ~= "table" then Shared.Passives = {} end
        for weaponName, isWeaponEnabled in pairs(targetWeapons) do
            if not isWeaponEnabled then continue end
            local currentData = Shared.Passives[weaponName]; local currentName = "None"; local currentBuffs = {}
            if type(currentData) == "table" then currentName = currentData.Name or "None"; currentBuffs = currentData.RolledBuffs or {} elseif type(currentData) == "string" then currentName = currentData end
            local isCorrectName = targetPassives[currentName]; local meetsAllStats = true
            if isCorrectName then if type(currentBuffs) == "table" then for statKey, rolledValue in pairs(currentBuffs) do local sliderId = "Min_"..currentName:gsub("%s+", "").."_"..statKey; local minRequired = Options[sliderId] or 0; if tonumber(rolledValue) and rolledValue < minRequired then meetsAllStats = false; break end end end else meetsAllStats = false end
            if not isCorrectName or not meetsAllStats then workDone = true; Remotes.SpecPassiveReroll:FireServer(weaponName); local startWait = tick(); repeat task.wait(); local checkData = Shared.Passives[weaponName]; local checkName = (type(checkData)=="table" and checkData.Name) or (type(checkData)=="string" and checkData) or "" until (checkName ~= currentName) or (tick()-startWait > 1.5); break end
        end
        if not workDone then Library:Notify({Title = "Done", Description = "Done", Duration = 5}); Toggles.AutoSpec = false; break end
        task.wait()
    end
end
local function AutoSkillTreeLoop()
    while Toggles.AutoSkillTree do
        task.wait(0.5)
        if not next(Shared.SkillTree.Nodes) and Shared.SkillTree.SkillPoints == 0 then continue end
        local points = Shared.SkillTree.SkillPoints; if points <= 0 then continue end
        for _, branch in pairs(Modules.SkillTree.Branches) do for _, node in ipairs(branch.Nodes) do local nodeId = node.Id; local cost = node.Cost
            if not Shared.SkillTree.Nodes[nodeId] then if points >= cost then pcall(function() Remotes.SkillTreeUpgrade:FireServer(nodeId) end); Shared.SkillTree.SkillPoints = Shared.SkillTree.SkillPoints - cost; task.wait(0.3) end; break end
        end end
    end
end
local function Func_ArtifactMilestone() local currentMilestone = 1; while Toggles.ArtifactMilestone do Remotes.ArtifactClaim:FireServer(currentMilestone); currentMilestone = currentMilestone + 1; if currentMilestone > 40 then currentMilestone = 1 end; task.wait(1) end end
local function VoteDungeonDifficultyOnce()
    if not (Toggles.AutoDiff and Options.SelectedDiff) then return false end
    local diffName = tostring(Options.SelectedDiff):lower(); local diffVoteMap = {easy="Easy", normal="Easy", medium="Medium", hard="Hard", extreme="Extreme"}; local voteDiff = diffVoteMap[diffName]; if not voteDiff then return false end
    local ok = false; pcall(function() Remotes.DungeonWaveVote:FireServer(voteDiff); ok = true end); return ok
end
local function Func_AutoDungeonDifficulty() while Toggles.AutoDiff do VoteDungeonDifficultyOnce(); task.wait(1) end end
local function FireDungeonReplayVote() if not Remotes.DungeonWaveReplayVote then return false end; local ok = false; pcall(function() Remotes.DungeonWaveReplayVote:FireServer("sponsor"); ok = true end); return ok end
local function Func_AutoReplay() while Toggles.AutoReplay do FireDungeonReplayVote(); task.wait(1) end end
local function GetNearestDungeonTarget()
    local char = GetCharacter(); local root = char and char:FindFirstChild("HumanoidRootPart"); if not root then return nil end
    local closest, closestDist = nil, math.huge
    for _, npc in ipairs(PATH.Mobs:GetChildren()) do if npc:IsA("Model") and npc ~= char then local hum = npc:FindFirstChildOfClass("Humanoid"); local npcRoot = npc:FindFirstChild("HumanoidRootPart"); if hum and hum.Health > 0 and npcRoot then local dist = (root.Position - npcRoot.Position).Magnitude; if dist < closestDist then closest = npc; closestDist = dist end end end end
    return closest
end
local function IsDungeonTargetAlive(target) if not (target and target.Parent) then return false end; local hum = target:FindFirstChildOfClass("Humanoid"); local npcRoot = target:FindFirstChild("HumanoidRootPart"); return hum and hum.Health > 0 and npcRoot end
local function GetDungeonTargetWithLock(currentTarget)
    local char = GetCharacter(); local root = char and char:FindFirstChild("HumanoidRootPart"); if not root then return nil end
    if IsDungeonTargetAlive(currentTarget) then local npcRoot = currentTarget:FindFirstChild("HumanoidRootPart"); if npcRoot and (root.Position - npcRoot.Position).Magnitude <= 120 then return currentTarget end end
    return GetNearestDungeonTarget()
end
local function Func_DungeonAutofarm()
    local lockedTarget = nil
    while Toggles.DungeonAutofarm do
        local target = GetDungeonTargetWithLock(lockedTarget)
        if target then
            lockedTarget = target
            local targetPivot = target:GetPivot(); local targetPos = targetPivot.Position; local distVal = tonumber(Options.DungeonFarmDistance or 10); local posType = Options.DungeonFarmType or "Behind"; local hoverY = 2.5
            local finalPos = (posType == "Above") and (targetPos + Vector3.new(0,distVal,0)) or (posType == "Below") and (targetPos + Vector3.new(0,-distVal,0)) or (targetPivot * CFrame.new(0,hoverY,distVal)).Position
            local finalCF = CFrame.lookAt(finalPos, targetPos)
            local char = GetCharacter(); local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                local distTo = (root.Position - finalPos).Magnitude; local moveDeadzone = math.max(3, distVal*0.22)
                if FarmUsesTeleportMovement() then if Shared.DungeonMoveTween then Shared.DungeonMoveTween:Cancel(); Shared.DungeonMoveTween = nil end; if distTo > moveDeadzone then root.CFrame = finalCF end
                else local speed = tonumber(Options.TweenSpeed or 180); if distTo > moveDeadzone then if Shared.DungeonMoveTween then Shared.DungeonMoveTween:Cancel(); Shared.DungeonMoveTween = nil end; local ts = game:GetService("TweenService"); local tw = ts:Create(root, TweenInfo.new(math.max(0.05, distTo/speed), Enum.EasingStyle.Linear), {CFrame = finalCF}); Shared.DungeonMoveTween = tw; tw.Completed:Connect(function() if Shared.DungeonMoveTween == tw then Shared.DungeonMoveTween = nil end end); tw:Play() else root.CFrame = CFrame.lookAt(root.Position, targetPos) end end
                root.AssemblyLinearVelocity = Vector3.zero; root.AssemblyAngularVelocity = Vector3.zero
                EquipWeapon(); pcall(function() Remotes.M1:FireServer(targetPos) end)
            end
        else
            lockedTarget = nil
            if Shared.DungeonMoveTween then Shared.DungeonMoveTween:Cancel(); Shared.DungeonMoveTween = nil end
        end
        task.wait(0.12)
    end
    if Shared.DungeonMoveTween then Shared.DungeonMoveTween:Cancel(); Shared.DungeonMoveTween = nil end
end
local function Func_AutoDungeon()
    local lastDiffSelect = 0
    while Toggles.AutoDungeon do
        task.wait(1)
        local selected = Options.SelectedDungeon; if not selected then continue end
        if Toggles.AutoDiff and tick()-lastDiffSelect >= 1.2 then if VoteDungeonDifficultyOnce() then lastDiffSelect = tick() end end
        if Toggles.AutoReplay then FireDungeonReplayVote() end
        local dungeonUI = PGui:FindFirstChild("DungeonPortalJoinUI"); local leaveBtn = dungeonUI and dungeonUI:FindFirstChild("LeaveButton")
        if leaveBtn and leaveBtn.Visible then if Toggles.AutoReplay then if not FireDungeonReplayVote() then local diff = (Toggles.AutoDiff and Options.SelectedDiff) and tostring(Options.SelectedDiff) or nil; if diff then Remotes.OpenDungeon:FireServer(tostring(selected), diff) else Remotes.OpenDungeon:FireServer(tostring(selected)) end end end; continue end
        local targetIsland = (selected == "BossRush") and "Sailor" or "Dungeon"
        if tick() - Shared.LastDungeon > 15 then local diff = (Toggles.AutoDiff and Options.SelectedDiff) and tostring(Options.SelectedDiff) or nil; if diff then Remotes.OpenDungeon:FireServer(tostring(selected), diff) else Remotes.OpenDungeon:FireServer(tostring(selected)) end; Shared.LastDungeon = tick(); task.wait(1) end
        if not (leaveBtn and leaveBtn.Visible) then
            local portal = workspace:FindFirstChild("ActiveDungeonPortal")
            if not portal then if Shared.Island ~= targetIsland then Remotes.TP_Portal:FireServer(targetIsland); Shared.Island = targetIsland; task.wait(2.5) end
            else local char = GetCharacter(); local root = char and char:FindFirstChild("HumanoidRootPart"); if root then root.CFrame = portal.CFrame; task.wait(0.2); local prompt = portal:FindFirstChild("JoinPrompt"); if prompt then fireproximityprompt(prompt); task.wait(1) end end
            end
        end
    end
end
local MerchantTimerLabel
local function Func_AutoMerchant()
    local MerchantUI = UI.Merchant.Regular; local Holder = MerchantUI:FindFirstChild("Holder", true); local LastTimerText = ""
    local function StartPurchaseSequence()
        if Shared.MerchantExecute then return end; Shared.MerchantExecute = true
        if Shared.FirstMerchantSync then MerchantUI.Enabled = true; MerchantUI.MainFrame.Visible = true; task.wait(0.5); local closeBtn = MerchantUI:FindFirstChild("CloseButton", true); if closeBtn then gsc(closeBtn); task.wait(1.8) end end
        OpenMerchantInterface(); task.wait(2)
        local itemsWithStock = {}
        for _, child in pairs(Holder:GetChildren()) do if child:IsA("Frame") and child.Name ~= "Item" then local stockLabel = child:FindFirstChild("StockAmountForThatItem", true); local currentStock = 0; if stockLabel then currentStock = tonumber(stockLabel.Text:match("%d+")) or 0 end; Shared.CurrentStock[child.Name] = currentStock; if currentStock > 0 then table.insert(itemsWithStock, {Name = child.Name, Stock = currentStock}) end end end
        if #itemsWithStock > 0 then local selectedItems = Options.SelectedMerchantItems or {}; for _, item in ipairs(itemsWithStock) do if selectedItems[item.Name] then pcall(function() Remotes.MerchantBuy:InvokeServer(item.Name, 99) end); task.wait(math.random(11,17)/10) end end end
        if MerchantUI.MainFrame then MerchantUI.MainFrame.Visible = false end; Shared.FirstMerchantSync = true; Shared.MerchantExecute = false
    end
    local function SyncClock() OpenMerchantInterface(); task.wait(1); local Label = MerchantUI and MerchantUI:FindFirstChild("RefreshTimerLabel", true); if Label and Label.Text:find(":") then local serverSecs = GetSecondsFromTimer(Label.Text); if serverSecs then Shared.LocalMerchantTime = serverSecs end end; if MerchantUI.MainFrame then MerchantUI.MainFrame.Visible = false end end
    SyncClock()
    while Toggles.AutoMerchant do
        local Label = MerchantUI:FindFirstChild("RefreshTimerLabel", true)
        if Label and Label.Text ~= "" then local currentText = Label.Text; local s = GetSecondsFromTimer(currentText); if s then Shared.LocalMerchantTime = s; if currentText ~= LastTimerText then LastTimerText = currentText; Shared.LastTimerTick = tick() end else Shared.LocalMerchantTime = math.max(0, Shared.LocalMerchantTime - 1) end
        else Shared.LocalMerchantTime = math.max(0, Shared.LocalMerchantTime - 1) end
        local isRefresh = (Shared.LocalMerchantTime <= 1) or (Shared.LocalMerchantTime >= 1799)
        if not Shared.FirstMerchantSync or isRefresh then task.spawn(StartPurchaseSequence) end
        if tick() - Shared.LastTimerTick > 30 then task.spawn(SyncClock); Shared.LastTimerTick = tick() end
        if MerchantTimerLabel then MerchantTimerLabel:SetText(FormatSecondsToTimer(Shared.LocalMerchantTime)) end
        task.wait(1)
    end
end
local function Func_AutoTrade()
    while task.wait(0.5) do
        local inTradeUI = PGui:FindFirstChild("InTradingUI") and PGui.InTradingUI.MainFrame.Visible; local requestUI = PGui:FindFirstChild("TradeRequestUI") and PGui.TradeRequestUI.TradeRequest.Visible
        if Toggles.ReqTradeAccept and requestUI then Remotes.TradeRespond:FireServer(true); task.wait(1) end
        if Toggles.ReqTrade and not inTradeUI and not requestUI then local targetPlr = Options.SelectedTradePlr; if targetPlr and typeof(targetPlr) == "Instance" then Remotes.TradeSend:FireServer(targetPlr.UserId); task.wait(3) end end
        if inTradeUI and Toggles.AutoAccept then
            local selectedItems = Options.SelectedTradeItems or {}; local itemsToAdd = {}
            for itemName, enabled in pairs(selectedItems) do if enabled then local alreadyInTrade = false; if Shared.TradeState.myItems then for _, tradeItem in pairs(Shared.TradeState.myItems) do if tradeItem.name == itemName then alreadyInTrade = true break end end end; if not alreadyInTrade then table.insert(itemsToAdd, itemName) end end end
            if #itemsToAdd > 0 then for _, itemName in ipairs(itemsToAdd) do local invQty = 0; for _, item in pairs(Shared.Cached.Inv) do if item.name == itemName then invQty = item.quantity break end end; if invQty > 0 then Remotes.TradeAddItem:FireServer("Items", itemName, invQty); task.wait(0.5) end end
            else if not Shared.TradeState.myReady then Remotes.TradeReady:FireServer(true) elseif Shared.TradeState.myReady and Shared.TradeState.theirReady then if Shared.TradeState.phase == "confirming" and not Shared.TradeState.myConfirm then Remotes.TradeConfirm:FireServer() end end end
        end
    end
end
local function Func_AutoChest()
    while task.wait(2) do if not Toggles.AutoChest then break end; local selected = Options.SelectedChests; if type(selected) ~= "table" then continue end; for _, rarityName in ipairs(Tables.Rarities or {}) do if selected[rarityName] then local fullName = (rarityName == "Aura Crate") and "Aura Crate" or (rarityName.." Chest"); pcall(function() Remotes.UseItem:FireServer("Use", fullName, 10000) end); task.wait(1) end end end
end
local function Func_AutoCraft()
    while task.wait(1) do
        if Toggles.AutoCraftItem then
            local selected = Options.SelectedCraftItems or {}
            for _, item in pairs(Shared.Cached.Inv) do
                if selected["DivineGrail"] and item.name == "Broken Sword" and item.quantity >= 3 then local totalPossible = math.floor(item.quantity/3); local craftAmount = math.min(totalPossible, 99); pcall(function() Remotes.GrailCraft:InvokeServer("DivineGrail", craftAmount) end); task.wait(0.5) end
                if selected["SlimeKey"] and item.name == "Slime Shard" and item.quantity >= 2 then local totalPossible = math.floor(item.quantity/2); local craftAmount = math.min(totalPossible, 99); pcall(function() Remotes.SlimeCraft:InvokeServer("SlimeKey", craftAmount) end) end
            end
        end
        if not Toggles.AutoCraftItem then break end
    end
end
local function Func_ArtifactAutomation()
    while task.wait(5) do
        if not Shared.ArtifactSession.Inventory or not next(Shared.ArtifactSession.Inventory) then Remotes.ArtifactUnequip:FireServer(""); task.wait(2); continue end
        local lockQueue, deleteQueue, upgradeQueue = {}, {}, {}
        for uuid, data in pairs(Shared.ArtifactSession.Inventory) do
            local res = EvaluateArtifact2(uuid, data)
            if res.lock then table.insert(lockQueue, uuid) end
            if res.delete then table.insert(deleteQueue, uuid) end
            if res.upgrade then local targetLvl = Options.UpgradeLimit or 15; if Toggles.UpgradeStage then targetLvl = math.min(math.floor(data.Level/3)*3+3, Options.UpgradeLimit or 15) end; table.insert(upgradeQueue, {["UUID"] = uuid, ["Levels"] = targetLvl}) end
        end
        for _, uuid in ipairs(lockQueue) do Remotes.ArtifactLock:FireServer(uuid, true); task.wait(0.1) end
        if #deleteQueue > 0 then for i=1,#deleteQueue,50 do local chunk={}; for j=i,math.min(i+49,#deleteQueue) do table.insert(chunk, deleteQueue[j]) end; Remotes.MassDelete:FireServer(chunk); task.wait(0.6) end; Remotes.ArtifactUnequip:FireServer("") end
        if #upgradeQueue > 0 then for i=1,#upgradeQueue,50 do local chunk={}; for j=i,math.min(i+49,#upgradeQueue) do table.insert(chunk, upgradeQueue[j]) end; Remotes.MassUpgrade:FireServer(chunk); task.wait(0.6) end end
        if Toggles.ArtifactEquip then AutoEquipArtifacts() end
    end
end

-- UI CONSTRUCTION
local infoSection = Library:AddSection({Name = "Information", Icon = "info"})
local infoTab = infoSection:AddTab({Name = "Overview", Icon = "home"})
local userGroup = infoTab:AddGroup({Name = "User", Side = "Left", Icon = "user"})
local gameGroup = infoTab:AddGroup({Name = "Game", Side = "Left", Icon = "gamepad"})
local othersGroup = infoTab:AddGroup({Name = "Others", Side = "Right", Icon = "box"})
local tierLabel = userGroup:AddLabel({Text = "<b>Type:</b> Premium User"})
local timeLabel = userGroup:AddLabel({Text = "<b>Time Left:</b> Lifetime"})
userGroup:AddLabel({Text = "<b>Executor:</b> "..(identifyexecutor and identifyexecutor() or "Unknown")})
gameGroup:AddButton({Name = "Redeem All Codes", Callback = function()
    for codeName, data in pairs(Modules.Codes.Codes) do if Plr.Data.Level.Value >= (data.LevelReq or 0) then Remotes.UseCode:InvokeServer(codeName); task.wait(2) end end
end})
othersGroup:AddLabel({Text = "<b>Community Support</b>"})
othersGroup:AddLabel({Text = "<b>Update</b>: Every time there is a game update or someone reports something, I will fix it as soon as possible."})
othersGroup:AddButton({Name = "Discord", Callback = function() setclipboard("https://discord.gg/vorahub") end, Disabled = not Support.Clipboard})
othersGroup:AddButton({Name = "Join Discord Server", Callback = function() local invite="vorahub"; pcall(function() request({Url="http://127.0.0.1:6463/rpc?v=1",Method="POST",Headers={["Content-Type"]="application/json",["Origin"]="https://discord.com"},Body=HttpService:JSONEncode({cmd="INVITE_BROWSER",args={code=invite},nonce=HttpService:GenerateGUID(false)})}) end) end})

local prioSection = Library:AddSection({Name = "Priority", Icon = "arrow-up-down"})
local prioTab = prioSection:AddTab({Name = "Config", Icon = "wrench"})
local prioGroup = prioTab:AddGroup({Name = "Priority Order", Side = "Left"})
for i = 1, #PriorityTasks do
    prioGroup:AddDropdown({Name = "Priority "..i, Options = PriorityTasks, Default = PriorityTasks[i], Callback = function(v) Options["SelectedPriority_"..i] = v end})
    Options["SelectedPriority_"..i] = PriorityTasks[i]
end

local mainSection = Library:AddSection({Name = "Main", Icon = "box"})
local mobsTab = mainSection:AddTab({Name = "Mobs", Icon = "users"})
local mobsGroup = mobsTab:AddGroup({Name = "Mob Farming", Side = "Left"})
local selectedMob_dd = mobsGroup:AddMultiDropdown({Name = "Select Mob (s)", Options = Tables.MobList, Default = {}, Callback = function(v) Options.SelectedMob = v end})
Options.SelectedMob_dd = selectedMob_dd
mobsGroup:AddButton({Name = "Refresh", Callback = UpdateNPCLists})
local mobFarmToggle = mobsGroup:AddToggle({Name = "Autofarm Selected Mob", Default = false, Callback = function(v) Toggles.MobFarm = v end})
Toggles.MobFarm = false
local allMobToggle = mobsGroup:AddToggle({Name = "Autofarm All Mobs", Default = false, Callback = function(v) Toggles.AllMobFarm = v end})
Toggles.AllMobFarm = false
mobsGroup:AddDropdown({Name = "Select Type [All Mob]", Options = {"Normal","Fast"}, Default = "Normal", Callback = function(v) Options.AllMobType = v end})
local levelFarmToggle = mobsGroup:AddToggle({Name = "Autofarm Level", Default = false, Callback = function(v) Toggles.LevelFarm = v; if not v then Shared.QuestNPC = "" end end})
Toggles.LevelFarm = false

local bossesTab = mainSection:AddTab({Name = "Bosses", Icon = "crown"})
local bossGroup = bossesTab:AddGroup({Name = "World Bosses", Side = "Left"})
bossGroup:AddMultiDropdown({Name = "Select Bosses", Options = Tables.BossList, Default = {}, Callback = function(v) Options.SelectedBosses = v end})
local bossFarmToggle = bossGroup:AddToggle({Name = "Autofarm Selected Boss", Default = false, Callback = function(v) Toggles.BossesFarm = v end})
Toggles.BossesFarm = false
local allBossToggle = bossGroup:AddToggle({Name = "Autofarm All Bosses", Default = false, Callback = function(v) Toggles.AllBossesFarm = v end})
Toggles.AllBossesFarm = false
bossGroup:AddDivider()
bossGroup:AddDropdown({Name = "Select Summon Boss", Options = Tables.SummonList, Default = nil, Callback = function(v) Options.SelectedSummon = v end})
bossGroup:AddDropdown({Name = "Select Difficulty", Options = Tables.DiffList, Default = "Normal", Callback = function(v) Options.SelectedSummonDiff = v end})
local autoSummonToggle = bossGroup:AddToggle({Name = "Auto Summon", Default = false, Callback = function(v) Toggles.AutoSummon = v end})
Toggles.AutoSummon = false
local summonFarmToggle = bossGroup:AddToggle({Name = "Autofarm Summon Boss", Default = false, Callback = function(v) Toggles.SummonBossFarm = v end})
Toggles.SummonBossFarm = false
bossGroup:AddDivider()
local pityLabel = bossGroup:AddLabel({Text = "<b>Pity:</b> 0/25"})
bossGroup:AddMultiDropdown({Name = "Select Boss [Build Pity]", Options = Tables.AllBossList, Default = {}, Callback = function(v) Options.SelectedBuildPity = v end})
bossGroup:AddDropdown({Name = "Select Boss [Use Pity]", Options = Tables.AllBossList, Default = nil, Callback = function(v) Options.SelectedUsePity = v end})
bossGroup:AddDropdown({Name = "Select Difficulty [Use Pity]", Options = Tables.DiffList, Default = "Normal", Callback = function(v) Options.SelectedPityDiff = v end})
local pityFarmToggle = bossGroup:AddToggle({Name = "Autofarm Pity Boss", Default = false, Callback = function(v) Toggles.PityBossFarm = v end})
Toggles.PityBossFarm = false
bossGroup:AddDivider()
bossGroup:AddDropdown({Name = "Select Summon Boss (Other)", Options = Tables.OtherSummonList, Default = nil, Callback = function(v) Options.SelectedOtherSummon = v end})
bossGroup:AddDropdown({Name = "Select Difficulty", Options = Tables.DiffList, Default = "Normal", Callback = function(v) Options.SelectedOtherSummonDiff = v end})
local otherSummonToggle = bossGroup:AddToggle({Name = "Auto Summon (Other)", Default = false, Callback = function(v) Toggles.AutoOtherSummon = v end})
Toggles.AutoOtherSummon = false
local otherFarmToggle = bossGroup:AddToggle({Name = "Autofarm Summon Boss (Other)", Default = false, Callback = function(v) Toggles.OtherSummonFarm = v end})
Toggles.OtherSummonFarm = false

local miscMainTab = mainSection:AddTab({Name = "Misc", Icon = "users"})
local altGroup = miscMainTab:AddGroup({Name = "Alt Help", Side = "Left"})
altGroup:AddDropdown({Name = "Select Boss", Options = Tables.AllBossList, Default = nil, Callback = function(v) Options.SelectedAltBoss = v end})
altGroup:AddDropdown({Name = "Select Difficulty", Options = Tables.DiffList, Default = "Normal", Callback = function(v) Options.SelectedAltDiff = v end})
for i = 1, 5 do altGroup:AddPlayerDropdown({Name = "Select Alt #"..i, Default = nil, Callback = function(v) Options["SelectedAlt_"..i] = v end}) end
local altHelpToggle = altGroup:AddToggle({Name = "Auto Help Alt", Default = false, Callback = function(v) Toggles.AltBossFarm = v end})
Toggles.AltBossFarm = false

local configMainTab = mainSection:AddTab({Name = "Config", Icon = "settings"})
local weaponGroup = configMainTab:AddGroup({Name = "Weapon", Side = "Left"})
local moveGroup = configMainTab:AddGroup({Name = "Movement", Side = "Right"})
weaponGroup:AddMultiDropdown({Name = "Select Weapon Type", Options = Tables.Weapon, Default = {"Melee","Sword","Power"}, Callback = function(v) Options.SelectedWeaponType = v end})
weaponGroup:AddSlider({Name = "Switch Weapon Delay", Min = 1, Max = 20, Default = 4, Increment = 1, Callback = function(v) Options.SwitchWeaponCD = v end})
local islandTPToggle = moveGroup:AddToggle({Name = "Island TP [Autofarm]", Default = true, Callback = function(v) Toggles.IslandTP = v end})
Toggles.IslandTP = true
local instantBypassToggle = moveGroup:AddToggle({Name = "Instant TP bypass", Default = false, Callback = function(v) Toggles.InstantTPBypass = v; ACThing(v) end})
Toggles.InstantTPBypass = false
moveGroup:AddSlider({Name = "Island TP CD", Min = 0, Max = 2.5, Default = 0.67, Increment = 0.01, Callback = function(v) Options.IslandTPCD = v end})
moveGroup:AddSlider({Name = "Target TP CD", Min = 0, Max = 5, Default = 0, Increment = 0.01, Callback = function(v) Options.TargetTPCD = v end})
moveGroup:AddSlider({Name = "Target Distance TP [Tween]", Min = 0, Max = 100, Default = 0, Increment = 1, Callback = function(v) Options.TargetDistTP = v end})
moveGroup:AddSlider({Name = "M1 Attack Cooldown", Min = 0, Max = 1, Default = 0.2, Increment = 0.01, Callback = function(v) Options.M1Speed = v end})
moveGroup:AddDropdown({Name = "Select Movement Type", Options = {"Teleport","Tween"}, Default = "Tween", Callback = function(v) Options.SelectedMovementType = v end})
moveGroup:AddDropdown({Name = "Select Farm Type", Options = {"Behind","Above","Below"}, Default = "Behind", Callback = function(v) Options.SelectedFarmType = v end})
moveGroup:AddSlider({Name = "Farm Distance", Min = 0, Max = 30, Default = 12, Increment = 1, Callback = function(v) Options.Distance = v end})
moveGroup:AddSlider({Name = "Tween Speed", Min = 0, Max = 500, Default = 160, Increment = 1, Callback = function(v) Options.TweenSpeed = v end})
local instaKillToggle = moveGroup:AddToggle({Name = "Instant Kill", Default = false, Callback = function(v) Toggles.InstaKill = v end})
Toggles.InstaKill = false
moveGroup:AddDropdown({Name = "Select Type", Options = {"V1","V2"}, Default = "V1", Callback = function(v) Options.InstaKillType = v end})
moveGroup:AddSlider({Name = "HP% For Insta-Kill", Min = 1, Max = 100, Default = 90, Increment = 1, Callback = function(v) Options.InstaKillHP = v end})
moveGroup:AddTextInput({Name = "Min MaxHP for Insta-Kill", Default = "100000", PlaceholderText = "Number..", Callback = function(v) Options.InstaKillMinHP = tonumber(v) or 0 end})

local autoSection = Library:AddSection({Name = "Automation", Icon = "repeat-2"})
local hakiTab = autoSection:AddTab({Name = "Haki", Icon = "zap"})
local hakiGroup = hakiTab:AddGroup({Name = "Auto Haki", Side = "Left"})
hakiGroup:AddToggle({Name = "Auto Observation Haki", Default = false, Callback = function(v) Toggles.ObserHaki = v end})
hakiGroup:AddToggle({Name = "Auto Armament Haki", Default = false, Callback = function(v) Toggles.ArmHaki = v end})
hakiGroup:AddToggle({Name = "Auto Conqueror Haki", Default = false, Callback = function(v) Toggles.ConquerorHaki = v end})
local skillTab = autoSection:AddTab({Name = "Skill", Icon = "zap"})
local skillGroup = skillTab:AddGroup({Name = "Auto Skills", Side = "Left"})
skillGroup:AddLabel({Text = "Autofarm already has auto-M1 built in."})
skillGroup:AddToggle({Name = "Auto Attack (M1)", Default = false, Callback = function(v) Toggles.AutoM1 = v end})
skillGroup:AddToggle({Name = "Kill Aura", Default = false, Callback = function(v) Toggles.KillAura = v end})
skillGroup:AddSlider({Name = "Kill Aura CD", Min = 0.1, Max = 1, Default = 0.1, Increment = 0.01, Callback = function(v) Options.KillAuraCD = v end})
skillGroup:AddSlider({Name = "Kill Aura Range", Min = 0, Max = 200, Default = 200, Increment = 1, Callback = function(v) Options.KillAuraRange = v end})
skillGroup:AddLabel({Text = "Mode:\n- Normal: Check cooldowns\n- Instant: No check"})
skillGroup:AddMultiDropdown({Name = "Select Skills", Options = {"Z","X","C","V","F"}, Default = {}, Callback = function(v) Options.SelectedSkills = v end})
skillGroup:AddDropdown({Name = "Select Mode", Options = {"Normal","Instant"}, Default = "Normal", Callback = function(v) Options.AutoSkillType = v end})
skillGroup:AddToggle({Name = "Target Only", Default = false, Callback = function(v) Toggles.OnlyTarget = v end})
skillGroup:AddToggle({Name = "Use On Boss Only", Default = false, Callback = function(v) Toggles.AutoSkill_BossOnly = v end})
skillGroup:AddSlider({Name = "Boss HP%", Min = 1, Max = 100, Default = 100, Increment = 1, Callback = function(v) Options.AutoSkill_BossHP = v end})
local autoSkillToggle = skillGroup:AddToggle({Name = "Auto Use Skills", Default = false, Callback = function(v) Toggles.AutoSkill = v end})
local comboTab = autoSection:AddTab({Name = "Combo", Icon = "code"})
local comboGroup = comboTab:AddGroup({Name = "Skill Combo", Side = "Left"})
comboGroup:AddLabel({Text = "Example: Z > X > C > 0.5 > V"})
comboGroup:AddTextInput({Name = "Combo Pattern", Default = "Z > X > C > V > F", PlaceholderText = "combo..", Callback = function(v) Options.ComboPattern = v end})
comboGroup:AddDropdown({Name = "Select Mode", Options = {"Normal","Instant"}, Default = "Normal", Callback = function(v) Options.ComboMode = v end})
comboGroup:AddToggle({Name = "Boss Only", Default = false, Callback = function(v) Toggles.ComboBossOnly = v end})
local comboEnableToggle = comboGroup:AddToggle({Name = "Auto Skill Combo", Default = false, Callback = function(v) Toggles.AutoCombo = v; if v and Toggles.AutoSkill then Toggles.AutoSkill = false; autoSkillToggle:SetValue(false) end end})
local rollsTab = autoSection:AddTab({Name = "Rolls", Icon = "dice"})
local rollsGroup = rollsTab:AddGroup({Name = "Auto Rolls", Side = "Left"})
rollsGroup:AddSlider({Name = "Roll Delay", Min = 0.01, Max = 1, Default = 0.3, Increment = 0.01, Callback = function(v) Options.RollCD = v end})
rollsGroup:AddMultiDropdown({Name = "Select Trait (s)", Options = Tables.TraitList, Default = {}, Callback = function(v) Options.SelectedTrait = v end})
rollsGroup:AddToggle({Name = "Auto Roll Trait", Default = false, Callback = function(v) Toggles.AutoTrait = v end})
rollsGroup:AddMultiDropdown({Name = "Select Race (s)", Options = Tables.RaceList, Default = {}, Callback = function(v) Options.SelectedRace = v end})
rollsGroup:AddToggle({Name = "Auto Roll Race", Default = false, Callback = function(v) Toggles.AutoRace = v end})
rollsGroup:AddMultiDropdown({Name = "Select Clan (s)", Options = Tables.ClanList, Default = {}, Callback = function(v) Options.SelectedClan = v end})
rollsGroup:AddToggle({Name = "Auto Roll Clan", Default = false, Callback = function(v) Toggles.AutoClan = v end})

local playerSection = Library:AddSection({Name = "Player", Icon = "user"})
local playerTab = playerSection:AddTab({Name = "General", Icon = "user-cog"})
local playerGroup = playerTab:AddGroup({Name = "Character", Side = "Left"})
local serverGroup = playerTab:AddGroup({Name = "Server", Side = "Right"})
AddSliderToggle(playerGroup, "WS", "WalkSpeed", false, 16, 16, 250, 0)
AddSliderToggle(playerGroup, "TPW", "TPWalk", false, 1, 1, 10, 1)
AddSliderToggle(playerGroup, "JP", "JumpPower", false, 50, 0, 500, 0)
AddSliderToggle(playerGroup, "HH", "HipHeight", false, 2, 0, 10, 1)
playerGroup:AddToggle({Name = "Noclip", Default = false, Callback = function(v) Toggles.Noclip = v end})
playerGroup:AddToggle({Name = "Freeze Character", Default = false, Callback = function(v) Toggles.FreezeCharacter = v end})
playerGroup:AddToggle({Name = "Anti Knockback", Default = false, Callback = function(v) Toggles.AntiKnockback = v end})
playerGroup:AddToggle({Name = "Auto Dash", Default = false, Callback = function(v) Toggles.AutoDash = v end})
playerGroup:AddToggle({Name = "Auto Dash FX", Default = true, Callback = function(v) Toggles.AutoDashFX = v end})
playerGroup:AddSlider({Name = "Dash cooldown", Min = 0.15, Max = 1.25, Default = 0.4, Increment = 0.01, Callback = function(v) Options.AutoDashCD = v end})
playerGroup:AddSlider({Name = "Dash max distance", Min = 15, Max = 100, Default = 33, Increment = 1, Callback = function(v) Options.AutoDashDistance = v end})
playerGroup:AddToggle({Name = "Disable 3D Rendering", Default = false, Callback = function(v) Toggles.Disable3DRender = v end})
AddSliderToggle(playerGroup, "Grav", "Gravity", false, 196, 0, 500, 1)
AddSliderToggle(playerGroup, "Zoom", "Camera Zoom", false, 128, 128, 10000, 0)
AddSliderToggle(playerGroup, "FOV", "Field of View", false, 70, 30, 120, 0)
serverGroup:AddToggle({Name = "Anti AFK", Default = true, Callback = function(v) Toggles.AntiAFK = v end})
serverGroup:AddToggle({Name = "Anti Kick (Client)", Default = false, Callback = function(v) Toggles.AntiKick = v end})
serverGroup:AddToggle({Name = "Auto Reconnect", Default = false, Callback = function(v) Toggles.AutoReconnect = v end})
serverGroup:AddToggle({Name = "No Gameplay Paused", Default = false, Callback = function(v) Toggles.NoGameplayPaused = v end})
serverGroup:AddButton({Name = "Rejoin", Callback = function() TeleportService:Teleport(game.PlaceId, Plr) end})

local tpSection = Library:AddSection({Name = "Teleport", Icon = "map-pin"})
local tpTab = tpSection:AddTab({Name = "Islands", Icon = "map"})
local islandTpGroup = tpTab:AddGroup({Name = "Island Teleport", Side = "Left"})
islandTpGroup:AddDropdown({Name = "Select Island", Options = Tables.IslandList, Default = nil, Callback = function(v) if v then Remotes.TP_Portal:FireServer(v) end end})

local configSection = Library:AddSection({Name = "Config", Icon = "save"})
local configTab = configSection:AddTab({Name = "Settings", Icon = "hard-drive"})
local configGroup = configTab:AddGroup({Name = "Config Management", Side = "Left"})
configGroup:AddButton({Name = "Save Config", Callback = function() pcall(function() Library:SaveConfig("vorahub_config") end); Library:Notify({Title = "Config", Description = "Saved!", Duration = 3}) end})
configGroup:AddButton({Name = "Load Config", Callback = function() pcall(function() Library:LoadConfig("vorahub_config") end); Library:Notify({Title = "Config", Description = "Loaded!", Duration = 3}) end})

Library:Notify({Title = "VoraHub", Description = "Script loaded. Press RightCtrl to toggle UI.", Duration = 5})

Toggles.SendWebhook:OnChanged(function(s) Thread("WebhookLoop", Func_WebhookLoop, s) end)
Toggles.ObserHaki:OnChanged(function(s) Thread("AutoHaki", Func_AutoHaki, s) end)
Toggles.ArmHaki:OnChanged(function(s) Thread("AutoHaki", Func_AutoHaki, s) end)
Toggles.ConquerorHaki:OnChanged(function(s) Thread("AutoHaki", Func_AutoHaki, s) end)
Toggles.AutoM1:OnChanged(function(s) Thread("AutoM1", SafeLoop("Auto M1", Func_AutoM1), s) end)
Toggles.KillAura:OnChanged(function(s) Thread("KillAura", Func_KillAura, s) end)
Toggles.AutoSkill:OnChanged(function(s) Thread("AutoSkill", SafeLoop("Auto Skill", Func_AutoSkill), s) end)
Toggles.AutoStats:OnChanged(function(s) Thread("AutoStats", SafeLoop("Auto Stats", Func_AutoStats), s) end)
Toggles.AutoCombo:OnChanged(function(s) Thread("AutoCombo", SafeLoop("Skill Combo", Func_AutoCombo), s) end)
Toggles.AutoTrait:OnChanged(EnsureRollManager)
Toggles.AutoRace:OnChanged(EnsureRollManager)
Toggles.AutoClan:OnChanged(EnsureRollManager)
Toggles.AutoSpec:OnChanged(function(s) Thread("AutoSpecPassive", SafeLoop("Spec Passive", AutoSpecPassiveLoop), s) end)
Toggles.AutoRollStats:OnChanged(function(s) Thread("AutoRollStats", SafeLoop("Stat Roll", AutoRollStatsLoop), s) end)
Toggles.AutoSkillTree:OnChanged(function(s) Thread("AutoSkillTree", SafeLoop("Skill Tree", AutoSkillTreeLoop), s) end)
Toggles.ArtifactMilestone:OnChanged(function(s) Thread("ArtifactMilestone", Func_ArtifactMilestone, s) end)
Toggles.AutoEnchant:OnChanged(function(s) Thread("AutoEnchant", SafeLoop("Enchant", function() AutoUpgradeLoop("Enchant") end), s) end)
Toggles.AutoEnchantAll:OnChanged(function(s) Thread("AutoEnchantAll", SafeLoop("EnchantAll", function() AutoUpgradeLoop("Enchant") end), s) end)
Toggles.AutoBlessing:OnChanged(function(s) Thread("AutoBlessing", SafeLoop("Blessing", function() AutoUpgradeLoop("Blessing") end), s) end)
Toggles.AutoBlessingAll:OnChanged(function(s) Thread("AutoBlessingAll", SafeLoop("BlessingAll", function() AutoUpgradeLoop("Blessing") end), s) end)
Toggles.ArtifactLock:OnChanged(function(s) Thread("Artifact.Lock", SafeLoop("ArtifactLogic", Func_ArtifactAutomation), s) end)
Toggles.ArtifactDelete:OnChanged(function(s) Thread("Artifact.Delete", SafeLoop("ArtifactLogic", Func_ArtifactAutomation), s) end)
Toggles.ArtifactUpgrade:OnChanged(function(s) Thread("Artifact.Upgrade", SafeLoop("ArtifactLogic", Func_ArtifactAutomation), s) end)
Toggles.AutoDungeon:OnChanged(function(s) Thread("AutoDungeon", Func_AutoDungeon, s) end)
Toggles.DungeonAutofarm:OnChanged(function(s) Thread("DungeonAutofarm", Func_DungeonAutofarm, s) end)
Toggles.AutoMerchant:OnChanged(function(s) Thread("AutoMerchant", SafeLoop("Merchant", Func_AutoMerchant), s) end)
Toggles.AutoChest:OnChanged(function(s) Thread("AutoChest", SafeLoop("Chest", Func_AutoChest), s) end)
Toggles.AutoCraftItem:OnChanged(function(s) Thread("AutoCraft", SafeLoop("Craft", Func_AutoCraft), s) end)
Toggles.AutoQuestline:OnChanged(function(s) Thread("AutoQuestline", SafeLoop("Questline", AutoQuestlineLoop), s) end)
Toggles.AntiKnockback:OnChanged(function(s) Thread("AntiKnockback", Func_AntiKnockback, s) end)
Toggles.TPW:OnChanged(function(v) Thread("TPW", FuncTPW, v) end)
Toggles.Noclip:OnChanged(function(v) Thread("Noclip", FuncNoclip, v) end)
Toggles.AutoReconnect:OnChanged(function(v) if v then Func_AutoReconnect() end end)
Toggles.NoGameplayPaused:OnChanged(function(v) Thread("NoGameplayPaused", SafeLoop("Anti-Pause", Func_NoGameplayPaused), v) end)
Toggles.Disable3DRender:OnChanged(function(v) RunService:Set3dRenderingEnabled(not v) end)
Toggles.FPSBoost:OnChanged(ApplyFPSBoost)
Toggles.FPSBoost_AF:OnChanged(ApplyIslandWipe)
Connections.Player_General = RunService.Stepped:Connect(function()
    local char = Plr.Character; local root = char and char:FindFirstChild("HumanoidRootPart"); local Hum = Plr.Character and Plr.Character:FindFirstChildOfClass("Humanoid")
    if Hum then
        if Toggles.WS then Hum.WalkSpeed = Options.WSValue or 16 end
        if Toggles.JP then Hum.JumpPower = Options.JPValue or 50; Hum.UseJumpPower = true end
        if Toggles.HH then Hum.HipHeight = Options.HHValue or 2 end
        if Toggles.AutoDash and _DR and Hum.Health > 0 and not Hum.Sit and char and root and not Toggles.FreezeCharacter then
            local moving = Hum.MoveDirection.Magnitude > 0.08
            local wasd = UIS:IsKeyDown(Enum.KeyCode.W) or UIS:IsKeyDown(Enum.KeyCode.S) or UIS:IsKeyDown(Enum.KeyCode.A) or UIS:IsKeyDown(Enum.KeyCode.D)
            if moving or wasd then
                local dir = Dash_GetDirection(char, Hum, root)
                if dir then
                    local mod = getGameDashModule(); local cfg = mod and mod.Config; local cap = (cfg and cfg.DashDistance) or 33
                    local raw = tonumber(Options.AutoDashDistance or cap); local maxDist = math.clamp(math.max(raw,15),15,120); maxDist = math.min(maxDist, cap)
                    local okPath, dist = Dash_CheckPath(char, dir, maxDist)
                    if okPath and dist > 0 then
                        local interval = tonumber(Options.AutoDashCD) or (cfg and cfg.DashCooldown) or 0.4
                        if tick() - Shared.AutoDashLast >= interval then
                            Shared.AutoDashLast = tick()
                            local backward = Dash_IsBackward(char, dir)
                            pcall(function()
                                if Toggles.AutoDashFX then DashClient_PlayDashEffects(Hum, root, backward) end
                                DashClient_ApplyDashMovement(root, Hum, dir, dist)
                                _DR:FireServer(dir, dist, backward)
                            end)
                        end
                    end
                end
            end
        end
    end
    if root then
        if Toggles.FreezeCharacter then root.AssemblyLinearVelocity = Vector3.zero; root.AssemblyAngularVelocity = Vector3.zero; root.Anchored = true; Shared.FreezeApplied = true
        elseif Shared.FreezeApplied then root.Anchored = false; Shared.FreezeApplied = false end
    end
    workspace.Gravity = Toggles.Grav and Options.GravValue or 192
    if Toggles.FOV then workspace.CurrentCamera.FieldOfView = Options.FOVValue or 70 end
    if Toggles.Zoom then Plr.CameraMaxZoomDistance = Options.ZoomValue or 128 end
end)
task.spawn(function() while task.wait() do if Toggles.Fullbright then Lighting.Brightness = 2; Lighting.ClockTime = 14; Lighting.GlobalShadows = false elseif Toggles.OverrideTime then Lighting.ClockTime = Options.OverrideTimeValue or 12 end; if Toggles.NoFog then Lighting.FogEnd = 9e9 end; if Library.Unloaded then break end end end)
task.spawn(function() DisableIdled(); while true do task.wait(60); if Toggles.AntiAFK then pcall(function() VirtualUser:CaptureController(); VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame); task.wait(0.2); VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame) end) end end end)
task.spawn(function() while true do task.wait(); if Shared.AltActive then continue end; if not Shared.Farm or Shared.MerchantBusy or not Shared.Target then continue end; pcall(function() local char = GetCharacter(); local target = Shared.Target; if not target or not char then return end; local npcHum = target:FindFirstChildOfClass("Humanoid"); local npcRoot = target:FindFirstChild("HumanoidRootPart"); local root = char:FindFirstChild("HumanoidRootPart"); if npcHum and npcRoot and root then local currentDist = (root.Position - npcRoot.Position).Magnitude; local hpPercent = (npcHum.Health / npcHum.MaxHealth) * 100; local minMaxHP = tonumber(Options.InstaKillMinHP or 0); local ikThreshold = tonumber(Options.InstaKillHP or 90); if Toggles.InstaKill and npcHum.MaxHealth >= minMaxHP and hpPercent < ikThreshold then npcHum.Health = 0; if not target:FindFirstChild("IK_Active") then local tag = Instance.new("Folder"); tag.Name = "IK_Active"; tag:SetAttribute("TriggerTime", tick()); tag.Parent = target end end; if currentDist < 35 then if math.abs(root.Position.Y - npcRoot.Position.Y) > 50 then root.Velocity = Vector3.new(0,-100,0) end; local m1Delay = tonumber(Options.M1Speed or 0.2); if tick() - Shared.LastM1 >= m1Delay then if not Toggles.KillAura then EquipWeapon(); Remotes.M1:FireServer(); Shared.LastM1 = tick() end end end end end) end end)
task.spawn(function() while task.wait() do if not Shared.Farm or Shared.MerchantBusy then Shared.Target = nil; continue end; local char = GetCharacter(); if not char or Shared.Recovering then continue end; if Shared.TargetValid and (not Shared.Target or not Shared.Target.Parent or Shared.Target.Humanoid.Health <= 0) then Shared.KillTick = tick(); Shared.TargetValid = false end; if tick() - Shared.KillTick < (tonumber(Options.TargetTPCD or 0)) then continue end; HandleSummons(); local currentPity, maxPity = GetCurrentPity(); local isPityReady = Toggles.PityBossFarm and currentPity >= (maxPity - 1); local foundTask = false; if isPityReady then local t, isl, fType = GetPityTarget(); if t then foundTask = true; Shared.Target = t; Shared.TargetValid = true; UpdateSwitchState(t, fType); ExecuteFarmLogic(t, isl, fType) end end; if not foundTask then for i=1,#PriorityTasks do local taskName = Options["SelectedPriority_"..i]; if not taskName then continue end; if isPityReady and (taskName == "Boss" or taskName == "All Mob Farm" or taskName == "Mob") then continue end; local t, isl, fType = CheckTask(taskName); if t then foundTask = true; Shared.Target = (typeof(t) == "Instance") and t or nil; Shared.TargetValid = true; UpdateSwitchState(t, fType); if taskName ~= "Merchant" then ExecuteFarmLogic(t, isl, fType) end; break end end end; if not foundTask then Shared.Target = nil; UpdateSwitchState(nil, "None") end end end)
task.spawn(function() while task.wait(1) do if not getgenv().vorahub_Running then break end; local char = GetCharacter(); local root = char and char:FindFirstChild("HumanoidRootPart"); if root and not Shared.MovingIsland then local pos = root.Position; if pos.Y > 5000 or math.abs(pos.X) > 10000 or math.abs(pos.Z) > 10000 then Shared.Recovering = true; Library:Notify({Title = "Error", Description = "Something wrong, attempt to reset..", Duration = 5}); root.AssemblyLinearVelocity = Vector3.zero; root.AssemblyAngularVelocity = Vector3.zero; if IslandCrystals["Starter"] then root.CFrame = IslandCrystals["Starter"]:GetPivot() * CFrame.new(0,5,0); task.wait(1) end; Shared.Recovering = false end end end end)
UpdateNPCLists()
InitAutoKick()
Library:Notify({Title = "VoraHub", Description = "Report bug and give suggestion in Discord!", Duration = 5})
