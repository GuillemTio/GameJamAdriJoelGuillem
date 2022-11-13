local EnemyEyes = {}
EnemyEyes.__index = EnemyEyes
local Player = require("src/Player")

local ActiveFlyingEnemies = {}

function EnemyEyes.removeAll()
   for i,v in ipairs(ActiveFlyingEnemies) do
      v.physics.body:destroy()
      v.isDying = true
   end

   ActiveFlyingEnemies = {}
end

function EnemyEyes:new(x,y)
   local instance = setmetatable({}, EnemyEyes)
   instance.x = x
   instance.y = y
   instance.offsetY = -8
   instance.r = 0

   instance.speed = 0
   instance.xVel = instance.speed
   instance.yVel = instance.speed

   instance.health = { current = 2, max = 2 }
   instance.damage = 1

   instance.state = "fly"

   instance.isHurt = false
   instance.isDying = false

   instance.animation = {timer = 0, rate = 0.1}
   instance.animation.fly = {total = 8, current = 1, img = EnemyEyes.flyAnim}
   instance.animation.hit = { total = 4, current = 1, img = EnemyEyes.hitAnim }
   instance.animation.death = { total = 4, current = 1, img = EnemyEyes.deathAnim }
   instance.animation.draw = instance.animation.fly.img[1]

   instance.physics = {}
   instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "dynamic")
   instance.physics.body:setFixedRotation(true)
   instance.physics.shape = love.physics.newRectangleShape(instance.width * 0.07, instance.height * 0.04)
   instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)

   table.insert(ActiveFlyingEnemies, instance)
   table.insert(actorList, instance)
end

function EnemyEyes.loadAssets()
    EnemyEyes.flyAnim = {}
   for i=1,8 do
    EnemyEyes.flyAnim[i] = love.graphics.newImage("src/textures/Monsters_Creatures_Fantasy/Flying_eye/eyeFlying/tile00"..i..".png")
   end

   EnemyEyes.hitAnim = {}
   for i = 1, 4 do
      EnemyEyes.hitAnim[i] = love.graphics.newImage("src/textures/Monsters_Creatures_Fantasy/Flying_eye/eyeHit/tile00".. i .. ".png")
   end

   EnemyEyes.deathAnim = {}
   for i = 1, 4 do
      EnemyEyes.deathAnim[i] = love.graphics.newImage("src/textures/Monsters_Creatures_Fantasy/Flying_eye/eyeDie/tile00".. i .. ".png")
   end

   EnemyEyes.width = EnemyEyes.flyAnim[1]:getWidth()
   EnemyEyes.height = EnemyEyes.flyAnim[1]:getHeight()
end

function EnemyEyes:takeDamage(amount, eyeActor)
   if eyeActor.health.current - amount > 0 then
      eyeActor.health.current = eyeActor.health.current - amount
      if eyeActor.xVel < 0 then
         eyeActor.xVel = eyeActor.xVel + 250
      else
         eyeActor.xVel = eyeActor.xVel - 250
      end
      eyeActor.isHurt = true
   else
      eyeActor.health.current = 0
      eyeActor:die(eyeActor)
   end

   print(eyeActor.health.current)
end

function EnemyEyes:die(eyeActor)
   if not eyeActor.isDying then
      eyeActor.physics.body:destroy()
   end
   eyeActor.isDying = true
   print("goblin died")
end

function EnemyEyes:dying(instance)
   self.state = "death"
   if self.animation.draw == self.animation.death.img[4] then
      for i, v in ipairs(ActiveFlyingEnemies) do
         if (v == instance) then
            table.remove(ActiveFlyingEnemies, i)
         end
      end
   end
end

function EnemyEyes:update(dt, instance)
   self:animate(dt)
   if not self.isDying then
      self:syncPhysics()
      self:playerDetected()
   else
      self:dying(instance)
   end
end

function EnemyEyes:playerDetected()
   if self.isHurt then
      self.state = "hit"
      if self.animation.draw == self.animation.hit.img[4] then
         self.isHurt = false
      end
   elseif math.max(self.x - Player.x, - (self.x - Player.x)) < 200 then
      self.state = "fly"
      if self.x - Player.x > 0 then
        self.xVel = - 65
      elseif self.x - Player.x < 0 then
        self.xVel = 65
      end
      if self.y - Player.y > -5 then
        self.yVel = - 65
      elseif self.y -Player.y < -5 then
        self.yVel = 65
      end
   else
      self.state = "fly"
      self.xVel = 0
      self.yVel = 0
   end
end

function EnemyEyes:flipDirection()
   self.xVel = -self.xVel
end

function EnemyEyes:animate(dt)
   self.animation.timer = self.animation.timer + dt
   if self.animation.timer > self.animation.rate then
      self.animation.timer = 0
      self:setNewFrame()
   end
end

function EnemyEyes:setNewFrame()
   local anim = self.animation[self.state]
   if anim.current < anim.total then
      anim.current = anim.current + 1
   else
      anim.current = 1
   end
   self.animation.draw = anim.img[anim.current]
end

function EnemyEyes:syncPhysics()
   self.x, self.y = self.physics.body:getPosition()
   self.physics.body:setLinearVelocity(self.xVel, self.yVel)
end

function EnemyEyes:draw()
   local scaleX = 1
   if self.xVel < 0 then
      scaleX = -1
   end
   love.graphics.draw(self.animation.draw, self.x, self.y + self.offsetY, self.r, scaleX, 1, self.width / 2, self.height / 2)
end

function EnemyEyes.updateAll(dt)
   for i,instance in ipairs(ActiveFlyingEnemies) do
      instance:update(dt, instance)
   end
end

function EnemyEyes.drawAll()
   for i,instance in ipairs(ActiveFlyingEnemies) do
      instance:draw()
   end
end

function EnemyEyes.beginContact(a, b, collision)
   for i,instance in ipairs(ActiveFlyingEnemies) do
      if a == instance.physics.fixture or b == instance.physics.fixture then
         if a == Player.physics.fixture or b == Player.physics.fixture then
            Player:takeDamage(instance.damage)
         end
      end
   end
end

return EnemyEyes