local EnemyGoblin = {}
EnemyGoblin.__index = EnemyGoblin
local Player = require("src/Player")

local ActiveEnemies = {}

function EnemyGoblin.removeAll()
   for i, v in ipairs(ActiveEnemies) do
      v.physics.body:destroy()
      v.isDying = true
   end

   ActiveEnemies = {}
end

function EnemyGoblin:new(x, y)
   local instance = setmetatable({}, EnemyGoblin)
   instance.x = x
   instance.y = y
   instance.offsetY = -8
   instance.r = 0

   instance.speed = 0
   instance.xVel = instance.speed

   instance.health = { current = 2, max = 2 }
   instance.damage = 1

   instance.state = "idle"

   instance.isHurt = false
   instance.isDying = false

   instance.animation = { timer = 0, rate = 0.1 }
   instance.animation.run = { total = 8, current = 1, img = EnemyGoblin.runAnim }
   instance.animation.idle = { total = 4, current = 1, img = EnemyGoblin.walkAnim }
   instance.animation.hit = { total = 4, current = 1, img = EnemyGoblin.hitAnim }
   instance.animation.death = { total = 4, current = 1, img = EnemyGoblin.deathAnim }
   instance.animation.draw = instance.animation.run.img[1]

   instance.physics = {}
   instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "dynamic")
   instance.physics.body:setFixedRotation(true)
   instance.physics.shape = love.physics.newRectangleShape(instance.width * 0.07, instance.height * 0.2)
   instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
   instance.physics.body:setMass(25)
   table.insert(ActiveEnemies, instance)
   table.insert(actorList, instance)
end

function EnemyGoblin.loadAssets()
   EnemyGoblin.runAnim = {}
   for i = 1, 8 do
      EnemyGoblin.runAnim[i] = love.graphics.newImage("src/textures/Monsters_Creatures_Fantasy/Goblin/goblinRun/tile00"
         .. i .. ".png")
   end

   EnemyGoblin.walkAnim = {}
   for i = 1, 4 do
      EnemyGoblin.walkAnim[i] = love.graphics.newImage("src/textures/Monsters_Creatures_Fantasy/Goblin/goblinIdle/tile00"
         .. i .. ".png")
   end

   EnemyGoblin.hitAnim = {}
   for i = 1, 4 do
      EnemyGoblin.hitAnim[i] = love.graphics.newImage("src/textures/Monsters_Creatures_Fantasy/Goblin/goblinHit/tile00"
         .. i .. ".png")
   end

   EnemyGoblin.deathAnim = {}
   for i = 1, 4 do
      EnemyGoblin.deathAnim[i] = love.graphics.newImage("src/textures/Monsters_Creatures_Fantasy/Goblin/goblinDeath/tile00"
         .. i .. ".png")
   end

   EnemyGoblin.width = EnemyGoblin.runAnim[1]:getWidth()
   EnemyGoblin.height = EnemyGoblin.runAnim[1]:getHeight()
end

function EnemyGoblin:takeDamage(amount, goblinActor)
   if goblinActor.health.current - amount > 0 then
      goblinActor.health.current = goblinActor.health.current - amount
      if goblinActor.xVel < 0 then
         goblinActor.xVel = goblinActor.xVel + 150
      else
         goblinActor.xVel = goblinActor.xVel - 150
      end
      goblinActor.isHurt = true
   else
      goblinActor.health.current = 0
      goblinActor:die(goblinActor)
      
   end

   print(goblinActor.health.current)
end

function EnemyGoblin:die(goblinActor)

   if not goblinActor.isDying then
      goblinActor.physics.body:destroy()
   end
   goblinActor.isDying = true
   print("goblin died")
end

function EnemyGoblin:dying(instance)
   self.state = "death"
   if self.animation.draw == self.animation.death.img[4] then
      for i, v in ipairs(ActiveEnemies) do
         if (v == instance) then
            table.remove(ActiveEnemies, i)
         end
      end
   end
end

function EnemyGoblin:update(dt, instance)
      self:animate(dt)
   if not self.isDying then
      self:syncPhysics()
      self:playerDetected()
   else
      self:dying(instance)
   end
end

function EnemyGoblin:playerDetected()
   if self.isHurt then
      self.state = "hit"
      if self.animation.draw == self.animation.hit.img[4] then
         self.isHurt = false
      end
   elseif math.max(self.x - Player.x, -(self.x - Player.x)) < 100 then
      self.state = "run"
      if self.x - Player.x > 5 then
         self.xVel = -65
      elseif self.x - Player.x < -5 then
         self.xVel = 65
      end
   else
      self.state = "idle"
      self.xVel = 0
   end
end

function EnemyGoblin:flipDirection()
   self.xVel = -self.xVel
end

function EnemyGoblin:animate(dt)
   self.animation.timer = self.animation.timer + dt
   if self.animation.timer > self.animation.rate then
      self.animation.timer = 0
      self:setNewFrame()
   end
end

function EnemyGoblin:setNewFrame()
   local anim = self.animation[self.state]
   if anim.current < anim.total then
      anim.current = anim.current + 1
   else
      anim.current = 1
   end
   self.animation.draw = anim.img[anim.current]
end

function EnemyGoblin:syncPhysics()
   self.x, self.y = self.physics.body:getPosition()
   self.physics.body:setLinearVelocity(self.xVel, 100)
end

function EnemyGoblin:draw()
   local scaleX = 1
   if self.xVel < 0 then
      scaleX = -1
   end
   love.graphics.draw(self.animation.draw, self.x, self.y + self.offsetY, self.r, scaleX, 1, self.width / 2,
      self.height / 2)
end

function EnemyGoblin.updateAll(dt)
   for i, instance in ipairs(ActiveEnemies) do
      instance:update(dt, instance)
   end
end

function EnemyGoblin.drawAll()
   for i, instance in ipairs(ActiveEnemies) do
      instance:draw()
   end
end

function EnemyGoblin.beginContact(a, b, collision)
   for i, instance in ipairs(ActiveEnemies) do
      if a == instance.physics.fixture or b == instance.physics.fixture then
         if a == Player.physics.fixture or b == Player.physics.fixture then
            Player:takeDamage(instance.damage)
         end
      end
   end
end

return EnemyGoblin
