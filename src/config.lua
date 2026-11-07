-- Configurações e constantes centralizadas do jogo.
-- Se precisar balancear algo (preços, alcance do radar, cores), mexa aqui.
local Config = {}

Config.window = {
    title = "Espaço Profundo",
    width = 1024,
    height = 768,
}

-- Parâmetros gerais do mundo. Planetas e asteroides vivem em assets/data/*.json
Config.world = {
    chunkSize = 2048,
    seed = 1337,
    stars = {                      -- Estrelas de fundo (decorativas)
        quantidade = {60, 90},
        tamanho = {1, 3},
        brilho = {100, 255},       -- dividido por 255 ao gerar
    },
    stations = {                   -- Estações Espaciais
        chance = 0.8,
        raio = 35,
        margem = 300,
        prefixo = "Posto Orbital",
        numero = {100, 999},
        alcanceInteracao = 40,
    },
}

Config.economy = {
    refuelCost = 30,        -- Preço do reabastecimento/reparo na estação
    scanRewardMoney = 150,  -- Créditos ao explorar um alvo pela primeira vez
    scanRewardScore = 300,  -- Pontos ao explorar um alvo pela primeira vez
}

Config.radar = {
    range = 800,    -- Raio da varredura de longo alcance
    maxItems = 4,   -- Quantos objetos aparecem no painel do radar
}

Config.ui = {
    messageDuration = 4,  -- Segundos que a mensagem da estação fica na tela
}

-- Paleta nomeada (valores de 0 a 1, formato LÖVE 11+)
Config.colors = {
    white         = {1, 1, 1},
    title         = {0, 1, 0},
    terminalGreen = {0, 1, 0},
    muted         = {0.7, 0.7, 0.7},
    message       = {1, 1, 0},
    black         = {0, 0, 0},

    fuelBack      = {0.3, 0.3, 0.3},
    fuelFill      = {1, 0.5, 0},

    radarBg       = {0, 0, 0, 0.75},

    scanPrompt    = {0, 1, 0, 0.9},
    stationPrompt = {1, 0.8, 0.2, 0.9},
}

return Config
