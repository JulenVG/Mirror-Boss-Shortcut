local mod = RegisterMod("Mirror Boss Shortcut", 1)
local game = Game()

-- Función para detectar la muerte del jefe
function onClear()
    local room = game:GetRoom()
    local RoomType = room:GetType()

    -- Verificar si estamos en el mundo espejo y si la habitación es de tipo Bosss
    if room:IsMirrorWorld() and RoomType == 5 then
        --Cambiar al mundo normal
        local level = game:GetLevel()

        -- Obtener el índice de la misma sala pero en el mundo normal
        local currentRoomIndex = level:GetCurrentRoomIndex()
        level:ChangeRoom(currentRoomIndex, 0) -- Cambiar a la dimensión principal
    end
end

-- Vinculamos la función a MC_PRE_SPAWN_CLEAN_AWARD
mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, onClear)

