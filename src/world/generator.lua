local Generator = {}

Generator.chunkSize = 2048
Generator.seed = 1337

-- Coordenadas de mundo onde a estrela Khorus está localizada (bem distante do ponto inicial 0,0)
local KHORUS_CHUNK_X = 2
local KHORUS_CHUNK_Y = -2

local function hashCoordinates(cx, cy, seed)
    local h = seed + cx * 374761393 + cy * 668265263
    h = (h * 1274126177) % 2147483647
    h = math.floor(h / 8192)
    return math.abs(h % 1000000) / 1000000
end

local function escolherTipoPlaneta()
    local r = math.random()
    -- 5% de chance de ser um planeta Tipo Terra (Raríssimo)
    if r < 0.04 then
        return "TERRA", {0.1, 0.7, 0.2} -- Verde exuberante
    -- 15% de chance de ser um Mundo de Água (Oceanos profundos com ilhas)
    elseif r < 0.08 then
        return "AGUA", {0.05, 0.4, 0.9} -- Azul oceânico forte
    -- Demais chances divididas entre os inóspitos comuns
    elseif r < 0.30 then
        return "MARTE", {0.8, 0.3, 0.1} -- Ferrugem / Vermelho
    elseif r < 0.55 then
        return "VENUS", {0.9, 0.7, 0.2} -- Amarelo / Sulfúrico
    elseif r < 0.80 then
        return "MERCURIO", {0.5, 0.5, 0.5} -- Cinza Rochoso
    else
        return "PLUTAO", {0.6, 0.8, 0.9} -- Gélido / Azul claro
    end
end

function Generator.generateChunk(chunkX, chunkY)
    local chunkData = {
        stars = {},
        planets = {},
        stations = {},
        asteroids = {},
        systemStar = nil -- Estrela central do sistema, se houver neste chunk
    }

    local localSeed = math.floor(hashCoordinates(chunkX, chunkY, Generator.seed) * 100000)
    math.randomseed(localSeed)

    -- Se for o chunk exato da Estrela Khorus, injetamos ela no centro
    if chunkX == KHORUS_CHUNK_X and chunkY == KHORUS_CHUNK_Y then
        chunkData.systemStar = {
            x = Generator.chunkSize / 2,
            y = Generator.chunkSize / 2,
            radius = 280, -- Gigantesca comparada aos planetas
            name = "Khorus",
            color = {1.0, 0.9, 0.2} -- Amarelo estelar brilhante
        }
    end

    -- Estrelas
    local numStars = math.random(60, 90)
    for i = 1, numStars do
        table.insert(chunkData.stars, {
            x = math.random(0, Generator.chunkSize),
            y = math.random(0, Generator.chunkSize),
            size = math.random(1, 3),
            brightness = math.random(100, 255) / 255
        })
    end

    -- Planetas (Raros, com classes e cores baseadas no tipo)
    -- Não geramos planetas no mesmo chunk exato da estrela para mantê-la soberana
    if not (chunkX == KHORUS_CHUNK_X and chunkY == KHORUS_CHUNK_Y) and math.random() > 0.4 then
        local tipo, corDominante = escolherTipoPlaneta()
        table.insert(chunkData.planets, {
            x = math.random(400, Generator.chunkSize - 400),
            y = math.random(400, Generator.chunkSize - 400),
            radius = math.random(200, 350),
            name = tipo .. "-" .. math.random(100, 999),
            type = tipo,
            color = corDominante,
            seedAltitude = math.random(1, 9999),
            seedHumidity = math.random(1, 9999),
            explored = false
        })
    end

    -- Estações Espaciais
    if math.random() > 0.2 then
        table.insert(chunkData.stations, {
            x = math.random(300, Generator.chunkSize - 300),
            y = math.random(300, Generator.chunkSize - 300),
            radius = 35,
            name = "Posto Orbital " .. math.random(100, 999)
        })
    end

    -- Asteroides Viajantes
    local numAsteroids = math.random(4, 8)
    for i = 1, numAsteroids do
        local angle = math.random() * math.pi * 2
        local speed = math.random(20, 60)
        table.insert(chunkData.asteroids, {
            x = math.random(200, Generator.chunkSize - 200),
            y = math.random(200, Generator.chunkSize - 200),
            radius = math.random(40, 70),
            vx = math.cos(angle) * speed,
            vy = math.sin(angle) * speed,
            name = "Asteroide-Drifter " .. math.random(10, 99),
            type = "ASTEROIDE",
            color = {0.4, 0.4, 0.4},
            seedAltitude = math.random(1, 9999),
            seedHumidity = math.random(1, 9999),
            explored = false
        })
    end

    return chunkData
end

return Generator