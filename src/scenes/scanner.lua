-- Cena: Scanner de superfície de planetas/asteroides (antigo estado "PLANET_SCANNER")
-- As paletas de cores de cada tipo ficam em assets/data/planetas.json e asteroides.json
local SceneManager = require("src.core.scene_manager")
local Catalog = require("src.world.catalog")

local Scanner = {}

local TAMANHO_BLOCO = 16
local LARGURA_MAPA = 200
local ALTURA_MAPA = 150

local cameraX = 0
local cameraY = 0
local velocidadeCamera = 400
local mapaBiomas = {}
local nomeAlvo = nil

Scanner.sementeAltitude = 0
Scanner.sementeHumidade = 0
Scanner.tipoAlvo = "PLANETA"

function Scanner.load(alt, hum, tipo)
    Scanner.sementeAltitude = alt or math.random(1, 99999)
    Scanner.sementeHumidade = hum or math.random(1, 99999)
    Scanner.tipoAlvo = tipo or "MARTE"
    
    cameraX = 0
    cameraY = 0
    Scanner.gerarSuperficie()
end

-- Chamado pelo SceneManager ao entrar na cena: recebe o alvo escaneado
function Scanner.enter(alvo)
    nomeAlvo = alvo.name
    Scanner.load(alvo.seedAltitude, alvo.seedHumidity, alvo.type)
end

local function limitar(v)
    return math.max(0, math.min(1, v))
end

-- Converte a altitude (0 a 1) numa cor usando a paleta do tipo.
-- "camadas": a primeira camada cujo "ate" é maior que a altitude vence (sem "ate" = padrão).
-- "gradiente": tom de cinza = base + altitude * fator, somado a uma "tinta" por canal.
-- A umidade (hum) ainda não é usada por nenhuma paleta; fica disponível para camadas futuras.
local function corDoBioma(superficie, alt, hum)
    if not superficie then
        return {1, 1, 1}
    end

    if superficie.modo == "gradiente" then
        local tom = superficie.base + alt * superficie.fator
        local tinta = superficie.tinta or {0, 0, 0}
        return { limitar(tom + tinta[1]), limitar(tom + tinta[2]), limitar(tom + tinta[3]) }
    end

    for _, camada in ipairs(superficie.camadas) do
        if not camada.ate or alt < camada.ate then
            return camada.cor
        end
    end
    return {1, 1, 1}
end

function Scanner.gerarSuperficie()
    mapaBiomas = {}

    local superficie = Catalog.getSuperficie(Scanner.tipoAlvo)
    
    local offsetXAlt = Scanner.sementeAltitude % 1000
    local offsetYAlt = (Scanner.sementeAltitude / 2) % 1000
    local offsetXHum = Scanner.sementeHumidade % 1000
    local offsetYHum = (Scanner.sementeHumidade / 2) % 1000

    for y = 1, ALTURA_MAPA do
        mapaBiomas[y] = {}
        for x = 1, LARGURA_MAPA do
            local nx = (x + offsetXAlt) / 40.0
            local ny = (y + offsetYAlt) / 40.0
            local alt = love.math.noise(nx, ny)
            
            local hx = (x + offsetXHum) / 40.0
            local hy = (y + offsetYHum) / 40.0
            local hum = love.math.noise(hx, hy)
            
            mapaBiomas[y][x] = corDoBioma(superficie, alt, hum)
        end
    end
end

function Scanner.update(dt)
    if love.keyboard.isDown("left") then
        cameraX = cameraX - velocidadeCamera * dt
    end
    if love.keyboard.isDown("right") then
        cameraX = cameraX + velocidadeCamera * dt
    end
    if love.keyboard.isDown("up") then
        cameraY = cameraY - velocidadeCamera * dt
    end
    if love.keyboard.isDown("down") then
        cameraY = cameraY + velocidadeCamera * dt
    end

    local larguraMundo = LARGURA_MAPA * TAMANHO_BLOCO
    local alturaMundo = ALTURA_MAPA * TAMANHO_BLOCO
    local larguraTela = love.graphics.getWidth()
    local alturaTela = love.graphics.getHeight()

    cameraX = math.max(0, math.min(cameraX, larguraMundo - larguraTela))
    cameraY = math.max(0, math.min(cameraY, alturaMundo - alturaTela))
end

function Scanner.draw()
    love.graphics.clear(0.05, 0.05, 0.1)

    love.graphics.push()
    love.graphics.translate(-cameraX, -cameraY)
    
    for y = 1, #mapaBiomas do
        for x = 1, #mapaBiomas[y] do
            local cor = mapaBiomas[y][x]
            love.graphics.setColor(cor[1], cor[2], cor[3])
            love.graphics.rectangle("fill", (x - 1) * TAMANHO_BLOCO, (y - 1) * TAMANHO_BLOCO, TAMANHO_BLOCO, TAMANHO_BLOCO)
        end
    end
    
    love.graphics.pop()
    
    -- HUD do Computador de Bordo
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", 10, 10, 520, 80)
    
    love.graphics.setColor(0, 1, 0)
    love.graphics.print("ANÁLISE DE SUPERFÍCIE: " .. (nomeAlvo or "Desconhecido"), 20, 20)
    love.graphics.print("Setas: Mover visor | [ESC/BACKSPACE]: Retornar ao Espaço", 20, 40)
    love.graphics.print("CLASSE: " .. Scanner.tipoAlvo .. " | ALT: " .. Scanner.sementeAltitude .. " | HUM: " .. Scanner.sementeHumidade, 20, 60)
end

function Scanner.keypressed(key)
    if key == "escape" or key == "backspace" then
        SceneManager.switch("gameplay")
    end
end

return Scanner
