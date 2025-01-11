local mod = RegisterMod("mirror_boss_trapdoor", 1)
local game = Game()

function onClear()
    local room = game:GetRoom()
    local RoomType = room:GetType()

    -- Checks if we are in the mirror world and if the room is a Boss type
    if room:IsMirrorWorld() and RoomType == 5 then

        -- Get the position of the room center
        local gridIndex = room:GetGridIndex(room:GetCenterPos())
        local width = room:GetGridWidth()
        local adjustedGridIndex = gridIndex - width * 2 -- Moving the spawn coordinates of the trapdoor two rows
        print(tostring(gridIndex))
        print(tostring(width))

        -- Generate the trapdoor to move to the next floor
        room:SpawnGridEntity(adjustedGridIndex, GridEntityType.GRID_TRAPDOOR, 0, 0, 0)
        local success = room:TrySpawnSecretExit(true, true)
    end 
end

function clearedRoom()
    local room = game:GetRoom()
    local RoomType = room:GetType()

    -- When entering a room checks if the world is mirroed and if the room is the trapdoor room to the alt path floors
    if room:IsMirrorWorld() and RoomType == 27 then
        local gridIndex = room:GetGridIndex(room:GetCenterPos())

        -- Spawns the trapdoor to the mines
        room:SpawnGridEntity(gridIndex, GridEntityType.GRID_TRAPDOOR, 0, 0, 0)
    end
    
    -- This part is to keep the secret room door from disappearing
    if room:IsMirrorWorld() and RoomType == 5 and room:IsClear() then
        local success = room:TrySpawnSecretExit(false, true)
    end
end

mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, onClear)
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, clearedRoom)
