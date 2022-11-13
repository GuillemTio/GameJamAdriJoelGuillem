local EnemySkeleton = {}
EnemySkeleton.__index = EnemySkeleton
local Player = require("src/Player")

local ActiveSkeletonEnemies = {}

function EnemySkeleton.removeAll()
   for i, v in ipairs(ActiveSkeletonEnemies) do
      v.physics.body:destroy()
      v.isDying = true
   end

   ActiveSkeletonEnemies = {}
end

function EnemySkeleton:new(x, y)
   local instance = setmetatable({}, EnemySkeleton)
   instance.x = x
   instance.y = y
   instance.offsetY = -8
   instance.r = 0

   instance.speed = 0
   instance.xVel = instance.speed

   instance.health = { current = 1, max = 1}
   instance.damage = 1

   instance.state = "idle"

   instance.isHurt = false
   instance.isDying = false

   instance.animation = { timer = 0, rate = 0.1 }
   instance.animation.run = { total = 4, current = 1, img = EnemySkeleton.runAnim }
   instance.animation.idle = { total = 4, current = 1, img = EnemySkeleton.walkAnim }
   instance.animation.hit = { total = 4, current = 1, img = EnemySkeleton.hitAnim }
   instance.animation.death = { total = 4, current = 1, img = EnemySkeleton.deathAnim }
   instance.animation.draw = instance.animation.run.img[1]

   instance.physics = {}
   instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "dynamic")
   instance.physics.body:setFixedRotation(true)
   instance.physics.shape = love.physics.newRectangleShape(instance.width * 0.07, instance.height * 0.2)
   instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
   instance.physics.body:setMass(25)
   table.insert(ActiveSkeletonEnemies, instance)
   table.insert(actorList, instance)
end

function EnemySkeleton.loadAssets()
   EnemySkeleton.runAnim = {}
   for i = 1, 4 do
      EnemySkeleton.runAnim[i] = love.graphics.newImage("src/textures/Monsters_Creatures_Fantasy/Skeleton/skeletonWalk/tile00".. i .. ".png")
   end

   EnemySkeleton.walkAnim = {}
   for i = 1, 4 do
      EnemySkeleton.walkAnim[i] = love.graphics.newImage("src/textures/Monsters_Creatures_Fantasy/Skeleton/skeletonIdle/tile00".. i .. ".png")
   end

   EnemySkeleton.hitAnim = {}
   for i = 1, 4 do
      EnemySkeleton.hitAnim[i] = love.graphics.newImage("src/textures/Monsters_Creatures_Fantasy/Skeleton/skeletonHit/tile00".. i .. ".png")
   end

   EnemySkeleton.deathAnim = {}
   for i = 1, 4 do
      EnemySkeleton.deathAnim[i] = love.graphics.newImage("src/textures/Monsters_Creatures_Fantasy/Skeleton/skeletonDeath/tile00".. i .. ".png")
   end

   EnemySkeleton.width = EnemySkeleton.runAnim[1]:getWidth()
   EnemySkeleton.height = EnemySkeleton.runAnim[1]:getHeight()
end

function EnemySkeleton:takeDamage(amount, skeletonActor)

   skeletonActor.health.current = 0
   skeletonActor:die(skeletonActor)

end

function EnemySkeleton:die(skeletonActor)
   
   if not skeletonActor.isDying then
      skeletonActor.physics.body:destroy()
   end
   skeletonActor.isDying = true
   print("isDying")
end

function EnemySkeleton:dying(instance)
   self.state = "death"
   if self.animation.draw == self.animation.death.img[4] then
      for i, v in ipairs(ActiveSkeletonEnemies) do
         if (v == instance) then
            table.remove(ActiveSkeletonEnemies, i)
         end
      end
   end
end

function EnemySkeleton:update(dt, instance)
      self:animate(dt)
   if not self.isDying then
      self:syncPhysics()
      self:playerDetected()
   else
      self:dying(instance)
   end
end

function EnemySkeleton:playerDetected()
   if self.isHurt then
      self.state = "hit"
      if self.animation.draw == self.animation.hit.img[4] then
         self.isHurt = false
      end
   elseif math.max(self.x - Player.x, -(self.x - Player.x)) < 160 then
      self.state = "run"
      if self.x - Player.x > 0 then
         self.xVel = -120
      elseif self.x - Player.x < 0 then
         self.xVel = 120
      end
   else
      self.state = "idle"
      self.xVel = 0
   end
end

function EnemySkeleton:flipDirection()
   self.xVel = -self.xVel
end

function EnemySkeleton:animate(dt)
   self.animation.timer = self.animation.timer + dt
   if self.animation.timer > self.animation.rate then
      self.animation.timer = 0
      self:setNewFrame()
   end
end

function EnemySkeleton:setNewFrame()
   local anim = self.animation[self.state]
   if anim.current < anim.total then
      anim.current = anim.current + 1
   else
      anim.current = 1
   end
   self.animation.draw = anim.img[anim.current]
end

function EnemySkeleton:syncPhysics()
   self.x, self.y = self.physics.body:getPosition()
   self.physics.body:setLinearVelocity(self.xVel, 100)
end

function EnemySkeleton:draw()
   local scaleX = 1
   if self.xVel < 0 then
      scaleX = -1
   end
   love.graphics.draw(self.animation.draw, self.x, self.y + self.offsetY, self.r, scaleX, 1, self.width / 2, self.height / 2)
end

function EnemySkeleton.updateAll(dt)
   for i, instance in ipairs(ActiveSkeletonEnemies) do
      instance:update(dt, instance)
   end
end

function EnemySkeleton.drawAll()
   for i, instance in ipairs(ActiveSkeletonEnemies) do
      instance:draw()
   end
end

function EnemySkeleton.beginContact(a, b, collision)
   for i, instance in ipairs(ActiveSkeletonEnemies) do
      if a == instance.physics.fixture or b == instance.physics.fixture then
         if a == Player.physics.fixture or b == Player.physics.fixture then
            Player:takeDamage(instance.damage)
         end
      end
   end
end

return EnemySkeleton
