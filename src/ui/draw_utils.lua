-- Funções de desenho reutilizáveis
local DrawUtils = {}

-- Imprime o texto centralizado horizontalmente na tela
function DrawUtils.centered(text, y)
    local font = love.graphics.getFont()
    local x = (love.graphics.getWidth() - font:getWidth(text)) / 2
    love.graphics.print(text, x, y)
end

return DrawUtils
