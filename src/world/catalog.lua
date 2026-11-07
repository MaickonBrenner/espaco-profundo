-- Catálogo de tipos de corpos celestes, montado a partir de planetas.json e asteroides.json.
-- Quem precisar saber "como é um planeta MARTE" (gerador, scanner...) consulta aqui.
local DataLoader = require("src.core.data_loader")

local Catalog = {}

Catalog.planetas = DataLoader.load("planetas")
Catalog.asteroides = DataLoader.load("asteroides")

Catalog.planetas.fixos = Catalog.planetas.fixos or {}

local porNome = {}

-- Tipos de planeta que podem ser sorteados (categoria "planeta" e peso > 0).
-- Tipos com peso 0 (PLANETOIDE, ESTRELA) só aparecem como corpos fixos.
Catalog.planetasSorteaveis = {}

for _, def in ipairs(Catalog.planetas.tipos) do
    porNome[def.tipo] = def
    if def.categoria == "planeta" and (def.peso or 0) > 0 then
        table.insert(Catalog.planetasSorteaveis, def)
    end
end

for _, def in ipairs(Catalog.asteroides.tipos) do
    porNome[def.tipo] = def
end

assert(#Catalog.planetasSorteaveis > 0, "planetas.json precisa ter ao menos um tipo de planeta com peso > 0")

function Catalog.getTipo(nome)
    return porNome[nome]
end

-- Paleta usada pelo Scanner para pintar a superfície
function Catalog.getSuperficie(nome)
    local def = porNome[nome]
    return def and def.superficie
end

return Catalog
