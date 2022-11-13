Player = Player or require "src/Player"
GrapplingHook = GrapplingHook or require "src/GrapplingHook"
Camera = Camera or require"src/Camera"
EnemyGoblin = EnemyGoblin or require"src/EnemyGoblin"
EnemyEyes = EnemyEyes or require"src/EnemyEyes"
EnemySkeleton = EnemySkeleton or require"src/EnemySkeleton"
BossMushroom = BossMushroom or require "src/BossMushroom"
HUD = HUD or require"src/HUD"
StartMenu = StartMenu or require"src/StartMenu"

gameWon = false
gameStarted = false

actorList = {} --Lista de elementos de juego

local STI = require("src/sti")
love.graphics.setDefaultFilter("nearest", "nearest")

function love.load()

  if not gameStarted then
    StartMenu:new()
  else

  backgroundMusic = love.audio.newSource("src/music/BigPoppa.wav","static")
  backgroundMusic:setVolume(0.2)
  backgroundMusic:setLooping(true)
  backgroundMusic:play()

  Map = STI("src/map/Map1.lua", { "box2d" })
  World = love.physics.newWorld(0, 0) -- takes x and y velocity for the World, for example to create gravity
  World:setCallbacks(beginContact, endContact)
  Map:box2d_init(World)
  Map.layers.solid.visible = false -- colliders non visible
  Map.layers.entity.visible = false
  
  MapWidth = Map.layers.ground.width * 24
  background = love.graphics.newImage("src/textures/background/background_layer_1.png") -- this is for our future background
  background2 = love.graphics.newImage("src/textures/background/background_layer_2.png")
  background3 = love.graphics.newImage("src/textures/background/background_layer_3.png")

  EnemyGoblin.loadAssets()
  EnemyEyes.loadAssets()
  EnemySkeleton.loadAssets()
  BossMushroom.loadAssets()

  Player:new()
  HUD:load()

  spawnEntities()
  --local p = Player()
  --table.insert(actorList,p)
  end
end

function love.update(dt)
  --for _,v in ipairs(actorList) do
  --v:update(dt)
  --end

  if not gameStarted then
    StartMenu:update(dt)
  else

  World:update(dt)
  Player:update(dt)
  EnemyGoblin.updateAll(dt)
  EnemyEyes.updateAll(dt)
  EnemySkeleton.updateAll(dt)
  BossMushroom.updateAll(dt)
  Camera:setPosition(Player.x, 0)
  HUD:update(dt)
  end
end

function love.draw()
  --for _,v in ipairs(actorList) do
  --v:draw()
  --end
  if not gameStarted then
    StartMenu:draw()
  else

  love.graphics.draw(background, 0, 0, 0, 5, 5) -- this is for our future background, it should be always before the map
  love.graphics.draw(background2, 0, 0, 0, 5, 5)
  love.graphics.draw(background3, 0, 0, 0, 5, 5)

  Map:draw(-Camera.x, -Camera.y, Camera.scale, Camera.scale)


  Camera:apply()

  Player:draw()
  EnemyGoblin.drawAll()
  EnemyEyes.drawAll()
  EnemySkeleton.drawAll()
  BossMushroom.drawAll()

  Camera:clear()
  HUD:draw()
  end
end

function love.keypressed(key)
  --for _,v in ipairs(actorList) do
  if gameStarted then

    Player:attackkey(key)
    Player:jump(key)
    Player:grapplinghookkey(key)
    Player:godMode(key)
  end
end

function beginContact(a, b, collision)
  if gameStarted then
  EnemyGoblin.beginContact(a, b, collision)
  EnemyEyes.beginContact(a, b, collision)
  EnemySkeleton.beginContact(a, b, collision)
  BossMushroom.beginContact(a, b, collision)
  if a == Player.physics.fixture or b == Player.physics.fixture then
    Player:beginContact(a, b, collision)
  elseif Player.grappleactive then
    if a == GrapplingHook.physics.fixture or b == GrapplingHook.physics.fixture then
      GrapplingHook:beginContact(a, b, collision)
    end
  end
end
end

function endContact(a, b, collision)
  if gameStarted then
  Player:endContact(a, b, collision)
  end
end

function spawnEntities()
  if gameStarted then
  for i,v in ipairs(Map.layers.entity.objects) do
    if v.type == "enemyGoblin" then
      EnemyGoblin:new(v.x + v.width / 2, v.y + v.height / 2)
    end
    if v.type == "enemyEyes" then
      EnemyEyes:new(v.x + v.width / 2, v.y + v.height / 2)
    end
    if v.type == "enemySkeleton" then
      EnemySkeleton:new(v.x + v.width / 2, v.y + v.height / 2)
    end
    if v.type == "bossMushroom" then
      BossMushroom:new(v.x + v.width / 2, v.y + v.height / 2)
    end
  end
end
end
