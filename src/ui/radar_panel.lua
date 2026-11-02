-- Painel do Radar de Longo Alcance (Lateral Direita)
local Config = require("src.config")

local RadarPanel = {}

function RadarPanel.draw(radarLista)
    local C = Config.colors
    local screenW = love.graphics.getWidth()

    love.graphics.setColor(C.radarBg)
    love.graphics.rectangle("fill", screenW - 260, 10, 250, 140)
    love.graphics.setColor(C.terminalGreen)
    love.graphics.print("--- RADAR DE LONGO ALCANCE ---", screenW - 250, 16)

    if #radarLista > 0 then
        local posY = 38
        -- Mostra até N objetos capturados pelo radar
        for i = 1, math.min(#radarLista, Config.radar.maxItems) do
            local obj = radarLista[i]
            love.graphics.print(obj.type .. ": " .. obj.name .. " (" .. obj.dist .. "u)", screenW - 250, posY)
            posY = posY + 20
        end
    else
        love.graphics.setColor(C.muted)
        love.graphics.print("Nenhum sinal detectado no raio.", screenW - 250, 45)
    end
end

return RadarPanel
