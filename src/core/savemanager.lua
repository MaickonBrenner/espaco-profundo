local json = require("lib.dkjson")
local SaveManager = {}
local SAVE_FILENAME = "savegame.json"

function SaveManager.getDefaultSave()
    return {
        money = 100,
        score = 0,
        shipModel = "Starter-Mk1",
        inventory = {
            fuel = 100,
            scrap = 0
        }
    }
end

function SaveManager.loadGame()
    if not love.filesystem.getInfo(SAVE_FILENAME) then
        local defaultData = SaveManager.getDefaultSave()
        SaveManager.saveGame(defaultData)
        return defaultData
    end

    local contents, size = love.filesystem.read(SAVE_FILENAME)
    if not contents then
        return SaveManager.getDefaultSave()
    end

    local data, pos, err = json.decode(contents, 1, nil)
    if err then
        print("Erro ao decodificar JSON do save: " .. err)
        return SaveManager.getDefaultSave()
    end

    return data
end

function SaveManager.saveGame(data)
    local contents = json.encode(data, { indent = true })
    local success, message = love.filesystem.write(SAVE_FILENAME, contents)
    
    if not success then
        print("Erro ao salvar o jogo: " .. (message or "desconhecido"))
    end
end

return SaveManager