local Camera = {}

function Camera.load()
    Camera.x = 0
    Camera.y = 0
    Camera.scale = 1
    Camera.lag = 5 -- Velocidade com que a câmera segue o player (maior = mais rápido)
end

function Camera.update(dt, targetX, targetY)
    -- Interpolação linear (Lerp) para a câmera deslizar suavemente até o player
    Camera.x = Camera.x + (targetX - Camera.x) * Camera.lag * dt
    Camera.y = Camera.y + (targetY - Camera.y) * Camera.lag * dt
end

function Camera.apply()
    love.graphics.push()
    -- Centraliza a câmera na tela e aplica a translação baseada na posição do alvo
    love.graphics.translate(love.graphics.getWidth() / 2 - Camera.x, love.graphics.getHeight() / 2 - Camera.y)
    love.graphics.scale(Camera.scale, Camera.scale)
end

function Camera.detach()
    love.graphics.pop()
end

return Camera