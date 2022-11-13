local BossMushroom = {}
BossMushroom.__index = BossMushroom
local Player = require("src/Player")

local ActiveBoss = {}

function BossMushroom.removeAll()
   for i, v in ipairs(ActiveBoss) do
      v.physics.body:destroy()
      v.isDying = true
   end

   ActiveBoss = {}
end

function BossMushroom:new(x, y)
   local instance = setmetatable({}, BossMushroom)
   instance.x = x
   instance.y = y
   instance.offsetY = -25
   instance.r = 0

   instance.speed = 100
   instance.speedMod = 1
   instance.xVel = instance.speed

   instance.rageCounter = 0
   instance.rageTrigger = 3

   instance.health = { current = 5, max = 5 }
   instance.damage = 1

   instance.state = "run"

   instance.turned = false
   instance.isHurt = false
   instance.isDying = false

   instance.animation = { timer = 0, rate = 0.1 }
   instance.animation.run = { total = 8, current = 1, img = BossMushroom.runAnim }
   instance.animation.idle = { total = 4, current = 1, img = BossMushroom.idleAnim }
   instance.animation.hit = { total = 4, current = 1, img = BossMushroom.hitAnim }
   instance.animation.death = { total = 4, current = 1, img = BossMushroom.deathAnim }
   instance.animation.draw = instance.animation.run.img[1]

   instance.physics = {}
   instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "dynamic")
   instance.physics.body:setFixedRotation(true)
   instance.physics.shape = love.physics.newRectangleShape(instance.width * 0.25, instance.height * 0.5)
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
      mushroomActor.isHurt = true
   else
      mushroomActor.health.current = 0
      mushroomActor:die(mushroomActor)
   end

   print(mushroomActor.health.current)
end

function BossMushroom:die(mushroomActor)
    if not mushroomActor.isDying then
        mushroomActor.physics.body:destroy()
     end
     mushroomActor.isDying = true
   print("goblin died")
end

function BossMushroom:dying(instance)
   self.state = "death"
   if self.animation.draw == self.animation.death.img[4] then
      for i, v in ipairs(ActiveBoss) do
         if (v == instance) then
            table.remove(ActiveBoss, i)
            gameWon = true
            gameStarted = false
            backgroundMusic:stop()
            love.load()
         end
      end
   end
end

function BossMushroom:update(dt, instance)
      self:animate(dt)
   if not self.isDying then
      self:syncPhysics()
      if self.isHurt then
         self.state = "hit"
         if self.animation.draw == self.animation.hit.img[4] then
            self.isHurt = false
            self.state = "run"
         end
      end
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

function BossMushroom:flipDirection(turnRight)
   if turnRight then
      if self.xVel<0 then
         print("girar")
      self.xVel = -self.xVel
      end

   else
      if self.xVel>0 then
         self.xVel = -self.xVel
      end
   end
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
   love.graphics.draw(self.animation.draw, self.x, self.y + self.offsetY, self.r, scaleX * 2.5, 2.5, self.width / 2,
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
   local nx, ny = collision:getNormal()
   for i, instance in ipairs(ActiveBoss) do
      
      if a == instance.physics.fixture then
         if nx > 0 then
            
         elseif nx < 0 then
         
         end
      elseif b == instance.physics.fixture then
         if a == Player.physics.fixture then
            Player:takeDamage(instance.damage)
         
         elseif nx < 0 then
            print("klk")
            instance:flipDirection(false)
            instance:incrementRage()
         elseif nx > 0 then
            print("nx>0")
            instance:flipDirection(true)
            instance:incrementRage()
         end
      end
      --if a == instance.physics.fixture or b == instance.physics.fixture then
      --  print("klk")
      --   if a == Player.physics.fixture or b == Player.physics.fixture then
      --      Player:takeDamage(instance.damage)
      --   end
      --   instance:flipDirection()
      --   instance:incrementRage()
      --end
   end
end

return BossMushroom
