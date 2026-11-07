-- Gerador de chunks. Os dados (tipos, probabilidades, corpos fixos) vêm de
-- assets/data/planetas.json e asteroides.json; parâmetros gerais vêm de src/config.lua.
local Config = require("src.config")
local Catalog = require("src.world.catalog")

local Generator = {}

Generator.chunkSize = Config.world.chunkSize
Generator.seed = Config.world.seed

local function hashCoordinates(cx, cy, seed)
    local h = seed + cx * 374761393 + cy * 668265263
    h = (h * 1274126177) % 2147483647
    h = math.floor(h / 8192)
    return math.abs(h % 1000000) / 1000000
end

-- Sorteia um inteiro dentro de uma faixa {min, max} vinda do JSON
local function sortear(faixa)
    return math.random(faixa[1], faixa[2])
end

-- Sorteia um item de uma lista usando o campo "peso" (maior peso = mais provável).
-- Lista com um único item não gasta sorteio.
local function escolherPorPeso(lista)
    if #lista == 1 then
        return lista[1]
    end

    local total = 0
    for _, def in ipairs(lista) do
        total = total + (def.peso or 1)
    end

    local r = math.random() * total
    local acumulado = 0
    for _, def in ipairs(lista) do
        acumulado = acumulado + (def.peso or 1)
        if r < acumulado then
            return def
        end
    end
    return lista[#lista]
end

-- Valor do corpo fixo, com fallback para o que o tipo define
local function valor(fixo, def, campo)
    if fixo[campo] ~= nil then
        return fixo[campo]
    end
    return def[campo]
end

-- Adiciona ao chunk um corpo de posição fixa (Khorus, Karone...). Não consome sorteios.
local function adicionarCorpoFixo(chunkData, fixo)
    local def = Catalog.getTipo(fixo.tipo)
    assert(def, "Corpo fixo '" .. tostring(fixo.nome) .. "' usa tipo desconhecido: " .. tostring(fixo.tipo))
    assert(type(fixo.raio) == "number", "Corpo fixo '" .. tostring(fixo.nome) .. "' precisa de um 'raio' numérico")

    local corpo = {
        x = fixo.posicao.x,
        y = fixo.posicao.y,
        radius = fixo.raio,
        name = fixo.nome,
        type = fixo.tipo,
        color = valor(fixo, def, "cor"),
        interactRange = valor(fixo, def, "alcanceInteracao") or 60,
        seedAltitude = fixo.seedAltitude or 1,
        seedHumidity = fixo.seedHumidity or 1,
    }

    if def.categoria == "estrela" then
        corpo.halo = valor(fixo, def, "halo")
        chunkData.systemStar = corpo -- Estrela central do sistema neste chunk
    else
        corpo.explored = false
        corpo.fixed = true
        table.insert(chunkData.planets, corpo)
    end
end

local function gerarPlanetaAleatorio(chunkData)
    local geracao = Catalog.planetas.geracao
    local def = escolherPorPeso(Catalog.planetasSorteaveis)

    local x = math.random(geracao.margem, Generator.chunkSize - geracao.margem)
    local y = math.random(geracao.margem, Generator.chunkSize - geracao.margem)
    local radius = sortear(def.raio)
    local nome = (def.prefixo or def.tipo) .. "-" .. sortear(geracao.numero)
    local seedAltitude = math.random(1, 9999)
    local seedHumidity = math.random(1, 9999)

    table.insert(chunkData.planets, {
        x = x,
        y = y,
        radius = radius,
        name = nome,
        type = def.tipo,
        color = def.cor,
        interactRange = def.alcanceInteracao or 60,
        seedAltitude = seedAltitude,
        seedHumidity = seedHumidity,
        explored = false
    })
end

local function gerarAsteroides(chunkData)
    local geracao = Catalog.asteroides.geracao
    local margem = geracao.margem
    local numAsteroids = sortear(geracao.quantidade)

    for i = 1, numAsteroids do
        local def = escolherPorPeso(Catalog.asteroides.tipos)

        local angle = math.random() * math.pi * 2
        local speed = sortear(def.velocidade)
        local x = math.random(margem, Generator.chunkSize - margem)
        local y = math.random(margem, Generator.chunkSize - margem)
        local radius = sortear(def.raio)
        local nome = def.prefixo .. " " .. sortear(def.numero)
        local seedAltitude = math.random(1, 9999)
        local seedHumidity = math.random(1, 9999)

        table.insert(chunkData.asteroids, {
            x = x,
            y = y,
            radius = radius,
            vx = math.cos(angle) * speed,
            vy = math.sin(angle) * speed,
            name = nome,
            type = def.tipo,
            color = def.cor,
            interactRange = def.alcanceInteracao or 40,
            seedAltitude = seedAltitude,
            seedHumidity = seedHumidity,
            explored = false
        })
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

    -- Corpos de posição fixa (Khorus, Karone...) definidos em planetas.json.
    -- Para mudar o local, edite "chunk" e "posicao" no JSON.
    local bloqueiaPlanetas = false
    for _, fixo in ipairs(Catalog.planetas.fixos) do
        if fixo.chunk.x == chunkX and fixo.chunk.y == chunkY then
            adicionarCorpoFixo(chunkData, fixo)
            if fixo.bloqueiaPlanetas then
                bloqueiaPlanetas = true
            end
        end
    end

    -- Estrelas de fundo
    local cfgStars = Config.world.stars
    local numStars = sortear(cfgStars.quantidade)
    for i = 1, numStars do
        table.insert(chunkData.stars, {
            x = math.random(0, Generator.chunkSize),
            y = math.random(0, Generator.chunkSize),
            size = sortear(cfgStars.tamanho),
            brightness = sortear(cfgStars.brilho) / 255
        })
    end

    -- Planetas (raros; tipo sorteado pelo "peso" de cada um em planetas.json)
    -- Chunks com corpo fixo marcado como "bloqueiaPlanetas" não recebem planetas aleatórios
    if not bloqueiaPlanetas and math.random() > 1 - Catalog.planetas.geracao.chance then
        gerarPlanetaAleatorio(chunkData)
    end

    -- Estações Espaciais
    local cfgEst = Config.world.stations
    if math.random() > 1 - cfgEst.chance then
        table.insert(chunkData.stations, {
            x = math.random(cfgEst.margem, Generator.chunkSize - cfgEst.margem),
            y = math.random(cfgEst.margem, Generator.chunkSize - cfgEst.margem),
            radius = cfgEst.raio,
            interactRange = cfgEst.alcanceInteracao,
            name = cfgEst.prefixo .. " " .. sortear(cfgEst.numero)
        })
    end

    -- Asteroides Viajantes
    gerarAsteroides(chunkData)

    return chunkData
end

return Generator
