local mod = RegisterMod("Automatically destroy poops and fires", 1)

-- Destroy the poops and fireplaces in the current room if it's been cleared
local function destroyPoopsAndFires()
    local room = Game():GetRoom()
    if room:IsClear() then
        for i = 0, room:GetGridSize() do
            local gridEntity = room:GetGridEntity(i)

            -- Variant 0 is normal poop, 3 is golden poop
            if gridEntity ~= nil and gridEntity:GetType() == GridEntityType.GRID_POOP and (gridEntity:GetVariant() == 0 or gridEntity:GetVariant() == 3) then
                gridEntity:Destroy()
            end
        end

        entities = room:GetEntities()
        for i = 0, entities.Size do
            entity = entities:Get(i)
            -- entity can be nil for some reason
            -- Variant 0 are normal fireplaces
            if entity ~= nil and entity.Type == EntityType.ENTITY_FIREPLACE and entity.Variant == 0 then
                entity:Die()
            end
        end

    end
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, destroyPoopsAndFires)
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, destroyPoopsAndFires)
