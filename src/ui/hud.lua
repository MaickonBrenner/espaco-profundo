-- HUD Espacial (dinheiro, pontos, controles, combustível e mensagens)
local Config = require("src.config")

local HUD = {}

local FUEL_BAR = { x = 100, y = 55, w = 150, h = 15 }

function HUD.draw(data, player, mensagem)
    local C = Config.colors

    love.graphics.setColor(C.white)
    love.graphics.print("Dinheiro: $" .. data.money .. " | Pontos: " .. data.score, 10, 10)
    love.graphics.print("Controles: W (Acelerar) | A/D (Girar) | [M] Mapa | ESC (Menu)", 10, 30)

    -- Barra de Combustível na HUD
    love.graphics.print("Combustível:", 10, 55)
    love.graphics.setColor(C.fuelBack)
    love.graphics.rectangle("fill", FUEL_BAR.x, FUEL_BAR.y, FUEL_BAR.w, FUEL_BAR.h)
    love.graphics.setColor(C.fuelFill)
    love.graphics.rectangle("fill", FUEL_BAR.x, FUEL_BAR.y, FUEL_BAR.w * player.getFuelRatio(), FUEL_BAR.h)
    love.graphics.setColor(C.white)
    love.graphics.rectangle("line", FUEL_BAR.x, FUEL_BAR.y, FUEL_BAR.w, FUEL_BAR.h)

    if mensagem ~= "" then
        love.graphics.setColor(C.message)
        love.graphics.print(mensagem, 10, 80)
    end
end

return HUD
