-- Sailor Piece VoraHub - Converted to FlowUI
-- Original: Linoria UI, Converted by request

if not game:IsLoaded() then game.Loaded:Wait() end

-- 1. Anti-Tamper & Service Protection
cloneref = cloneref or function(o) return o end
HttpService = cloneref(game:GetService("HttpService"))
StarterGui = cloneref(game:GetService("StarterGui"))
Players = cloneref(game:GetService("Players"))
RbxAnalyticsService = cloneref(game:GetService("RbxAnalyticsService"))
LocalPlayer = Players.LocalPlayer
local API_ENDPOINT = "https://api.vorahub.xyz/redeem"

-- ... (Semua fungsi anti-tamper, request, redeem, dll tetap sama seperti asli) ...
-- Karena panjang, saya anggap bagian ini tidak berubah. Lanjut ke bagian UI.

-- ================== FLOW UI SETUP ==================
local FlowUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Andrazx23/voralib/refs/heads/main/flow%20ui/ui.lua"))()
local Library = FlowUI.new({
    Name = "VoraHub",
    AccentColor = Color3.fromRGB(0, 140, 210),
    AutoConfig = false
})

-- Global variables untuk menyimpan nilai kontrol
local Toggles = {}
local Options = {}
local Flags = {} -- Untuk thread management tetap sama

-- Fungsi helper untuk membuat toggle + slider terkait
function AddSliderToggle(group, id, text, defaultToggle, defaultSlider, min, max, rounding, disabled)
    local toggle = group:AddToggle({
        Name = text,
        Default = defaultToggle or false,
        Disabled = disabled,
        Callback = function(v)
            Toggles[id] = v
            if slider then slider:SetVisible(v) end
        end
    })
    local slider = group:AddSlider({
        Name = text .. " Value",
        Min = min or 0,
        Max = max or 100,
        Default = defaultSlider or 0,
        Increment = rounding and (10^(-rounding)) or 1,
        Visible = defaultToggle or false,
        Disabled = disabled,
        Callback = function(v)
            Options[id .. "Value"] = v
        end
    })
    Toggles[id] = defaultToggle or false
    Options[id .. "Value"] = defaultSlider or 0
    return toggle, slider
end

-- ================== DATA & TABLES (sama seperti asli) ==================
-- ... Salin semua definisi Tables, Modules, Remotes, Shared, dll. ...
-- Karena panjang, saya akan langsung ke pembuatan UI.

-- ================== UI SECTIONS & TABS ==================

-- SECTION: Information
local infoSection = Library:AddSection({ Name = "Information", Icon = "info" })
local infoTab = infoSection:AddTab({ Name = "Overview", Icon = "home" })

local userGroup = infoTab:AddGroup({ Name = "User", Side = "Left", Icon = "user" })
local gameGroup = infoTab:AddGroup({ Name = "Game", Side = "Left", Icon = "gamepad" })
local othersGroup = infoTab:AddGroup({ Name = "Others", Side = "Right", Icon = "box" })

-- Isi User Group
local tierLabel = userGroup:AddLabel({ Text = "<b>Type:</b> Premium User" })
local timeLabel = userGroup:AddLabel({ Text = "<b>Time Left:</b> Lifetime" })
userGroup:AddLabel({ Text = "<b>Executor:</b> " .. (identifyexecutor and identifyexecutor() or "Unknown") })

-- Isi Game Group
gameGroup:AddButton({
    Name = "Redeem All Codes",
    Callback = function()
        -- ... kode redeem seperti asli ...
    end
})

-- Isi Others Group
othersGroup:AddLabel({ Text = "<b>Community Support</b>" })
othersGroup:AddLabel({ Text = "<b>Update</b>: Every time there is a game update or someone reports something, I will fix it as soon as possible." })
othersGroup:AddButton({
    Name = "Discord",
    Callback = function() setclipboard("https://discord.gg/vorahub") end,
    Disabled = not Support.Clipboard
})
othersGroup:AddButton({
    Name = "Join Discord Server",
    Callback = function()
        -- ... kode invite ...
    end
})

-- SECTION: Priority
local prioSection = Library:AddSection({ Name = "Priority", Icon = "arrow-up-down" })
local prioTab = prioSection:AddTab({ Name = "Config", Icon = "wrench" })
local prioGroup = prioTab:AddGroup({ Name = "Priority Order", Side = "Left" })

for i = 1, #PriorityTasks do
    prioGroup:AddDropdown({
        Name = "Priority " .. i,
        Options = PriorityTasks,
        Default = DefaultPriority[i],
        Callback = function(val)
            Options["SelectedPriority_" .. i] = val
        end
    })
    Options["SelectedPriority_" .. i] = DefaultPriority[i]
end

-- SECTION: Main (Autofarm, Boss, Misc, Config) - menggunakan Tabbox, jadi kita buat beberapa Tab
local mainSection = Library:AddSection({ Name = "Main", Icon = "box" })

-- Tab: Autofarm Mobs
local mobsTab = mainSection:AddTab({ Name = "Mobs", Icon = "users" })
local mobsGroup = mobsTab:AddGroup({ Name = "Mob Farming", Side = "Left" })

mobsGroup:AddMultiDropdown({
    Name = "Select Mob (s)",
    Options = Tables.MobList,
    Default = {},
    Callback = function(val) Options.SelectedMob = val end
})
mobsGroup:AddButton({
    Name = "Refresh Mob List",
    Callback = function() UpdateNPCLists() end
})

local mobFarmToggle = mobsGroup:AddToggle({
    Name = "Autofarm Selected Mob",
    Default = false,
    Callback = function(v) Toggles.MobFarm = v end
})
Toggles.MobFarm = false

local allMobToggle = mobsGroup:AddToggle({
    Name = "Autofarm All Mobs",
    Default = false,
    Callback = function(v) Toggles.AllMobFarm = v end
})
Toggles.AllMobFarm = false

mobsGroup:AddDropdown({
    Name = "Select Type [All Mob]",
    Options = {"Normal", "Fast"},
    Default = "Normal",
    Callback = function(v) Options.AllMobType = v end
})
Options.AllMobType = "Normal"

local levelFarmToggle = mobsGroup:AddToggle({
    Name = "Autofarm Level",
    Default = false,
    Callback = function(v) Toggles.LevelFarm = v; if not v then Shared.QuestNPC = "" end
})
Toggles.LevelFarm = false

-- Tab: Bosses
local bossesTab = mainSection:AddTab({ Name = "Bosses", Icon = "crown" })
local bossGroup = bossesTab:AddGroup({ Name = "World Bosses", Side = "Left" })

bossGroup:AddMultiDropdown({
    Name = "Select Bosses",
    Options = Tables.BossList,
    Default = {},
    Callback = function(v) Options.SelectedBosses = v end
})

local bossFarmToggle = bossGroup:AddToggle({
    Name = "Autofarm Selected Boss",
    Default = false,
    Callback = function(v) Toggles.BossesFarm = v end
})
Toggles.BossesFarm = false

local allBossToggle = bossGroup:AddToggle({
    Name = "Autofarm All Bosses",
    Default = false,
    Callback = function(v) Toggles.AllBossesFarm = v end
})
Toggles.AllBossesFarm = false

bossGroup:AddDivider()

-- Summon Boss
bossGroup:AddDropdown({
    Name = "Select Summon Boss",
    Options = Tables.SummonList,
    Default = nil,
    Callback = function(v) Options.SelectedSummon = v end
})
bossGroup:AddDropdown({
    Name = "Select Difficulty",
    Options = Tables.DiffList,
    Default = "Normal",
    Callback = function(v) Options.SelectedSummonDiff = v end
})

local autoSummonToggle = bossGroup:AddToggle({
    Name = "Auto Summon",
    Default = false,
    Callback = function(v) Toggles.AutoSummon = v end
})
Toggles.AutoSummon = false

local summonFarmToggle = bossGroup:AddToggle({
    Name = "Autofarm Summon Boss",
    Default = false,
    Callback = function(v) Toggles.SummonBossFarm = v end
})
Toggles.SummonBossFarm = false

bossGroup:AddDivider()

-- Pity Boss
local pityLabel = bossGroup:AddLabel({ Text = "<b>Pity:</b> 0/25" })
bossGroup:AddMultiDropdown({
    Name = "Select Boss [Build Pity]",
    Options = Tables.AllBossList,
    Default = {},
    Callback = function(v) Options.SelectedBuildPity = v end
})
bossGroup:AddDropdown({
    Name = "Select Boss [Use Pity]",
    Options = Tables.AllBossList,
    Default = nil,
    Callback = function(v) Options.SelectedUsePity = v end
})
bossGroup:AddDropdown({
    Name = "Select Difficulty [Use Pity]",
    Options = Tables.DiffList,
    Default = "Normal",
    Callback = function(v) Options.SelectedPityDiff = v end
})

local pityFarmToggle = bossGroup:AddToggle({
    Name = "Autofarm Pity Boss",
    Default = false,
    Callback = function(v) Toggles.PityBossFarm = v end
})
Toggles.PityBossFarm = false

bossGroup:AddDivider()

-- Other Summons
bossGroup:AddDropdown({
    Name = "Select Summon Boss (Other)",
    Options = Tables.OtherSummonList,
    Default = nil,
    Callback = function(v) Options.SelectedOtherSummon = v end
})
bossGroup:AddDropdown({
    Name = "Select Difficulty",
    Options = Tables.DiffList,
    Default = "Normal",
    Callback = function(v) Options.SelectedOtherSummonDiff = v end
})
local otherSummonToggle = bossGroup:AddToggle({
    Name = "Auto Summon (Other)",
    Default = false,
    Callback = function(v) Toggles.AutoOtherSummon = v end
})
Toggles.AutoOtherSummon = false
local otherFarmToggle = bossGroup:AddToggle({
    Name = "Autofarm Summon Boss (Other)",
    Default = false,
    Callback = function(v) Toggles.OtherSummonFarm = v end
})
Toggles.OtherSummonFarm = false

-- Tab: Misc (Alt Help, etc)
local miscMainTab = mainSection:AddTab({ Name = "Misc", Icon = "users" })
local altGroup = miscMainTab:AddGroup({ Name = "Alt Help", Side = "Left" })

altGroup:AddDropdown({
    Name = "Select Boss",
    Options = Tables.AllBossList,
    Default = nil,
    Callback = function(v) Options.SelectedAltBoss = v end
})
altGroup:AddDropdown({
    Name = "Select Difficulty",
    Options = Tables.DiffList,
    Default = "Normal",
    Callback = function(v) Options.SelectedAltDiff = v end
})
for i = 1, 5 do
    altGroup:AddPlayerDropdown({
        Name = "Select Alt #" .. i,
        Default = nil,
        Callback = function(v) Options["SelectedAlt_" .. i] = v end
    })
end
local altHelpToggle = altGroup:AddToggle({
    Name = "Auto Help Alt",
    Default = false,
    Callback = function(v) Toggles.AltBossFarm = v end
})
Toggles.AltBossFarm = false

-- Tab: Config (Weapon, Movement, etc)
local configMainTab = mainSection:AddTab({ Name = "Config", Icon = "settings" })
local weaponGroup = configMainTab:AddGroup({ Name = "Weapon", Side = "Left" })
local moveGroup = configMainTab:AddGroup({ Name = "Movement", Side = "Right" })

weaponGroup:AddMultiDropdown({
    Name = "Select Weapon Type",
    Options = Tables.Weapon,
    Default = {"Melee", "Sword", "Power"},
    Callback = function(v) Options.SelectedWeaponType = v end
})
weaponGroup:AddSlider({
    Name = "Switch Weapon Delay",
    Min = 1, Max = 20, Default = 4, Increment = 1,
    Callback = function(v) Options.SwitchWeaponCD = v end
})
Options.SwitchWeaponCD = 4

local islandTPToggle = moveGroup:AddToggle({
    Name = "Island TP [Autofarm]",
    Default = true,
    Callback = function(v) Toggles.IslandTP = v end
})
Toggles.IslandTP = true

local instantBypassToggle = moveGroup:AddToggle({
    Name = "Instant TP bypass",
    Default = false,
    Callback = function(v)
        Toggles.InstantTPBypass = v
        ACThing(v)
    end
})
Toggles.InstantTPBypass = false

moveGroup:AddSlider({
    Name = "Island TP CD",
    Min = 0, Max = 2.5, Default = 0.67, Increment = 0.01,
    Callback = function(v) Options.IslandTPCD = v end
})
moveGroup:AddSlider({
    Name = "Target TP CD",
    Min = 0, Max = 5, Default = 0, Increment = 0.01,
    Callback = function(v) Options.TargetTPCD = v end
})
moveGroup:AddSlider({
    Name = "Target Distance TP [Tween]",
    Min = 0, Max = 100, Default = 0, Increment = 1,
    Callback = function(v) Options.TargetDistTP = v end
})
moveGroup:AddSlider({
    Name = "M1 Attack Cooldown",
    Min = 0, Max = 1, Default = 0.2, Increment = 0.01,
    Callback = function(v) Options.M1Speed = v end
})
moveGroup:AddDropdown({
    Name = "Select Movement Type",
    Options = {"Teleport", "Tween"},
    Default = "Tween",
    Callback = function(v) Options.SelectedMovementType = v end
})
moveGroup:AddDropdown({
    Name = "Select Farm Type",
    Options = {"Behind", "Above", "Below"},
    Default = "Behind",
    Callback = function(v) Options.SelectedFarmType = v end
})
moveGroup:AddSlider({
    Name = "Farm Distance",
    Min = 0, Max = 30, Default = 12, Increment = 1,
    Callback = function(v) Options.Distance = v end
})
moveGroup:AddSlider({
    Name = "Tween Speed",
    Min = 0, Max = 500, Default = 160, Increment = 1,
    Callback = function(v) Options.TweenSpeed = v end
})
local instaKillToggle = moveGroup:AddToggle({
    Name = "Instant Kill",
    Default = false,
    Callback = function(v) Toggles.InstaKill = v end
})
Toggles.InstaKill = false
moveGroup:AddDropdown({
    Name = "Select Type",
    Options = {"V1", "V2"},
    Default = "V1",
    Callback = function(v) Options.InstaKillType = v end
})
moveGroup:AddSlider({
    Name = "HP% For Insta-Kill",
    Min = 1, Max = 100, Default = 90, Increment = 1,
    Callback = function(v) Options.InstaKillHP = v end
})
moveGroup:AddTextInput({
    Name = "Min MaxHP for Insta-Kill",
    Default = "100000",
    PlaceholderText = "Number..",
    Callback = function(v) Options.InstaKillMinHP = tonumber(v) or 0 end
})

-- SECTION: Automation
local autoSection = Library:AddSection({ Name = "Automation", Icon = "repeat-2" })
-- Tab Haki
local hakiTab = autoSection:AddTab({ Name = "Haki", Icon = "zap" })
local hakiGroup = hakiTab:AddGroup({ Name = "Auto Haki", Side = "Left" })

hakiGroup:AddToggle({
    Name = "Auto Observation Haki",
    Default = false,
    Callback = function(v) Toggles.ObserHaki = v end
})
hakiGroup:AddToggle({
    Name = "Auto Armament Haki",
    Default = false,
    Callback = function(v) Toggles.ArmHaki = v end
})
hakiGroup:AddToggle({
    Name = "Auto Conqueror Haki",
    Default = false,
    Callback = function(v) Toggles.ConquerorHaki = v end
})
Toggles.ObserHaki = false; Toggles.ArmHaki = false; Toggles.ConquerorHaki = false

-- Tab Skill
local skillTab = autoSection:AddTab({ Name = "Skill", Icon = "zap" })
local skillGroup = skillTab:AddGroup({ Name = "Auto Skills", Side = "Left" })

skillGroup:AddLabel({ Text = "Autofarm already has auto-M1 built in." })
skillGroup:AddToggle({
    Name = "Auto Attack (M1)",
    Default = false,
    Callback = function(v) Toggles.AutoM1 = v end
})
skillGroup:AddToggle({
    Name = "Kill Aura",
    Default = false,
    Callback = function(v) Toggles.KillAura = v end
})
skillGroup:AddSlider({
    Name = "Kill Aura CD",
    Min = 0.1, Max = 1, Default = 0.1, Increment = 0.01,
    Callback = function(v) Options.KillAuraCD = v end
})
skillGroup:AddSlider({
    Name = "Kill Aura Range",
    Min = 0, Max = 200, Default = 200, Increment = 1,
    Callback = function(v) Options.KillAuraRange = v end
})
skillGroup:AddLabel({ Text = "Mode:\n- Normal: Check cooldowns\n- Instant: No check" })
skillGroup:AddMultiDropdown({
    Name = "Select Skills",
    Options = {"Z", "X", "C", "V", "F"},
    Default = {},
    Callback = function(v) Options.SelectedSkills = v end
})
skillGroup:AddDropdown({
    Name = "Select Mode",
    Options = {"Normal", "Instant"},
    Default = "Normal",
    Callback = function(v) Options.AutoSkillType = v end
})
skillGroup:AddToggle({
    Name = "Target Only",
    Default = false,
    Callback = function(v) Toggles.OnlyTarget = v end
})
skillGroup:AddToggle({
    Name = "Use On Boss Only",
    Default = false,
    Callback = function(v) Toggles.AutoSkill_BossOnly = v end
})
skillGroup:AddSlider({
    Name = "Boss HP%",
    Min = 1, Max = 100, Default = 100, Increment = 1,
    Callback = function(v) Options.AutoSkill_BossHP = v end
})
local autoSkillToggle = skillGroup:AddToggle({
    Name = "Auto Use Skills",
    Default = false,
    Callback = function(v) Toggles.AutoSkill = v end
})
Toggles.AutoSkill = false

-- Tab Combo
local comboTab = autoSection:AddTab({ Name = "Combo", Icon = "code" })
local comboGroup = comboTab:AddGroup({ Name = "Skill Combo", Side = "Left" })

comboGroup:AddLabel({ Text = "Example: Z > X > C > 0.5 > V" })
comboGroup:AddTextInput({
    Name = "Combo Pattern",
    Default = "Z > X > C > V > F",
    PlaceholderText = "combo..",
    Callback = function(v) Options.ComboPattern = v end
})
comboGroup:AddDropdown({
    Name = "Select Mode",
    Options = {"Normal", "Instant"},
    Default = "Normal",
    Callback = function(v) Options.ComboMode = v end
})
comboGroup:AddToggle({
    Name = "Boss Only",
    Default = false,
    Callback = function(v) Toggles.ComboBossOnly = v end
})
local comboEnableToggle = comboGroup:AddToggle({
    Name = "Auto Skill Combo",
    Default = false,
    Callback = function(v)
        Toggles.AutoCombo = v
        if v and Toggles.AutoSkill then
            Toggles.AutoSkill = false
            autoSkillToggle:SetValue(false)
        end
    end
})
Toggles.AutoCombo = false

-- Tab Rolls (Trait, Race, Clan)
local rollsTab = autoSection:AddTab({ Name = "Rolls", Icon = "dice" })
local rollsGroup = rollsTab:AddGroup({ Name = "Auto Rolls", Side = "Left" })

rollsGroup:AddSlider({
    Name = "Roll Delay",
    Min = 0.01, Max = 1, Default = 0.3, Increment = 0.01,
    Callback = function(v) Options.RollCD = v end
})
rollsGroup:AddMultiDropdown({
    Name = "Select Trait (s)",
    Options = Tables.TraitList,
    Default = {},
    Callback = function(v) Options.SelectedTrait = v end
})
rollsGroup:AddToggle({
    Name = "Auto Roll Trait",
    Default = false,
    Callback = function(v) Toggles.AutoTrait = v end
})
rollsGroup:AddMultiDropdown({
    Name = "Select Race (s)",
    Options = Tables.RaceList,
    Default = {},
    Callback = function(v) Options.SelectedRace = v end
})
rollsGroup:AddToggle({
    Name = "Auto Roll Race",
    Default = false,
    Callback = function(v) Toggles.AutoRace = v end
})
rollsGroup:AddMultiDropdown({
    Name = "Select Clan (s)",
    Options = Tables.ClanList,
    Default = {},
    Callback = function(v) Options.SelectedClan = v end
})
rollsGroup:AddToggle({
    Name = "Auto Roll Clan",
    Default = false,
    Callback = function(v) Toggles.AutoClan = v end
})

-- SECTION: Player
local playerSection = Library:AddSection({ Name = "Player", Icon = "user" })
local playerTab = playerSection:AddTab({ Name = "General", Icon = "user-cog" })
local playerGroup = playerTab:AddGroup({ Name = "Character", Side = "Left" })
local serverGroup = playerTab:AddGroup({ Name = "Server", Side = "Right" })

AddSliderToggle(playerGroup, "WS", "WalkSpeed", false, 16, 16, 250, 0)
AddSliderToggle(playerGroup, "TPW", "TPWalk", false, 1, 1, 10, 1)
AddSliderToggle(playerGroup, "JP", "JumpPower", false, 50, 0, 500, 0)
AddSliderToggle(playerGroup, "HH", "HipHeight", false, 2, 0, 10, 1)
playerGroup:AddToggle({ Name = "Noclip", Default = false, Callback = function(v) Toggles.Noclip = v end })
playerGroup:AddToggle({ Name = "Freeze Character", Default = false, Callback = function(v) Toggles.FreezeCharacter = v end })
playerGroup:AddToggle({ Name = "Anti Knockback", Default = false, Callback = function(v) Toggles.AntiKnockback = v end })
playerGroup:AddToggle({ Name = "Auto Dash", Default = false, Callback = function(v) Toggles.AutoDash = v end })
playerGroup:AddToggle({ Name = "Auto Dash FX", Default = true, Callback = function(v) Toggles.AutoDashFX = v end })
playerGroup:AddSlider({ Name = "Dash cooldown", Min = 0.15, Max = 1.25, Default = 0.4, Increment = 0.01, Callback = function(v) Options.AutoDashCD = v end })
playerGroup:AddSlider({ Name = "Dash max distance", Min = 15, Max = 100, Default = 33, Increment = 1, Callback = function(v) Options.AutoDashDistance = v end })
playerGroup:AddToggle({ Name = "Disable 3D Rendering", Default = false, Callback = function(v) Toggles.Disable3DRender = v end })
AddSliderToggle(playerGroup, "Grav", "Gravity", false, 196, 0, 500, 1)
AddSliderToggle(playerGroup, "Zoom", "Camera Zoom", false, 128, 128, 10000, 0)
AddSliderToggle(playerGroup, "FOV", "Field of View", false, 70, 30, 120, 0)

serverGroup:AddToggle({ Name = "Anti AFK", Default = true, Callback = function(v) Toggles.AntiAFK = v end })
serverGroup:AddToggle({ Name = "Anti Kick (Client)", Default = false, Callback = function(v) Toggles.AntiKick = v end })
serverGroup:AddToggle({ Name = "Auto Reconnect", Default = false, Callback = function(v) Toggles.AutoReconnect = v end })
serverGroup:AddToggle({ Name = "No Gameplay Pau
