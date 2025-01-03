local mod = RegisterMod("Mirror Boss Shortcut", 1)
local game = Game()

-- Función para detectar la muerte del jefe
function mod:OnBossDeath(npc)
    local room = game:GetRoom()

    -- Verificar si estamos en el mundo espejo, si el NPC es un jefe y si estamos en la sala correcta
    if room:IsMirrorWorld() and npc:IsBoss() and room:GetType() == RoomType.ROOM_BOSS then
        -- Cambiar al mundo normal
        local level = game:GetLevel()

        -- Obtener el índice de la misma sala pero en el mundo normal
        local currentRoomIndex = level:GetCurrentRoomIndex()
        level:ChangeRoom(currentRoomIndex, 0) -- Cambiar a la dimensión principal
    end
end

-- Vinculamos la función al evento de muerte de NPCs
mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, mod.OnBossDeath)
