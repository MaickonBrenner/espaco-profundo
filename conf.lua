-- Configuração da janela (roda antes de tudo, evita abrir no tamanho padrão e redimensionar)
local Config = require("src.config")

function love.conf(t)
    t.window.title = Config.window.title
    t.window.width = Config.window.width
    t.window.height = Config.window.height
end
