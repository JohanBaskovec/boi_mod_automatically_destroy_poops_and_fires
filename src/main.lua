local json = require("json")
local mod = RegisterMod("Automatically destroy poops and fires", 1)

local defaultSettings = {
    destroyNormalPoops = true,
    destroyGoldenPoops = true,
    destroyRedPoops = false,
    destroyChunkyPoops = false,
    destroyBlackPoops = false,
    destroyNormalFires = true,
    destroyRedFires = false,
    destroyRocks = false,
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
    ModConfigMenu.AddSetting(
            mod.Name,
            nil,
            {
                Type = ModConfigMenu.OptionType.BOOLEAN,
                CurrentSetting = function()
                    return settings.destroySecretRoomEntrances
                end,
                Display = function()
                    currentValue = settings.destroySecretRoomEntrances
                    return "Destroy secret room entrances?" .. tostring(currentValue)
                end,
                OnChange = function(newValue)
                    settings.destroySecretRoomEntrances = newValue
                end,
                Info = {
                    'Destroy secret room entrances automatically if you could destroy them for free.'
                }
            }
    )
end

setupMyModConfigMenuSettings()

local blownUpWalls = {}

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

-- Destroy the poops and fireplaces in the current room if it's been cleared
local function destroyPoopsAndFires()
    local room = Game():GetRoom()
    local playerCanDestroyRocksForFree = false
    local playerCanDestroyWallsForFree = false

    nPlayers = Game():GetNumPlayers()
    for i = 1, nPlayers do
        player = Game():GetPlayer(i)
        if player:HasCollectible(CollectibleType.COLLECTIBLE_SAMSONS_CHAINS) or
                player:HasCollectible(CollectibleType.COLLECTIBLE_DR_FETUS) or
                player:HasCollectible(CollectibleType.COLLECTIBLE_EPIC_FETUS) or
                player:HasCollectible(CollectibleType.COLLECTIBLE_IPECAC) or
                player:HasCollectible(CollectibleType.COLLECTIBLE_LEO) or
                player:HasCollectible(CollectibleType.COLLECTIBLE_TERRA) or
                player:HasCollectible(CollectibleType.COLLECTIBLE_NUMBER_TWO) or
                player:HasCollectible(CollectibleType.COLLECTIBLE_SULFURIC_ACID) or
                player:HasCollectible(CollectibleType.COLLECTIBLE_FRUIT_CAKE) or
                player:HasGoldenBomb() or
                player:HasPlayerForm(PlayerForm.PLAYERFORM_STOMPY) then
            playerCanDestroyRocksForFree = true
        end
        if player:HasCollectible(CollectibleType.COLLECTIBLE_DR_FETUS) or
                player:HasCollectible(CollectibleType.COLLECTIBLE_EPIC_FETUS) or
                player:HasCollectible(CollectibleType.COLLECTIBLE_IPECAC) or
                player:HasCollectible(CollectibleType.COLLECTIBLE_TERRA) or
                player:HasCollectible(CollectibleType.COLLECTIBLE_NUMBER_TWO) or
                player:HasCollectible(CollectibleType.COLLECTIBLE_SULFURIC_ACID) or
                player:HasCollectible(CollectibleType.COLLECTIBLE_FRUIT_CAKE) or
                player:HasGoldenBomb() then
            playerCanDestroyWallsForFree = true
        end
    end
    if room:IsClear() then
        local currentRoomIsSecret = room:GetType() == RoomType.ROOM_SECRET or room:GetType() == RoomType.ROOM_SUPERSECRET
        if playerCanDestroyWallsForFree and settings.destroySecretRoomEntrances then
            for i = 0, DoorSlot.NUM_DOOR_SLOTS do
                -- Secret room walls are doors!
                door = room:GetDoor(i)
                if door ~= nil then
                    targetRoomId = door.TargetRoomIndex
                    -- For some reason, door:IsOpen() and door:IsBusted() always return false when entering a room,
                    -- so we can't rely on these functions to determine if the doors have been opened, so we
                    -- keep track of the blown up walls manually in the table blownUpWalls
                    if (door:IsRoomType(RoomType.ROOM_SECRET) or door:IsRoomType(RoomType.ROOM_SUPERSECRET) or currentRoomIsSecret) and blownUpWalls[targetRoomId] == nil then
                        blownUpWalls[targetRoomId] = true
                        local doorSlotPosition = room:GetDoorSlotPosition(i)
                        local gridIndex = room:GetGridIndex(doorSlotPosition)
                        room:DestroyGrid(gridIndex)
                    end
                end
            end
        end

        for i = 1, room:GetGridSize() do
            local gridEntity = room:GetGridEntity(i)

            -- We don't destroy rocks that contain a bomb (GridEntityType.GRID_ROCK_BOMB),
            -- and mushrooms, pots and skulls (all GridEntityType.GRID_ROCK_ALT) because they could hurt the player
            -- TODO: D12 and Mom's bracelet can make rocks useful so maybe we shouldn't destroy them then?
            if gridEntity ~= nil and (
                    (
                            gridEntity:GetType() == GridEntityType.GRID_POOP and (
                                    (settings.destroyNormalPoops and gridEntity:GetVariant() == 0) or
                                            (settings.destroyRedPoops and gridEntity:GetVariant() == 1) or
                                            (settings.destroyChunkyPoops and gridEntity:GetVariant() == 2) or
                                            (settings.destroyGoldenPoops and gridEntity:GetVariant() == 3) or
                                            (settings.destroyBlackPoops and gridEntity:GetVariant() == 5)
                            )
                    ) or (
                            (gridEntity:GetType() == GridEntityType.GRID_ROCK or
                                    gridEntity:GetType() == GridEntityType.GRID_ROCKT or
                                    gridEntity:GetType() == GridEntityType.GRID_ROCK_SS) and
                                    settings.destroyRocks and playerCanDestroyRocksForFree)
            ) then
                createBridgesAroundGridEntity(gridEntity)
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

local function initForNewStage()
    blownUpWalls = {}
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, destroyPoopsAndFires)
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, destroyPoopsAndFires)
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, initForNewStage)
