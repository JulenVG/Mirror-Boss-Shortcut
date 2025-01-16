local mod = RegisterMod("mirror_boss_trapdoor", 1)
local game = Game()
local doorState = 0
local alreadyBlown = 0

local function isRightStage()
    local level = Game():GetLevel()
    if level:GetStage() == 1 or level:GetStage() == 2 then
        return true
    else
        return false
    end
end

-- Checks if you're on the first boss on an XL floor
local function isFirstBossInXL()
    local room = game:GetRoom()
    local bossDoors = 0

    for i = 0, 7 do
        local door = room:GetDoor(i)
        if door then
            local sprite = door:GetSprite()
            if sprite:GetFilename() == "gfx/grid/Door_10_BossRoomDoor.anm2" then 
                bossDoors = bossDoors + 1 
            end
        end
    end
    if bossDoors == 2 then
        return true
    else
        return false
    end
end

-- Handles the secret exit door logic (opening or blowing up the door)
local function handleSecretExit(room)
    for i = 0, 7 do
        local door = room:GetDoor(i)
        if door and door.TargetRoomType == 27 then
            if not room:IsMirrorWorld() then
                if doorState == 1 and alreadyBlown == 0 then
                    door:TryBlowOpen(true, nil)
                    alreadyBlown = 1
                elseif doorState == 2 then
                    door:Open()
                    door:SetLocked(false)
                end
            elseif room:IsMirrorWorld() then
                if doorState == 1 then
                    door:TryBlowOpen(true, nil)
                elseif doorState == 2 then
                    door:Open()
                    door:SetLocked(false)
                end
            end
        end
    end
end

-- Called when a room is cleared to handle specific actions like spawning the trapdoor
local function onClear()

    -- Prevents the mod actuating on first XL boss or incorrect stage
    if isRightStage() and not isFirstBossInXL() then
        local room = game:GetRoom()
        local roomType = room:GetType()


            -- Checks if we are in the mirror world and if the room is a Boss type
            if room:IsMirrorWorld() and roomType == 5 then
                local gridIndex = room:GetGridIndex(room:GetCenterPos()) - room:GetGridWidth() * 2
                local gridEntity = room:GetGridEntity(gridIndex)

                -- If the trapdoor spot is a pit, removes the entity so the trapdoor can spawn
                if gridEntity and gridEntity:GetType() == GridEntityType.GRID_PIT then
                    room:RemoveGridEntity(gridIndex, 0, true)
                    --The api documentation said that this is not recommended. When I was testing the mod it did nothing weird so I keep it.
                    room:Update()
                end

                -- Spawns the trapdoor and the alt path door
                room:SpawnGridEntity(gridIndex, GridEntityType.GRID_TRAPDOOR, 0, 0, 0)
                room:TrySpawnSecretExit(true, true)
            end
            handleSecretExit(room)
    end
end

-- Called when entering a new room to handle specific actions
local function clearedRoom()

    -- Prevents the mod actuating on first XL boss or incorrect stage
    if isRightStage() and not isFirstBossInXL() then
        local room = game:GetRoom()
        local roomType = room:GetType()

        -- When entering a room, checks if the world is mirrored and if the room is the alt path trapdoor room
        if room:IsMirrorWorld() and roomType == 27 then
            local gridIndex = room:GetGridIndex(room:GetCenterPos())
            room:SpawnGridEntity(gridIndex, GridEntityType.GRID_TRAPDOOR, 0, 0, 0)
        end

        -- Keeps the secret room door active and sets it's current state
        if room:IsMirrorWorld() and roomType == 5 and room:IsClear() then
            room:TrySpawnSecretExit(false, true)
            handleSecretExit(room)
        elseif not room:IsMirrorWorld() and roomType == 5 and room:IsClear() then
            handleSecretExit(room)
        end
    end
end

-- Checks if the secret exit door is open or damaged
local function isSecretExitOpen()
    local room = game:GetRoom()

    for i = 0, 7 do
        local door = room:GetDoor(i)
        if door and door.TargetRoomType == 27 then
            local sprite = door.ExtraSprite
            if door:IsLocked() and sprite:GetAnimation() == "Damaged" then
                doorState = 1
                if not room:IsMirrorWorld() then
                    alreadyBlown = 1
                end
            elseif door:IsOpen() then
                doorState = 2
            end
        end
    end
end

-- Resets the door state and flags at the start of a new level
local function resetDoorState()
    doorState = 0
    alreadyBlown = 0
end

mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, onClear)
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, clearedRoom)
mod:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, isSecretExitOpen)
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, resetDoorState)

-- Function used for testing purposes
-- local function test()
--     print("doorState = " ..tostring(doorState))
--     print("alreadyBlown = " ..tostring(alreadyBlown))
-- end
-- mod:AddCallback(ModCallbacks.MC_USE_ITEM, test)