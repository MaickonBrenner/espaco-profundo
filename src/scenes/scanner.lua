-- Cena: Scanner de superfície de planetas/asteroides (antigo estado "PLANET_SCANNER")
local SceneManager = require("src.core.scene_manager")

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

function Scanner.gerarSuperficie()
    mapaBiomas = {}
    
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
            
            local cor = {1, 1, 1}

            -- ASTEROIDE: Renderiza estritamente em tons de cinza (metálico/rochoso)
            if Scanner.tipoAlvo == "ASTEROIDE" then
                local tom = 0.15 + (alt * 0.5)
                cor = {tom, tom, tom}

            -- PLANETA TERRA (Super verde e florestal)
            elseif Scanner.tipoAlvo == "TERRA" then
                if alt < 0.2 then
                    cor = {0.1, 0.3, 0.7} -- Pequenos lagos / oceanos rasos
                elseif alt < 0.3 then
                    cor = {0.8, 0.75, 0.5} -- Praias
                elseif alt < 0.6 then
                    cor = {0.05, 0.5, 0.15} -- Floresta densa verde-escura
                elseif alt < 0.8 then
                    cor = {0.2, 0.7, 0.25} -- Campos e colinas verdes
                else
                    cor = {0.4, 0.4, 0.4} -- Montanhas rochosas
                end

            -- PLANETA AGUA (Mundo oceânico com ilhas e montanhas)
            elseif Scanner.tipoAlvo == "AGUA" then
                if alt < 0.65 then
                    cor = {0.02, 0.25, 0.75} -- Oceano profundo e vasto
                elseif alt < 0.72 then
                    cor = {0.1, 0.5, 0.9} -- Oceano raso / Corais
                elseif alt < 0.85 then
                    cor = {0.8, 0.75, 0.55} -- Ilhas de areia / praias
                else
                    cor = {0.35, 0.35, 0.35} -- Cordilheiras de montanhas insulares
                end

            -- PLANETA MARTE: Deserto ferrugem, crateras escuras e desfiladeiros
            elseif Scanner.tipoAlvo == "MARTE" then
                if alt < 0.3 then
                    cor = {0.4, 0.15, 0.05} -- Solo profundo escuro
                elseif alt < 0.75 then
                    cor = {0.75, 0.35, 0.15} -- Deserto de óxido de ferro
                else
                    cor = {0.55, 0.25, 0.1} -- Rochas altas de ferrugem
                end

            -- PLANETA VÊNUS: Vales sulfúricos e vulcânicos quentes
            elseif Scanner.tipoAlvo == "VENUS" then
                if alt < 0.35 then
                    cor = {0.5, 0.3, 0.05} -- Magma / Depressão sulfúrica
                elseif alt < 0.7 then
                    cor = {0.8, 0.6, 0.1} -- Planície amarela ácida
                else
                    cor = {0.9, 0.8, 0.3} -- Cratera vulcânica
                end

            -- PLANETA MERCÚRIO: Crateras densas e cinza escuro rochoso
            elseif Scanner.tipoAlvo == "MERCURIO" then
                local tom = 0.2 + (alt * 0.4)
                cor = {tom + 0.05, tom, tom - 0.05} -- Cinza com leve tom metálico

            -- PLANETA PLUTÃO: Gelo nitrogenado e planícies gélidas
            elseif Scanner.tipoAlvo == "PLUTAO" then
                if alt < 0.4 then
                    cor = {0.3, 0.4, 0.5} -- Gelo escuro profundo
                elseif alt < 0.75 then
                    cor = {0.6, 0.75, 0.85} -- Planície congelada
                else
                    cor = {0.9, 0.95, 1.0} -- Pico de nitrogênio congelado
                end
            end
            
            mapaBiomas[y][x] = cor
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