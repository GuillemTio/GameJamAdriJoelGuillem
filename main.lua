Player = Player or require "src/Player"

actorList = {}  --Lista de elementos de juego

function love.load()
local p = Player()
table.insert(actorList,p)
end

function love.update(dt)
  for _,v in ipairs(actorList) do
    v:update(dt)
  end
end

function love.draw()
  for _,v in ipairs(actorList) do
    v:draw()
  end
end

function love.keypressed(key)
  for _,v in ipairs(actorList) do
    
  end
end
