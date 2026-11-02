-- Dados persistentes da sessão (dinheiro, pontos, modelo da nave...).
-- Fonte única de verdade, compartilhada entre as cenas.
local SaveManager = require("src.core.savemanager")

local Session = {}

Session.data = {}

function Session.load()
    Session.data = SaveManager.loadGame()
end

function Session.save()
    SaveManager.saveGame(Session.data)
end

return Session
