local json = require("json")
local mod = RegisterMod("Automatically destroy poops and fires", 1)

local CHOICE_YES = "Yes"
local CHOICE_NO = "No"
local CHOICE_AFTER_20_MINUTES_OR_BOSS_RUSH = "After 20 minutes or boss rush"
local CHOICE_AFTER_30_MINUTES_OR_HUSH = "After 30 minutes or Hush"
local enabledChoices = {
    CHOICE_YES,
    CHOICE_AFTER_20_MINUTES_OR_BOSS_RUSH,
    CHOICE_AFTER_30_MINUTES_OR_HUSH,
    CHOICE_NO,
}

local function getTableIndex(tbl, val)
    for i, v in ipairs(tbl) do
        if v == val then
            return i
        end
    end

    return 0
end

local defaultSettings = {
    enabled = enabledChoices[1],
    destroyNormalPoops = true,
    destroyGoldenPoops = true,
    destroyRedPoops = false,
    destroyChunkyPoops = false,
    destroyBlackPoops = false,
    destroyNormalFires = true,
    destroyRedFires = false,
    destroyRocks = false,
    destroyRocksAndFiresIfD12 = false,
    destroyRocksIfMomsBracelet = false,
    destroySecretRoomEntrances = false,
}

local settings = defaultSettings

local function saveSettings()
    local jsonString = json.encode(settings)
    mod:SaveData(jsonString)
end

mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, saveSettings)

local function loadSettings()
    local jsonString = mod:LoadData()
    settings = json.decode(jsonString)
    -- newly added settings are set to default value
    for k, v in pairs(defaultSettings) do
        if settings[k] == nil then
            settings[k] = defaultSettings[k]
        end
    end
end

local function initializeSettings()
    if not mod:HasData() then
        settings = defaultSettings
        return
    end

    if not pcall(loadSettings) then
        settings = defaultSettings
        Isaac.DebugString("Error: Failed to load " .. mod.Name .. " settings, reverting to default settings.")
    end
end

initializeSettings()

local optionsModName = "Destroy poops&fires"
local function setupMyModConfigMenuSettings()
    if ModConfigMenu == nil then
        return
    end

    -- Remove menu if it exists, makes debugging easier
    ModConfigMenu.RemoveCategory(optionsModName)

    ModConfigMenu.AddSetting(
            optionsModName,
            nil,
            {
                Type = ModConfigMenu.OptionType.NUMBER,
                CurrentSetting = function()
                    return getTableIndex(enabledChoices, settings.enabled)
                end,
                Minimum = 1,
                Maximum = #enabledChoices,
                Display = function()
                    return "Enabled: " .. settings.enabled
                end,
                OnChange = function(n)
                    settings.enabled = enabledChoices[n]
                end,
                Info = {
                    "Use this setting if you don't want to cheat: if you're aiming for Hush, enable only after 30 minutes, ",
                    "if you're aiming for the boss rush, enable only after 20 minutes, enable otherwise.",
                }
            }
    )
    ModConfigMenu.AddSetting(
            optionsModName,
            nil,
            {
                Type = ModConfigMenu.OptionType.BOOLEAN,
                CurrentSetting = function()
                    return settings.destroyNormalFires
                end,
                Display = function()
                    currentValue = settings.destroyNormalFires
                    return "Destroy normal fires? " .. tostring(currentValue)
                end,
                OnChange = function(newValue)
                    settings.destroyNormalFires = newValue
                end,
            }
    )
    ModConfigMenu.AddSetting(
            optionsModName,
            nil,
            {
                Type = ModConfigMenu.OptionType.BOOLEAN,
                CurrentSetting = function()
                    return settings.destroyRedFires
                end,
                Display = function()
                    currentValue = settings.destroyRedFires
                    return "Destroy red fires? " .. tostring(currentValue)
                end,
                OnChange = function(newValue)
                    settings.destroyRedFires = newValue
                end,
            }
    )
    ModConfigMenu.AddSetting(
            optionsModName,
            nil,
            {
                Type = ModConfigMenu.OptionType.BOOLEAN,
                CurrentSetting = function()
                    return settings.destroyNormalPoops
                end,
                Display = function()
                    currentValue = settings.destroyNormalPoops
                    return "Destroy normal poops? " .. tostring(currentValue)
                end,
                OnChange = function(newValue)
                    settings.destroyNormalPoops = newValue
                end,
            }
    )
    ModConfigMenu.AddSetting(
            optionsModName,
            nil,
            {
                Type = ModConfigMenu.OptionType.BOOLEAN,
                CurrentSetting = function()
                    return settings.destroyGoldenPoops
                end,
                Display = function()
                    currentValue = settings.destroyGoldenPoops
                    return "Destroy golden poops? " .. tostring(currentValue)
                end,
                OnChange = function(newValue)
                    settings.destroyGoldenPoops = newValue
                end,
            }
    )
    ModConfigMenu.AddSetting(
            optionsModName,
            nil,
            {
                Type = ModConfigMenu.OptionType.BOOLEAN,
                CurrentSetting = function()
                    return settings.destroyRedPoops
                end,
                Display = function()
                    currentValue = settings.destroyRedPoops
                    return "Destroy red poops? " .. tostring(currentValue)
                end,
                OnChange = function(newValue)
                    settings.destroyRedPoops = newValue
                end,
            }
    )
    ModConfigMenu.AddSetting(
            optionsModName,
            nil,
            {
                Type = ModConfigMenu.OptionType.BOOLEAN,
                CurrentSetting = function()
                    return settings.destroyBlackPoops
                end,
                Display = function()
                    currentValue = settings.destroyBlackPoops
                    return "Destroy black poops? " .. tostring(currentValue)
                end,
                OnChange = function(newValue)
                    settings.destroyBlackPoops = newValue
                end,
            }
    )
    ModConfigMenu.AddSetting(
            optionsModName,
            nil,
            {
                Type = ModConfigMenu.OptionType.BOOLEAN,
                CurrentSetting = function()
                    return settings.destroyChunkyPoops
                end,
                Display = function()
                    currentValue = settings.destroyChunkyPoops
                    return "Destroy chunky poops? " .. tostring(currentValue)
                end,
                OnChange = function(newValue)
                    settings.destroyChunkyPoops = newValue
                end,
            }
    )
    ModConfigMenu.AddSetting(
            optionsModName,
            nil,
            {
                Type = ModConfigMenu.OptionType.BOOLEAN,
                CurrentSetting = function()
                    return settings.destroyRocks
                end,
                Display = function()
                    currentValue = settings.destroyRocks
                    return "Destroy obstacles? " .. tostring(currentValue)
                end,
                OnChange = function(newValue)
                    settings.destroyRocks = newValue
                end,
                Info = {
                    'Destroy obstacles (rocks, pots, skulls, mushrooms) automatically if you could destroy them for free and safely.'
                }
            }
    )
    ModConfigMenu.AddSetting(
            optionsModName,
            nil,
            {
                Type = ModConfigMenu.OptionType.BOOLEAN,
                CurrentSetting = function()
                    return settings.destroyRocksIfMomsBracelet
                end,
                Display = function()
                    currentValue = settings.destroyRocksIfMomsBracelet
                    return "Destroy obstacles if Mom's bracelet? " .. tostring(currentValue)
                end,
                OnChange = function(newValue)
                    settings.destroyRocksIfMomsBracelet = newValue
                end,
                Info = {
                    "Destroy obstacles (rocks, pots, skulls, mushrooms) automatically if have Mom's bracelet equipped."
                }
            }
    )
    ModConfigMenu.AddSetting(
            optionsModName,
            nil,
            {
                Type = ModConfigMenu.OptionType.BOOLEAN,
                CurrentSetting = function()
                    return settings.destroyRocksAndFiresIfD12
                end,
                Display = function()
                    currentValue = settings.destroyRocksAndFiresIfD12
                    return "Destroy obstacles&fires if D12? " .. tostring(currentValue)
                end,
                OnChange = function(newValue)
                    settings.destroyRocksAndFiresIfD12 = newValue
                end,
                Info = {
                    'Destroy obstacles (rocks, pots, skulls, mushrooms) and fires automatically if you could destroy them for free and safely and you have the D12 equipped.'
                }
            }
    )
    ModConfigMenu.AddSetting(
            optionsModName,
            nil,
            {
                Type = ModConfigMenu.OptionType.BOOLEAN,
                CurrentSetting = function()
                    return settings.destroySecretRoomEntrances
                end,
                Display = function()
                    currentValue = settings.destroySecretRoomEntrances
                    return "Open secret room entrances? " .. tostring(currentValue)
                end,
                OnChange = function(newValue)
                    settings.destroySecretRoomEntrances = newValue
                end,
                Info = {
                    'Open secret room entrances automatically if you could destroy them for free.'
                }
            }
    )
end

setupMyModConfigMenuSettings()

local function createBridgesAroundGridEntity(gridEntity)
    local room = Game():GetRoom()
    local position = gridEntity.Position
    local neighborPositions = {
        Vector(position.X - 40, position.Y), -- left
        Vector(position.X + 40, position.Y), -- right
        Vector(position.X, position.Y - 40), -- top
        Vector(position.X, position.Y + 40), -- bottom
    }
    for k, v in pairs(neighborPositions) do
        neighborIndex = room:GetGridIndex(v)
        neighbor = room:GetGridEntity(neighborIndex)
        if neighbor ~= nil then
            pit = neighbor:ToPit()
            if pit ~= nil then
                pit:MakeBridge(nil)
            end
        end
    end
end

local function isModEnabled()
    local game = Game()
    local minutesElapsed = (game.TimeCounter / 30) / 60

    local level = game:GetLevel()
    local stage = level:GetStage()
    local room = level:GetCurrentRoom()
    local isBossRush = room:GetType() == RoomType.ROOM_BOSSRUSH

    modEnabled = (settings.enabled == CHOICE_YES or
            (settings.enabled == CHOICE_AFTER_20_MINUTES_OR_BOSS_RUSH and (minutesElapsed > 20 or isBossRush or stage >= LevelStage.STAGE4_1)) or
            (settings.enabled == CHOICE_AFTER_30_MINUTES_OR_HUSH and (minutesElapsed > 30 or stage >= LevelStage.STAGE4_3)))
    return modEnabled
end

-- Destroy the poops and fireplaces in the current room if it's been cleared
function destroyPoopsAndFires()
    if not isModEnabled() then
        return ;
    end

    local game = Game()
    local room = game:GetRoom()

    local playerCanDestroyObstaclesForFree = false
    local playerCanDestroyObstaclesSafely = false
    local playerCanDestroyWallsForFree = false
    local destroyedObstaclesCreateBridge = false

    nPlayers = game:GetNumPlayers()

    for i = 1, nPlayers do
        player = Game():GetPlayer(i)
        if player:HasCollectible(CollectibleType.COLLECTIBLE_D12) and not settings.destroyRocksAndFiresIfD12 then
            return
        end
        if player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_BRACELET) and settings.destroyRocksIfMomsBracelet then
            playerCanDestroyObstaclesForFree = true
            playerCanDestroyObstaclesSafely = true
        end
        if player:HasCollectible(CollectibleType.COLLECTIBLE_SAMSONS_CHAINS) or
                player:HasCollectible(CollectibleType.COLLECTIBLE_LEO) or
                player:HasPlayerForm(PlayerForm.PLAYERFORM_STOMPY) then
            playerCanDestroyObstaclesForFree = true
            destroyedObstaclesCreateBridge = true
        end

        if player:HasGoldenBomb() or
                player:HasCollectible(CollectibleType.COLLECTIBLE_DR_FETUS) or
                player:HasCollectible(CollectibleType.COLLECTIBLE_EPIC_FETUS) or
                player:HasCollectible(CollectibleType.COLLECTIBLE_IPECAC) or
                player:HasCollectible(CollectibleType.COLLECTIBLE_TERRA) or
                player:HasCollectible(CollectibleType.COLLECTIBLE_NUMBER_TWO) or
                player:HasCollectible(CollectibleType.COLLECTIBLE_SULFURIC_ACID) or
                player:HasCollectible(CollectibleType.COLLECTIBLE_FRUIT_CAKE) then
            playerCanDestroyObstaclesForFree = true
            playerCanDestroyWallsForFree = true
            playerCanDestroyObstaclesSafely = true
            destroyedObstaclesCreateBridge = true
        end
    end
    if playerCanDestroyWallsForFree then
        local level = game:GetLevel()
        level:SetCanSeeEverything(true)
    end
    if room:IsClear() then
        for i = 1, nPlayers do
            player = Game():GetPlayer(i)
            -- We make the player immune to bomb explosion and poison clouds (from mushroom)
            player:AddCollectible(CollectibleType.COLLECTIBLE_HOST_HAT, 0, false)
            player:AddCollectible(CollectibleType.COLLECTIBLE_BOBS_CURSE, 0, false)
        end
        for i = 1, room:GetGridSize() do
            local gridEntity = room:GetGridEntity(i)

            -- TODO: verify that player could reach the entity
            if gridEntity ~= nil then
                if (
                        gridEntity:GetType() == GridEntityType.GRID_POOP and (
                                (settings.destroyNormalPoops and gridEntity:GetVariant() == 0) or
                                        (settings.destroyRedPoops and gridEntity:GetVariant() == 1) or
                                        (settings.destroyChunkyPoops and gridEntity:GetVariant() == 2) or
                                        (settings.destroyGoldenPoops and gridEntity:GetVariant() == 3) or
                                        (settings.destroyBlackPoops and gridEntity:GetVariant() == 5))
                ) or (
                        (gridEntity:GetType() == GridEntityType.GRID_ROCK or
                                gridEntity:GetType() == GridEntityType.GRID_ROCKT or
                                gridEntity:GetType() == GridEntityType.GRID_ROCK_SPIKED or
                                gridEntity:GetType() == GridEntityType.GRID_ROCK_SS) and
                                settings.destroyRocks and playerCanDestroyObstaclesForFree
                ) or (
                        (gridEntity:GetType() == GridEntityType.GRID_ROCK_BOMB or
                                gridEntity:GetType() == GridEntityType.GRID_ROCK_ALT) and
                                settings.destroyRocks and playerCanDestroyObstaclesForFree and
                                playerCanDestroyObstaclesSafely
                ) then
                    if destroyedObstaclesCreateBridge then
                        createBridgesAroundGridEntity(gridEntity)
                    end
                    gridEntity:Destroy()
                end

            end
        end

        entities = room:GetEntities()
        for i = 1, entities.Size do
            local entity = entities:Get(i)
            -- TODO: verify that player could reach the fire
            if entity ~= nil then
                -- Remove mobs spawned by destroying pots and skulls
                if entity.Type == EntityType.ENTITY_SPIDER or entity.Type == EntityType.ENTITY_HOST then
                    entity:Die()
                end
                if entity.Type == EntityType.ENTITY_FIREPLACE and (settings.destroyNormalFires and entity.Variant == 0) or
                        (settings.destroyRedFires and entity.Variant == 1) then
                    entity:Die()
                end
            end
        end

        for i = 1, nPlayers do
            player = Game():GetPlayer(i)
            player:RemoveCollectible(CollectibleType.COLLECTIBLE_HOST_HAT)
            player:RemoveCollectible(CollectibleType.COLLECTIBLE_BOBS_CURSE)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, destroyPoopsAndFires)
mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, destroyPoopsAndFires)
