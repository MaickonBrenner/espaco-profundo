-- Ponto de entrada: só inicializa e delega para o gerenciador de cenas.
local Session = require("src.core.session")
local SceneManager = require("src.core.scene_manager")

function love.load()
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
