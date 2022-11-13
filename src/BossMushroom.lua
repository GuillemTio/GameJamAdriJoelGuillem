local BossMushroom = {}
BossMushroom.__index = BossMushroom
local Player = require("src/Player")

local ActiveBoss = {}

function BossMushroom.removeAll()
   for i, v in ipairs(ActiveBoss) do
      v.physics.body:destroy()
   end

   ActiveBoss = {}
end

function BossMushroom:new(x, y)
   local instance = setmetatable({}, BossMushroom)
   instance.x = x
   instance.y = y
   instance.offsetY = -8
   instance.r = 0

   instance.speed = 100
   instance.speedMod = 1
   instance.xVel = instance.speed

   instance.rageCounter = 0
   instance.rageTrigger = 3

   instance.health = { current = 2, max = 2 }
   instance.damage = 1

   instance.state = "idle"

   instance.isHurt = false
   instance.isDying = false

   instance.animation = { timer = 0, rate = 0.1 }
   instance.animation.run = { total = 4, current = 1, img = BossMushroom.runAnim }
   instance.animation.idle = { total = 4, current = 1, img = BossMushroom.idleAnim }
   instance.animation.hit = { total = 4, current = 1, img = BossMushroom.hitAnim }
   instance.animation.death = { total = 4, current = 1, img = BossMushroom.deathAnim }
   instance.animation.draw = instance.animation.run.img[1]

   instance.physics = {}
   instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "dynamic")
   instance.physics.body:setFixedRotation(true)
   instance.physics.shape = love.physics.newRectangleShape(instance.width * 0.1, instance.height * 0.2)
   instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
   instance.physics.body:setMass(25)
   table.insert(ActiveBoss, instance)
   table.insert(actorList, instance)
end

function BossMushroom.loadAssets()
   BossMushroom.runAnim = {}
   for i = 1, 8 do
      BossMushroom.runAnim[i] = love.graphics.newImage("src/textures/Monsters_Creatures_Fantasy/Mushroom/MushroomRun/tile00"
         .. i .. ".png")
   end

   BossMushroom.idleAnim = {}
   for i = 1, 4 do
      BossMushroom.idleAnim[i] = love.graphics.newImage("src/textures/Monsters_Creatures_Fantasy/Mushroom/MushroomIdle/tile00"
         .. i .. ".png")
   end

   BossMushroom.hitAnim = {}
   for i = 1, 4 do
      BossMushroom.hitAnim[i] = love.graphics.newImage("src/textures/Monsters_Creatures_Fantasy/Mushroom/MushroomHit/tile00"
         .. i .. ".png")
   end

   BossMushroom.deathAnim = {}
   for i = 1, 4 do
      BossMushroom.deathAnim[i] = love.graphics.newImage("src/textures/Monsters_Creatures_Fantasy/Mushroom/MushroomDeath/tile00"
         .. i .. ".png")
   end

   BossMushroom.width = BossMushroom.idleAnim[1]:getWidth()
   BossMushroom.height = BossMushroom.idleAnim[1]:getHeight()
end

function BossMushroom:takeDamage(amount, mushroomActor)
   if mushroomActor.health.current - amount > 0 then
      mushroomActor.health.current = mushroomActor.health.current - amount
      if mushroomActor.xVel < 0 then
         mushroomActor.xVel = mushroomActor.xVel + 150
      else
         mushroomActor.xVel = mushroomActor.xVel - 150
      end
      mushroomActor.isHurt = true
   else
      mushroomActor.health.current = 0
      mushroomActor:die(mushroomActor)
   end

   print(mushroomActor.health.current)
end

function BossMushroom:die(mushroomActor)
   mushroomActor.isDying = true
   if not mushroomActor.physics.body == nil then
      mushroomActor.physics.body:destroy()
   end
   print("goblin died")
end

function BossMushroom:dying(instance)
   self.state = "death"
   if self.animation.draw == self.animation.death.img[4] then
      for i, v in ipairs(ActiveBoss) do
         if (v == instance) then
            table.remove(ActiveBoss, i)
         end
      end
   end
end

function BossMushroom:update(dt, instance)
      self:animate(dt)
   if not self.isDying then
      self:syncPhysics()
      self:playerDetected()
   else
      self:dying(instance)
   end
end

function BossMushroom:incrementRage()
   self.rageCounter = self.rageCounter + 1
   if self.rageCounter > self.rageTrigger then
      self.state = "run"
      self.speedMod = 3
      self.rageCounter = 0
   else
      self.state = "run"
      self.speedMod = 1
   end
end


function BossMushroom:playerDetected()
   if self.isHurt then
      self.state = "hit"
      if self.animation.draw == self.animation.hit.img[4] then
         self.isHurt = false
      end
   elseif math.max(self.x - Player.x, -(self.x - Player.x)) < 100 then
      self.state = "run"
      if self.x - Player.x > 0 then
         self.xVel = -65
      elseif self.x - Player.x < 0 then
         self.xVel = 65
      end
   else
      self.state = "idle"
      self.xVel = 0
   end
end

function BossMushroom:flipDirection()
   self.xVel = -self.xVel
end

function BossMushroom:animate(dt)
   self.animation.timer = self.animation.timer + dt
   if self.animation.timer > self.animation.rate then
      self.animation.timer = 0
      self:setNewFrame()
   end
end

function BossMushroom:setNewFrame()
   local anim = self.animation[self.state]
   if anim.current < anim.total then
      anim.current = anim.current + 1
   else
      anim.current = 1
   end
   self.animation.draw = anim.img[anim.current]
end

function BossMushroom:syncPhysics()
   self.x, self.y = self.physics.body:getPosition()
   self.physics.body:setLinearVelocity(self.xVel * self.speedMod , 100)
end

function BossMushroom:draw()
   local scaleX = 1
   if self.xVel < 0 then
      scaleX = -1
   end
   love.graphics.draw(self.animation.draw, self.x, self.y + self.offsetY, self.r, scaleX, 1, self.width / 2,
      self.height / 2)
end

function BossMushroom.updateAll(dt)
   for i, instance in ipairs(ActiveBoss) do
      instance:update(dt, instance)
   end
end

function BossMushroom.drawAll()
   for i, instance in ipairs(ActiveBoss) do
      instance:draw()
   end
end

function BossMushroom.beginContact(a, b, collision)
   for i, instance in ipairs(ActiveBoss) do
      if a == instance.physics.fixture or b == instance.physics.fixture then
         if a == Player.physics.fixture or b == Player.physics.fixture then
            Player:takeDamage(instance.damage)
         end
         instance:incrementRage()
      end
   end
end

return BossMushroom
