-- Cena: Mapa espacial (antigo estado "MAP")
local SceneManager = require("src.core.scene_manager")
local Player = require("src.entities.player")
local World = require("src.world.world")

local Map = {}

-- Variáveis de controle da câmera do mapa
local mapOffsetX = 0
local mapOffsetY = 0
local velocidadePan = 300

function Map.reset()
    -- Reseta a câmera para centralizar na nave ao abrir o mapa
    mapOffsetX = 0
    mapOffsetY = 0
end

-- Chamado pelo SceneManager ao entrar na cena
Map.enter = Map.reset

function Map.update(dt)
    -- Movimentação livre pelo mapa usando as setas do teclado
    if love.keyboard.isDown("left") or love.keyboard.isDown("a") then
        mapOffsetX = mapOffsetX - velocidadePan * dt
    end
    if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
        mapOffsetX = mapOffsetX + velocidadePan * dt
    end
    if love.keyboard.isDown("up") or love.keyboard.isDown("w") then
        mapOffsetY = mapOffsetY - velocidadePan * dt
    end
    if love.keyboard.isDown("down") or love.keyboard.isDown("s") then
        mapOffsetY = mapOffsetY + velocidadePan * dt
    end
end

function Map.draw()
    local activeChunks = World.getActiveChunks()
    local playerX, playerY = Player.x, Player.y
    local chunkSize = World.getChunkSize()
    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()

    -- Fundo semi-transparente cobrindo a tela
    love.graphics.setColor(0, 0, 0, 0.9)
    love.graphics.rectangle("fill", 50, 50, screenW - 100, screenH - 100)

    love.graphics.setColor(0, 1, 0) -- Verde terminal
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", 50, 50, screenW - 100, screenH - 100)

    -- Cabeçalho e instruções de controle
    love.graphics.print("=== MAPA ESPACIAL (SISTEMA ESTELAR KHORUS) ===", 70, 70)
    love.graphics.print("Setas/WASD: Mover Câmera | [M] ou [ESC]: Retornar ao Voo", 70, screenH - 75)

    -- Centro base da tela do mapa
    local mapCenterX = screenW / 2 + mapOffsetX
    local mapCenterY = screenH / 2 + mapOffsetY

    -- Descobre o chunk atual do player
    local pCx = math.floor(playerX / chunkSize)
    local pCy = math.floor(playerY / chunkSize)

    -- Escala do mini-mapa
    local scale = 0.05

    -- Desenha os chunks descobertos armazenados na memória
    for chunkKey, chunk in pairs(activeChunks) do
        local cx, cy = chunkKey:match("([^,]+),([^,]+)")
        cx, cy = tonumber(cx), tonumber(cy)

        -- Posição relativa aplicando o deslocamento da câmera do mapa
        local drawX = mapCenterX + (cx - pCx) * (chunkSize * scale)
        local drawY = mapCenterY + (cy - pCy) * (chunkSize * scale)

        -- Desenha apenas se estiver visível dentro da área da moldura do mapa
        if drawX > -200 and drawX < screenW + 200 and drawY > -200 and drawY < screenH + 200 then
            love.graphics.setColor(0.1, 0.3, 0.1, 0.6)
            love.graphics.rectangle("fill", drawX, drawY, chunkSize * scale, chunkSize * scale)
            love.graphics.setColor(0, 0.8, 0.3)
            love.graphics.rectangle("line", drawX, drawY, chunkSize * scale, chunkSize * scale)

            love.graphics.print("Setor " .. cx .. "," .. cy, drawX + 5, drawY + 5)

            -- Planetas no setor
            if chunk.planets then
                for _, p in ipairs(chunk.planets) do
                    love.graphics.setColor(p.color[1], p.color[2], p.color[3])
                    love.graphics.circle("fill", drawX + (p.x * scale), drawY + (p.y * scale), 5)
                end
            end

            -- Estações no setor
            if chunk.stations then
                for _, s in ipairs(chunk.stations) do
                    love.graphics.setColor(1, 0.8, 0.2)
                    love.graphics.rectangle("fill", drawX + (s.x * scale) - 3, drawY + (s.y * scale) - 3, 6, 6)
                end
            end

            -- Estrela do Sistema (Khorus)
            if chunk.systemStar then
                local s = chunk.systemStar
                love.graphics.setColor(1, 0.9, 0.2)
                love.graphics.circle("fill", drawX + (s.x * scale), drawY + (s.y * scale), 8)
                love.graphics.setColor(1, 1, 1)
                love.graphics.print("[ESTRELA " .. string.upper(s.name) .. "]", drawX + (s.x * scale) + 10, drawY + (s.y * scale) - 5)
            end

            -- Asteroides no setor
            if chunk.asteroids then
                for _, ast in ipairs(chunk.asteroids) do
                    love.graphics.setColor(0.6, 0.6, 0.6)
                    love.graphics.circle("fill", drawX + (ast.x * scale), drawY + (ast.y * scale), 3)
                end
            end
        end
    end

    -- Desenha a posição fixa da nave no mapa tático (relativa ao centro real)
    local naveDrawX = screenW / 2 + mapOffsetX
    local naveDrawY = screenH / 2 + mapOffsetY
    love.graphics.setColor(1, 0, 0)
    love.graphics.circle("fill", naveDrawX, naveDrawY, 6)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("<- VOCÊ", naveDrawX + 10, naveDrawY - 6)

    love.graphics.setColor(1, 1, 1)
end

function Map.keypressed(key)
    if key == "m" or key == "escape" then
        SceneManager.switch("gameplay")
    end
end

return Map