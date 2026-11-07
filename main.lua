-- Ponto de entrada: só inicializa e delega para o gerenciador de cenas.
local Session = require("src.core.session")
local SceneManager = require("src.core.scene_manager")
local DataLoader = require("src.core.data_loader")

function love.load()
    -- Carrega os JSONs logo de início: se algum estiver com erro, o jogo avisa na hora
    DataLoader.preload({ "planetas", "asteroides", "naves" })
    Session.load()
    SceneManager.switch("menu")
end

function love.update(dt)
    SceneManager.update(dt)
end

function love.draw()
    SceneManager.draw()
end

function love.keypressed(key)
    SceneManager.keypressed(key)
end

-- Garante que o progresso é salvo mesmo ao fechar a janela direto
function love.quit()
    Session.save()
end
