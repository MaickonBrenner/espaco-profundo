-- Cena: Voo espacial (antigo estado "PLAYING")
local Config = require("src.config")
local Session = require("src.core.session")
local SceneManager = require("src.core.scene_manager")
local Camera = require("src.core.camera")
local Player = require("src.entities.player")
local World = require("src.world.world")
local Economy = require("src.systems.economy")
local HUD = require("src.ui.hud")
local RadarPanel = require("src.ui.radar_panel")
local Prompt = require("src.ui.prompt")

local Gameplay = {}

-- Estado exclusivo desta cena
local alvoPerto = nil        -- Para interação restrita (Tecla E)
local stationPerto = nil     -- Para reparo restrito (Tecla R)
local radarLista = {}        -- Varredura de longo alcance do radar
local mensagemEstacao = ""
local mensagemTimer = 0

local function mostrarMensagem(texto)
    mensagemEstacao = texto
    mensagemTimer = Config.ui.messageDuration
end

-- Chamado uma única vez, na primeira vez que a cena é usada
function Gameplay.load()
    Player.load(Session.data.shipModel)
    Camera.load()
    World.load()
end

function Gameplay.update(dt)
    Player.update(dt)
    Camera.update(dt, Player.x, Player.y)
    World.update(dt, Player.x, Player.y)
    
    -- Interação imediata (curto alcance)
    alvoPerto = World.checkPlanetProximity(Player.x, Player.y)
    stationPerto = World.checkStationProximity(Player.x, Player.y)
    
    -- Radar de longo alcance (detecta objetos num raio de X pixels)
    radarLista = World.getRadarObjects(Player.x, Player.y, Config.radar.range)

    -- Some com a mensagem da estação depois de alguns segundos
    if mensagemTimer > 0 then
        mensagemTimer = mensagemTimer - dt
        if mensagemTimer <= 0 then
            mensagemEstacao = ""
        end
    end
end

function Gameplay.draw()
    Camera.apply()
    World.draw(Player.x, Player.y)
    Player.draw()
    Camera.detach()
    
    HUD.draw(Session.data, Player, mensagemEstacao)
    RadarPanel.draw(radarLista)

    -- Aviso de Interação (Curto alcance para escaneamento com E)
    if alvoPerto then
        Prompt.draw("Pressione [E] para Escanear: " .. alvoPerto.name, Config.colors.scanPrompt, 90)
    end
    
    -- Aviso de Estação Espacial Próxima (Curto alcance para reabastecer com R)
    if stationPerto then
        Prompt.draw("Pressione [R] para Reabastecer/Reparar ($" .. Config.economy.refuelCost .. ")",
            Config.colors.stationPrompt, 40)
    end
end

function Gameplay.keypressed(key)
    if key == "m" then
        SceneManager.switch("map")

    elseif key == "e" and alvoPerto then
        if Economy.scanTarget(alvoPerto, Session.data) then
            Session.save()
        end
        SceneManager.switch("scanner", alvoPerto)

    elseif key == "r" and stationPerto then
        local ok, mensagem = Economy.refuel(Session.data, Player, stationPerto)
        mostrarMensagem(mensagem)
        if ok then
            Session.save()
        end

    elseif key == "escape" then
        Session.save()
        SceneManager.switch("menu")
    end
end

return Gameplay
