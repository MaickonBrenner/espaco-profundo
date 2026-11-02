-- Cena: Menu principal
local Config = require("src.config")
local Session = require("src.core.session")
local SceneManager = require("src.core.scene_manager")
local DrawUtils = require("src.ui.draw_utils")

local Menu = {}

function Menu.draw()
    local alturaTela = love.graphics.getHeight()
    local data = Session.data
    local C = Config.colors

    local tituloLinha1 = "=== [ E S P A Ç O   P R O F U N D O ] ==="
    local instrucao = "Pressione [ENTER] para Iniciar Missão"
    local txtDinheiro = "Créditos: $" .. data.money
    local txtPontos = "Pontuação: " .. data.score
    local txtNave = "Modelo da Nave: " .. data.shipModel

    local startY = alturaTela / 2 - 60

    love.graphics.setColor(C.title)
    DrawUtils.centered(tituloLinha1, startY)

    love.graphics.setColor(C.white)
    DrawUtils.centered(instrucao, startY + 50)
    DrawUtils.centered(txtDinheiro, startY + 95)
    DrawUtils.centered(txtPontos, startY + 120)
    DrawUtils.centered(txtNave, startY + 145)
end

function Menu.keypressed(key)
    if key == "return" then
        SceneManager.switch("gameplay")
    end
end

return Menu
