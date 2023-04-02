local json = require("json")
local mod = RegisterMod("Automatically destroy poops and fires", 1)

local defaultSettings = {
    destroyNormalPoops = true,
    destroyGoldenPoops = true,
    destroyRedPoops = false,
    destroyChunkyPoops = false,
    destroyBlackPoops = false,
    destroyNormalFires = true,
    destroyRedFires = true,
    destroyRocks = false,
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

local function setupMyModConfigMenuSettings()
    if ModConfigMenu == nil then
        return
    end

    -- Remove menu if it exists, makes debugging easier
    ModConfigMenu.RemoveCategory(mod.Name)

    ModConfigMenu.AddSetting(
            mod.Name,
            nil,
            {
                Type = ModConfigMenu.OptionType.BOOLEAN,
                CurrentSetting = function()
                    return settings.destroyNormalFires
                end,
                Display = function()
                    currentValue = settings.destroyNormalFires
                    return "Destroy normal fires?" .. tostring(currentValue)
                end,
                OnChange = function(newValue)
                    settings.destroyNormalFires = newValue
                end,
            }
    )
    ModConfigMenu.AddSetting(
            mod.Name,
            nil,
            {
                Type = ModConfigMenu.OptionType.BOOLEAN,
                CurrentSetting = function()
                    return settings.destroyRedFires
                end,
                Display = function()
                    currentValue = settings.destroyRedFires
                    return "Destroy red fires?" .. tostring(currentValue)
                end,
                OnChange = function(newValue)
                    settings.destroyRedFires = newValue
                end,
            }
    )
    ModConfigMenu.AddSetting(
            mod.Name,
            nil,
            {
                Type = ModConfigMenu.OptionType.BOOLEAN,
                CurrentSetting = function()
                    return settings.destroyNormalPoops
                end,
                Display = function()
                    currentValue = settings.destroyNormalPoops
                    return "Destroy normal poops?" .. tostring(currentValue)
                end,
                OnChange = function(newValue)
                    settings.destroyNormalPoops = newValue
                end,
            }
    )
    ModConfigMenu.AddSetting(
            mod.Name,
            nil,
            {
                Type = ModConfigMenu.OptionType.BOOLEAN,
                CurrentSetting = function()
                    return settings.destroyGoldenPoops
                end,
                Display = function()
                    currentValue = settings.destroyGoldenPoops
                    return "Destroy golden poops?" .. tostring(currentValue)
                end,
                OnChange = function(newValue)
                    settings.destroyGoldenPoops = newValue
                end,
            }
    )
    ModConfigMenu.AddSetting(
            mod.Name,
            nil,
            {
                Type = ModConfigMenu.OptionType.BOOLEAN,
                CurrentSetting = function()
                    return settings.destroyRedPoops
                end,
                Display = function()
                    currentValue = settings.destroyRedPoops
                    return "Destroy red poops?" .. tostring(currentValue)
                end,
                OnChange = function(newValue)
                    settings.destroyRedPoops = newValue
                end,
            }
    )
    ModConfigMenu.AddSetting(
            mod.Name,
            nil,
            {
                Type = ModConfigMenu.OptionType.BOOLEAN,
                CurrentSetting = function()
                    return settings.destroyBlackPoops
                end,
                Display = function()
                    currentValue = settings.destroyBlackPoops
                    return "Destroy black poops?" .. tostring(currentValue)
                end,
                OnChange = function(newValue)
                    settings.destroyBlackPoops = newValue
                end,
            }
    )
    ModConfigMenu.AddSetting(
            mod.Name,
            nil,
            {
                Type = ModConfigMenu.OptionType.BOOLEAN,
                CurrentSetting = function()
                    return settings.destroyChunkyPoops
                end,
                Display = function()
                    currentValue = settings.destroyChunkyPoops
                    return "Destroy chunky poops?" .. tostring(currentValue)
                end,
                OnChange = function(newValue)
                    settings.destroyChunkyPoops = newValue
                end,
            }
    )
    ModConfigMenu.AddSetting(
            mod.Name,
            nil,
            {
                Type = ModConfigMenu.OptionType.BOOLEAN,
                CurrentSetting = function()
                    return settings.destroyRocks
                end,
                Display = function()
                    currentValue = settings.destroyRocks
                    return "Destroy rocks?" .. tostring(currentValue)
                end,
                OnChange = function(newValue)
                    settings.destroyRocks = newValue
                end,
                Info = {
                    'Destroy rocks automatically if you could destroy them for free.'
                }
            }
    )
end

setupMyModConfigMenuSettings()

-- Destroy the poops and fireplaces in the current room if it's been cleared
local function destroyPoopsAndFires()
    local room = Game():GetRoom()
    local playerCanDestroyRocksForFree = false

    nPlayers = Game():GetNumPlayers()
    for i = 1, nPlayers do
        player = Game():GetPlayer(i)
        if (player:HasCollectible(CollectibleType.COLLECTIBLE_SAMSONS_CHAINS) and player.CanFly) or
                player:HasCollectible(CollectibleType.COLLECTIBLE_DR_FETUS) or
                player:HasCollectible(CollectibleType.COLLECTIBLE_EPIC_FETUS) or
                player:HasCollectible(CollectibleType.COLLECTIBLE_IPECAC) or
                player:HasCollectible(CollectibleType.COLLECTIBLE_SULFURIC_ACID) or
                player:HasGoldenBomb() or
                player:HasPlayerForm(PlayerForm.PLAYERFORM_STOMPY) then
            playerCanDestroyRocksForFree = true
        end
    end

    if room:IsClear() then
        for i = 1, room:GetGridSize() do
            local gridEntity = room:GetGridEntity(i)

            -- Variant 0 is normal poop, 3 is golden poop
            if gridEntity ~= nil then
                if gridEntity:GetType() == GridEntityType.GRID_POOP then
                    if (settings.destroyNormalPoops and gridEntity:GetVariant() == 0) or
                            (settings.destroyRedPoops and gridEntity:GetVariant() == 1) or
                            (settings.destroyChunkyPoops and gridEntity:GetVariant() == 2) or
                            (settings.destroyGoldenPoops and gridEntity:GetVariant() == 3) or
                            (settings.destroyBlackPoops and gridEntity:GetVariant() == 5) then
                        gridEntity:Destroy()
                    end
                end

                if (gridEntity:GetType() == GridEntityType.GRID_ROCK or
                        gridEntity:GetType() == GridEntityType.GRID_ROCK_BOMB or
                        gridEntity:GetType() == GridEntityType.GRID_ROCKT or
                        gridEntity:GetType() == GridEntityType.GRID_ROCK_SS or
                        gridEntity:GetType() == GridEntityType.GRID_ROCK_ALT) and
                        settings.destroyRocks and playerCanDestroyRocksForFree then
                    gridEntity:Destroy()
                end
            end
        end

        entities = room:GetEntities()
        for i = 1, entities.Size do
            local entity = entities:Get(i)
            if entity ~= nil and entity.Type == EntityType.ENTITY_FIREPLACE then
                if (settings.destroyNormalFires and entity.Variant == 0) or
                        (settings.destroyRedFires and entity.Variant == 1) then
                    entity:Die()
                end
            end
        end

    end
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, destroyPoopsAndFires)
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, destroyPoopsAndFires)
