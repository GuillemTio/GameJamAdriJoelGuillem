Player = Player or require "src/Player"
GrapplingHook = GrapplingHook or require "src/GrapplingHook"

actorList = {} --Lista de elementos de juego

local STI = require("src/sti")
love.graphics.setDefaultFilter("nearest", "nearest")

function love.load()
  Map = STI("src/map/Map1.lua", { "box2d" })
  World = love.physics.newWorld(0, 0) -- takes x and y velocity for the World, for example to create gravity
  World:setCallbacks(beginContact, endContact)
  Map:box2d_init(World)
  Map.layers.solid.visible = false -- colliders non visible
  --background = love.graphics.newImage("textures/background") -- this is for our future background

  Player:new()
  --local p = Player()
  --table.insert(actorList,p)
end

function love.update(dt)
  --for _,v in ipairs(actorList) do
  --v:update(dt)
  --end
  World:update(dt)
  Player:update(dt)
end

function love.draw()
  --for _,v in ipairs(actorList) do
  --v:draw()
  --end

  --love.graphics.draw(background) -- this is for our future background, it should be always before the map
  Map:draw(0, 0, 2, 2)

  -- anything drawn before the push and after the pop will be not affected by the scaling sti
  love.graphics.push() -- save the current transformations (positions, rotation, sacle....) to the stack
  love.graphics.scale(2, 2)

  Player:draw()

  love.graphics.pop() -- retrieves the information from the stack and resets everything to this state

end

function love.keypressed(key)
  --for _,v in ipairs(actorList) do

  --end
  Player:jump(key)
  Player:grapplinghookkey(key)
end

function beginContact(a, b, collision)
  if a == Player.physics.fixture or b == Player.physics.fixture then
    Player:beginContact(a, b, collision)

  elseif a == GrapplingHook.physics.fixture or b == GrapplingHook.physics.fixture then
    GrapplingHook:beginContact(a, b, collision)
  end
end

function endContact(a, b, collision)
  Player:endContact(a, b, collision)
end
