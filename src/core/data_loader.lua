-- Carrega arquivos JSON de assets/data/ (com cache).
local json = require("lib.dkjson")

local DataLoader = {}

local DATA_DIR = "assets/data/"
local cache = {}

-- name: nome do arquivo sem extensão (ex: "planetas" -> assets/data/planetas.json)
function DataLoader.load(name)
    if cache[name] then
        return cache[name]
    end

    local path = DATA_DIR .. name .. ".json"
    local contents, err = love.filesystem.read(path)
    assert(contents, "Arquivo de dados não encontrado: " .. path .. " (" .. tostring(err) .. ")")

    local data, _, decodeErr = json.decode(contents, 1, nil)
    assert(data, "JSON inválido em " .. path .. ": " .. tostring(decodeErr))

    cache[name] = data
    return data
end

-- Carrega vários de uma vez (útil no love.load para falhar cedo)
function DataLoader.preload(names)
    for _, name in ipairs(names) do
        DataLoader.load(name)
    end
end

return DataLoader
