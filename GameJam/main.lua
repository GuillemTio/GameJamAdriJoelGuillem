Asteroid = Asteroid or require "src/Asteroid"
Ship = Ship or require "src/Ship"

actorList = {}  --Lista de elementos de juego

function love.load()
  local s = Ship()
  table.insert(actorList,s)
  local a = Asteroid()
  table.insert(actorList,a)
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
    if v:is(Ship) then
      v:keyPressed(key)
    end
  end
end
