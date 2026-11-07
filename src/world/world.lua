local Generator = require("src.world.generator")
local World = {}

local activeChunks = {}

function World.load()
    activeChunks = {}
end

function World.getActiveChunks()
    return activeChunks
end

function World.getChunkSize()
    return Generator.chunkSize
end

function World.getChunkCoords(x, y)
    local cx = math.floor(x / Generator.chunkSize)
    local cy = math.floor(y / Generator.chunkSize)
    return cx, cy
end

local function distancia(x1, y1, x2, y2)
    return math.sqrt((x1 - x2)^2 + (y1 - y2)^2)
end

-- Percorre o chunk atual e os 8 ao redor, chamando fn(chunk, offsetX, offsetY).
-- Se fn retornar algo diferente de nil/false, a busca para e esse valor é devolvido.
local function percorrerChunksProximos(playerX, playerY, fn)
    local pCx, pCy = World.getChunkCoords(playerX, playerY)

    for x = pCx - 1, pCx + 1 do
        for y = pCy - 1, pCy + 1 do
            local chunkKey = x .. "," .. y
            local chunk = activeChunks[chunkKey]

            if chunk then
                local worldOffsetX = x * Generator.chunkSize
                local worldOffsetY = y * Generator.chunkSize

                local resultado = fn(chunk, worldOffsetX, worldOffsetY)
                if resultado then
                    return resultado
                end
            end
        end
    end
    return nil
end

function World.update(dt, playerX, playerY)
    local pCx, pCy = World.getChunkCoords(playerX, playerY)

    for x = pCx - 1, pCx + 1 do
        for y = pCy - 1, pCy + 1 do
            local chunkKey = x .. "," .. y
            if not activeChunks[chunkKey] then
                activeChunks[chunkKey] = Generator.generateChunk(x, y)
            else
                local chunk = activeChunks[chunkKey]
                for _, ast in ipairs(chunk.asteroids) do
                    ast.x = ast.x + ast.vx * dt
                    ast.y = ast.y + ast.vy * dt
                    
                    if ast.x < 0 then ast.x = Generator.chunkSize end
                    if ast.x > Generator.chunkSize then ast.x = 0 end
                    if ast.y < 0 then ast.y = Generator.chunkSize end
                    if ast.y > Generator.chunkSize then ast.y = 0 end
                end
            end
        end
    end
end

function World.checkPlanetProximity(playerX, playerY)
    return percorrerChunksProximos(playerX, playerY, function(chunk, offX, offY)
        -- Checa se está perto da Estrela Khorus
        if chunk.systemStar then
            local star = chunk.systemStar
            local dist = distancia(playerX, playerY, offX + star.x, offY + star.y)
            if dist < star.radius + star.interactRange then
                return {
                    name = "Estrela " .. star.name,
                    type = star.type,
                    explored = true,
                    seedAltitude = star.seedAltitude,
                    seedHumidity = star.seedHumidity
                }
            end
        end

        -- Checa planetas
        for _, planet in ipairs(chunk.planets) do
            local dist = distancia(playerX, playerY, offX + planet.x, offY + planet.y)
            if dist < planet.radius + planet.interactRange then
                return planet
            end
        end

        -- Checa asteroides
        for _, ast in ipairs(chunk.asteroids) do
            local dist = distancia(playerX, playerY, offX + ast.x, offY + ast.y)
            if dist < ast.radius + ast.interactRange then
                return ast
            end
        end
    end)
end

-- Retorna uma lista ordenada de objetos próximos dentro de um raio de alcance
function World.getRadarObjects(playerX, playerY, raioMaximo)
    local radarItens = {}

    local function registrar(obj, tipo, offX, offY)
        local dist = distancia(playerX, playerY, offX + obj.x, offY + obj.y)
        if dist <= raioMaximo then
            table.insert(radarItens, { name = obj.name, type = tipo, dist = math.floor(dist) })
        end
    end

    -- Varre o chunk atual e os 8 chunks ao redor para capturar objetos distantes
    percorrerChunksProximos(playerX, playerY, function(chunk, offX, offY)
        -- 1. Verifica Estrela Khorus
        if chunk.systemStar then
            registrar(chunk.systemStar, "ESTRELA", offX, offY)
        end

        -- 2. Verifica Planetas
        for _, planet in ipairs(chunk.planets) do
            registrar(planet, "PLANETA", offX, offY)
        end

        -- 3. Verifica Estações Espaciais
        for _, station in ipairs(chunk.stations) do
            registrar(station, "POSTO", offX, offY)
        end

        -- 4. Verifica Asteroides Viajantes
        for _, ast in ipairs(chunk.asteroids) do
            registrar(ast, "ASTEROIDE", offX, offY)
        end

        return nil -- continua varrendo os demais chunks
    end)

    -- Ordena os itens do mais próximo para o mais distante
    table.sort(radarItens, function(a, b)
        return a.dist < b.dist
    end)

    return radarItens
end

function World.checkStationProximity(playerX, playerY)
    return percorrerChunksProximos(playerX, playerY, function(chunk, offX, offY)
        for _, station in ipairs(chunk.stations) do
            local dist = distancia(playerX, playerY, offX + station.x, offY + station.y)
            if dist < station.radius + station.interactRange then
                return station
            end
        end
    end)
end

function World.draw(playerX, playerY)
    percorrerChunksProximos(playerX, playerY, function(chunk, worldOffsetX, worldOffsetY)
        -- Estrelas de fundo
        for _, star in ipairs(chunk.stars) do
            love.graphics.setColor(star.brightness, star.brightness, star.brightness, star.brightness)
            love.graphics.circle("fill", worldOffsetX + star.x, worldOffsetY + star.y, star.size)
        end

        -- Desenha a Estrela Khorus se presente no chunk
        if chunk.systemStar then
            local s = chunk.systemStar
            -- Halo de luz ao redor da estrela
            for _, halo in ipairs(s.halo or {}) do
                love.graphics.setColor(s.color[1], s.color[2], s.color[3], halo.alpha)
                love.graphics.circle("fill", worldOffsetX + s.x, worldOffsetY + s.y, s.radius + halo.extra)
            end
            
            -- Núcleo da estrela
            love.graphics.setColor(s.color)
            love.graphics.circle("fill", worldOffsetX + s.x, worldOffsetY + s.y, s.radius)
            love.graphics.setColor(1, 1, 1)
            love.graphics.circle("line", worldOffsetX + s.x, worldOffsetY + s.y, s.radius)
            love.graphics.print(s.name .. " (Estrela)", worldOffsetX + s.x - 75, worldOffsetY + s.y - s.radius - 35)
        end

        -- Planetas Gigantes
        for _, planet in ipairs(chunk.planets) do
            love.graphics.setColor(planet.color)
            love.graphics.circle("fill", worldOffsetX + planet.x, worldOffsetY + planet.y, planet.radius)
            love.graphics.setColor(1, 1, 1)
            love.graphics.circle("line", worldOffsetX + planet.x, worldOffsetY + planet.y, planet.radius)
            love.graphics.print(planet.name, worldOffsetX + planet.x - 40, worldOffsetY + planet.y - planet.radius - 25)
        end

        -- Estações Espaciais
        for _, station in ipairs(chunk.stations) do
            love.graphics.setColor(1, 0.8, 0.2)
            love.graphics.circle("fill", worldOffsetX + station.x, worldOffsetY + station.y, station.radius)
            love.graphics.setColor(0, 0, 0)
            love.graphics.circle("line", worldOffsetX + station.x, worldOffsetY + station.y, station.radius)
            love.graphics.setColor(1, 1, 1)
            love.graphics.print(station.name, worldOffsetX + station.x - 35, worldOffsetY + station.y - station.radius - 20)
        end

        -- Asteroides Viajantes
        for _, ast in ipairs(chunk.asteroids) do
            love.graphics.setColor(ast.color)
            love.graphics.circle("fill", worldOffsetX + ast.x, worldOffsetY + ast.y, ast.radius)
            love.graphics.setColor(0.8, 0.8, 0.8)
            love.graphics.circle("line", worldOffsetX + ast.x, worldOffsetY + ast.y, ast.radius)
            love.graphics.setColor(1, 1, 1, 0.8)
            love.graphics.print(ast.name, worldOffsetX + ast.x - 35, worldOffsetY + ast.y - ast.radius - 18)
        end

        return nil -- continua desenhando os demais chunks
    end)
    
    love.graphics.setColor(1, 1, 1)
end

return World
