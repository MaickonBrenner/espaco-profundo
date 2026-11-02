-- Aviso de interação na parte inferior da tela (ex: "Pressione [E] para ...")
local Config = require("src.config")

local Prompt = {}

local WIDTH = 440
local HEIGHT = 40

-- offsetFromBottom: distância entre a base da caixa e o fim da tela, mais a altura (ex: 90, 40)
function Prompt.draw(text, bgColor, offsetFromBottom)
    local x = love.graphics.getWidth() / 2 - WIDTH / 2
    local y = love.graphics.getHeight() - offsetFromBottom

    love.graphics.setColor(bgColor)
    love.graphics.rectangle("fill", x, y, WIDTH, HEIGHT)
    love.graphics.setColor(Config.colors.black)
    love.graphics.print(text, x + 10, y + 10)
end

return Prompt
