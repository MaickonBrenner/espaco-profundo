-- Regras de negócio de créditos/pontos (antes viviam dentro do keypressed do main).
-- Não desenha nada e não lê input: só altera dados e devolve o resultado.
local Config = require("src.config")

local Economy = {}

-- Escanear um alvo pela primeira vez rende créditos e pontos.
-- Retorna true se houve recompensa (ou seja, vale a pena salvar).
function Economy.scanTarget(target, data)
    if target.explored then
        return false
    end

    target.explored = true
    data.money = data.money + Config.economy.scanRewardMoney
    data.score = data.score + Config.economy.scanRewardScore
    return true
end

-- Reabastece/repara a nave numa estação.
-- Retorna (sucesso, mensagem).
function Economy.refuel(data, player, station)
    local cost = Config.economy.refuelCost

    if player.isFuelFull() then
        return false, "Tanque de combustível já está cheio!"
    elseif data.money >= cost then
        data.money = data.money - cost
        player.refuel()
        return true, "Nave reabastecida com sucesso no " .. station.name .. "!"
    else
        return false, "Dinheiro insuficiente para reabastecer! ($" .. cost .. " necessário)"
    end
end

return Economy
