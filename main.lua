local mod = RegisterMod("Mirror Boss Shortcut", 1)
local game = Game()

local timer = nil -- Variable para controlar el temporizador
local targetRoomIndex = nil -- Variable para guardar la sala objetivo
local player = Isaac.GetPlayer()

-- Función para detectar la muerte del jefe
function onClear()
    local room = game:GetRoom()
    local RoomType = room:GetType()

    -- Verificar si estamos en el mundo espejo y si la habitación es de tipo Bosss
    if room:IsMirrorWorld() and RoomType == 5 then
        --Cambiar al mundo normal
        local level = game:GetLevel()

        -- Obtener el índice de la misma sala pero en el mundo normal
        timer = 150 -- 5 segundos (150 frames, 30 FPS estándar)
        local currentRoomIndex = level:GetCurrentRoomIndex()
        targetRoomIndex = level:GetCurrentRoomIndex() -- Guardar el índice de la sala objetivo
        end
end

function OnUpdate()
    if timer then
        timer = timer - 1
        if timer <= 0 then
            -- Realizar el cambio de sala después de 5 segundos
            local level = game:GetLevel()
            level:ChangeRoom(targetRoomIndex, 0) -- Cambiar a la dimensión principal
            -- Reiniciar el temporizador
            timer = nil
            targetRoomIndex = nil
        end
    end
end
-- Función para renderizar el texto en pantalla
function OnRender()
    if timer then
        local player = Isaac.GetPlayer(0) -- Obtener el jugador principal
        local pos = Game():GetRoom():WorldToScreenPosition(player.Position) -- Convertir a coordenadas de pantalla

        -- Ajustar la posición del texto para que aparezca debajo del personaje
        local textX = pos.X - 380
        local textY = pos.Y - 50 -- Añadir un offset vertical para posicionar el texto debajo del jugador

        Isaac.RenderText("Returning to normal world in " .. tostring(math.ceil(timer / 30)) .. " seconds", -textX, textY, 1, 1, 1, 255)
    end
end


-- Vinculamos las funciones a los eventos
mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, onClear)
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, OnUpdate)
mod:AddCallback(ModCallbacks.MC_POST_RENDER, OnRender)