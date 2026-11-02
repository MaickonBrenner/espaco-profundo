-- Gerenciador de cenas (substitui o antigo gameState com strings).
--
-- Cada cena fica em src/scenes/<nome>.lua e pode definir (todas opcionais):
--   load()              -> chamada uma única vez, na primeira vez que a cena é usada
--   enter(...)          -> chamada toda vez que a cena se torna ativa (recebe os args do switch)
--   leave()             -> chamada ao sair da cena
--   update(dt), draw(), keypressed(key)
local SceneManager = {}

local scenes = {}
local current = nil
local currentName = nil

local function getScene(name)
    local scene = scenes[name]
    if not scene then
        scene = require("src.scenes." .. name)
        scenes[name] = scene
        if scene.load then scene.load() end
    end
    return scene
end

function SceneManager.switch(name, ...)
    if current and current.leave then current.leave() end
    current = getScene(name)
    currentName = name
    if current.enter then current.enter(...) end
end

function SceneManager.getCurrentName()
    return currentName
end

function SceneManager.update(dt)
    if current and current.update then current.update(dt) end
end

function SceneManager.draw()
    if current and current.draw then current.draw() end
    love.graphics.setColor(1, 1, 1)
end

function SceneManager.keypressed(key)
    if current and current.keypressed then current.keypressed(key) end
end

return SceneManager
