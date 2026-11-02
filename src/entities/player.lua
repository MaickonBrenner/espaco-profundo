local Player = {}

-- Consumo de combustível por segundo com o motor ligado
local FUEL_BURN_RATE = 1.5

function Player.load()
    Player.x = love.graphics.getWidth() / 2
    Player.y = love.graphics.getHeight() / 2
    
    Player.radius = 12
    Player.angle = 0
    
    Player.vx = 0
    Player.vy = 0
    Player.acceleration = 300
    Player.maxSpeed = 400
    Player.friction = 0.98
    Player.rotationSpeed = 4
    
    -- Novos atributos de sobrevivência da nave
    Player.fuel = 100
    Player.maxFuel = 100
    Player.hull = 100        -- Integridade estrutural (vida)
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
        Player.fuel = math.max(0, Player.fuel - FUEL_BURN_RATE * dt)
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

    love.graphics.setColor(0.2, 0.8, 1)
    love.graphics.polygon("line", 
        Player.radius * 1.5, 0,
        -Player.radius, Player.radius,
        -Player.radius * 0.5, 0,
        -Player.radius, -Player.radius
    )
    
    -- Desenha o fogo do motor apenas se estiver acelerando E tiver combustível
    if Player.isThrusting() then
        love.graphics.setColor(1, 0.5, 0)
        love.graphics.polygon("line",
            -Player.radius * 0.5, 0,
            -Player.radius * 1.5, -Player.radius * 0.5,
            -Player.radius * 1.2, 0,
            -Player.radius * 1.5, Player.radius * 0.5
        )
    end

    love.graphics.pop()
    love.graphics.setColor(1, 1, 1)
end

return Player
