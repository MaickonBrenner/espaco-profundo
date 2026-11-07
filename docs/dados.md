# Formato dos arquivos de dados (`assets/data/`)

## planetas.json
- `geracao`: `chance` de um setor ter planeta aleatório, `margem` das bordas do setor, `numero` (faixa do sufixo do nome).
- `fixos`: corpos em posição fixa. Para mover, altere `chunk` (setor) e `posicao` (dentro do setor, 0–2048).
  - `tipo` referencia um item de `tipos`; qualquer campo repetido aqui (`raio`, `cor`...) sobrescreve o do tipo.
  - `bloqueiaPlanetas`: se `true`, o setor não recebe planeta aleatório.
  - `seedAltitude` / `seedHumidity`: fixam o visual da superfície no scanner.
  - Limite atual: um corpo da categoria `estrela` por setor.
- `tipos`: cada tipo tem
  - `categoria`: `planeta` ou `estrela`
  - `peso`: chance relativa de aparecer aleatoriamente (0 = só aparece como corpo fixo)
  - `raio`: faixa `[min, max]`; `cor`: cor no espaço/mapa; `alcanceInteracao`: distância extra para o [E]
  - `halo` (só estrela): lista de `{extra, alpha}`
  - `superficie`: paleta do scanner
    - `"modo": "camadas"` → lista de `{ate, cor}`; vale a primeira em que altitude < `ate`; a última, sem `ate`, é o padrão
    - `"modo": "gradiente"` → cinza = `base + altitude * fator`, somado a `tinta` [r,g,b]

## asteroides.json
- `geracao`: `quantidade` por setor (faixa) e `margem`.
- `tipos`: mesma ideia dos planetas, com `velocidade`, `prefixo` e `numero` do nome. Com mais de um tipo, o sorteio usa `peso`.

## naves.json
Lista de naves; `nome` deve ser igual ao `shipModel` do save.
- `aceleracao`, `velocidade_max`, `atrito`, `velocidade_rotacao`
- `tanque` (capacidade) e `coeficiente_de_consumo` (combustível/segundo com o motor ligado)
- `vida`, `escudo`, `armas`
- `raio`: tamanho base; `formato.corpo` e `formato.chama` são listas de polígonos `[[x,y],...]` em múltiplos do `raio`
  (x positivo = frente da nave); `formato.cor` e `formato.corChama` em RGB 0–1.
- Campos omitidos usam valores padrão (ver `src/entities/player.lua`).
