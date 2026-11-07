-- Nave do jogador. Os atributos e o formato vêm de assets/data/naves.json,
-- escolhidos pelo nome da nave (Session.data.shipModel).
local DataLoader = require("src.core.data_loader")

local Player = {}

-- Valores usados quando a nave não define o campo no naves.json
local DEFAULTS = {
    raio = 12,
    aceleracao = 300,
    velocidade_max = 400,
    atrito = 0.98,
    velocidade_rotacao = 4,
    tanque = 100,
    coeficiente_de_consumo = 1.5,  -- combustível gasto por segundo com o motor ligado
    vida = 100,
    escudo = 0,
    armas = false,
}

-- Formato usado se a nave não tiver "formato" (mesmo desenho da Starter-Mk1)
local FORMATO_PADRAO = {
    cor = {0.2, 0.8, 1},
    corpo = { {{1.5, 0}, {-1, 1}, {-0.5, 0}, {-1, -1}} },
    corChama = {1, 0.5, 0},
    chama = { {{-0.5, 0}, {-1.5, -0.5}, {-1.2, 0}, {-1.5, 0.5}} },
}

local function buscarNave(nome)
    local naves = DataLoader.load("naves")
    for _, nave in ipairs(naves) do
        if nave.nome == nome then
            return nave
        end
    end
    print("Nave '" .. tostring(nome) .. "' não encontrada em naves.json; usando " .. naves[1].nome)
    return naves[1]
end

local function campo(nave, nome)
    if nave[nome] ~= nil then
        return nave[nome]
    end
    return DEFAULTS[nome]
end

-- Converte polígonos em múltiplos do raio ({{x,y},...}) para listas planas em pixels
local function escalarPoligonos(poligonos, raio)
    local resultado = {}
    for _, pontos in ipairs(poligonos or {}) do
        local plano = {}
        for _, p in ipairs(pontos) do
            plano[#plano + 1] = p[1] * raio
            plano[#plano + 1] = p[2] * raio
        end
        resultado[#resultado + 1] = plano
    end
    return resultado
end

-- Aplica os atributos e o formato de uma nave do naves.json
function Player.setShip(nomeNave)
    local nave = buscarNave(nomeNave)

    Player.shipName = nave.nome
    Player.radius = campo(nave, "raio")
    Player.acceleration = campo(nave, "aceleracao")
    Player.maxSpeed = campo(nave, "velocidade_max")
    Player.friction = campo(nave, "atrito")
    Player.rotationSpeed = campo(nave, "velocidade_rotacao")
    Player.fuelBurnRate = campo(nave, "coeficiente_de_consumo")

    -- Atributos de sobrevivência da nave
    Player.maxFuel = campo(nave, "tanque")
    Player.fuel = Player.maxFuel
    Player.maxHull = campo(nave, "vida")
    Player.hull = Player.maxHull        -- Integridade estrutural (vida)
    Player.shield = campo(nave, "escudo")
    Player.hasWeapons = campo(nave, "armas")

    local formato = nave.formato or FORMATO_PADRAO
    Player.shape = {
        color = formato.cor or FORMATO_PADRAO.cor,
        body = escalarPoligonos(formato.corpo or FORMATO_PADRAO.corpo, Player.radius),
        flameColor = formato.corChama or FORMATO_PADRAO.corChama,
        flame = escalarPoligonos(formato.chama or {}, Player.radius),
    }
end

function Player.load(nomeNave)
    Player.x = love.graphics.getWidth() / 2
    Player.y = love.graphics.getHeight() / 2
    
    Player.angle = 0
    
    Player.vx = 0
    Player.vy = 0

    Player.setShip(nomeNave)
end

-- Motor ligado: tecla de aceleração pressionada E tem combustível
function Player.isThrusting()
    return (love.keyboard.isDown("w") or love.keyboard.isDown("up")) and Player.fuel > 0
end

function Player.getFuelRatio()
    return Player.fuel / Player.maxFuel
end

function Player.isFuelFull()
    return Player.fuel >= Player.maxFuel
end

function Player.refuel()
    Player.fuel = Player.maxFuel
end

function Player.update(dt)
    -- Rotação
    if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
        Player.angle = Player.angle - Player.rotationSpeed * dt
    end
    if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
        Player.angle = Player.angle + Player.rotationSpeed * dt
    end

    -- Aceleração (consome combustível se houver)
    if Player.isThrusting() then
        Player.vx = Player.vx + math.cos(Player.angle) * Player.acceleration * dt
        Player.vy = Player.vy + math.sin(Player.angle) * Player.acceleration * dt
        
        -- Consome combustível proporcionalmente ao uso do motor
        Player.fuel = math.max(0, Player.fuel - Player.fuelBurnRate * dt)
    end

    Player.vx = Player.vx * Player.friction
    Player.vy = Player.vy * Player.friction

    local currentSpeed = math.sqrt(Player.vx^2 + Player.vy^2)
    if currentSpeed > Player.maxSpeed then
        Player.vx = (Player.vx / currentSpeed) * Player.maxSpeed
        Player.vy = (Player.vy / currentSpeed) * Player.maxSpeed
    end

    Player.x = Player.x + Player.vx * dt
    Player.y = Player.y + Player.vy * dt
end

function Player.draw()
    love.graphics.push()
    love.graphics.translate(Player.x, Player.y)
    love.graphics.rotate(Player.angle)

    -- Casco: um ou mais polígonos definidos no JSON da nave
    love.graphics.setColor(Player.shape.color)
    for _, poligono in ipairs(Player.shape.body) do
        love.graphics.polygon("line", poligono)
    end
    
    -- Desenha o fogo do motor apenas se estiver acelerando E tiver combustível
    if Player.isThrusting() then
        love.graphics.setColor(Player.shape.flameColor)
        for _, poligono in ipairs(Player.shape.flame) do
            love.graphics.polygon("line", poligono)
        end
    end

    love.graphics.pop()
    love.graphics.setColor(1, 1, 1)
end

return Player
