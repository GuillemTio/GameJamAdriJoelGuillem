local EnemyEyes = {}
EnemyEyes.__index = EnemyGoblin
local Player = require("src/Player")

local ActiveEnemies = {}

function EnemyEyes.removeAll()
   for i,v in ipairs(ActiveEnemies) do
      v.physics.body:destroy()
   end

   ActiveEnemies = {}
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

   instance.damage = 1

   instance.state = "fly"

   instance.animation = {timer = 0, rate = 0.1}
   instance.animation.fly = {total = 8, current = 1, img = EnemyEyes.runAnim}
   instance.animation.draw = instance.animation.run.img[1]

   instance.physics = {}
   instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "dynamic")
   instance.physics.body:setFixedRotation(true)
   instance.physics.shape = love.physics.newRectangleShape(instance.width * 0.1, instance.height * 0.2)
   instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
<<<<<<< Updated upstream
   instance.physics.body:setMass(25)
   table.insert(ActiveEnemies, instance)
=======
   --instance.physics.body:setMass(0)
   table.insert(ActiveFlyingEnemies, instance)
>>>>>>> Stashed changes
end

function EnemyEyes.loadAssets()
    EnemyEyes.flyAnim = {}
   for i=0,7 do
    EnemyEyes.flyAnim[i] = love.graphics.newImage("src/textures/Monsters_Creatures_Fantasy/Flyin_eye/eyeFlying/tile00"..i..".png")
   end

   EnemyEyes.width = EnemyEyes.runAnim[1]:getWidth()
   EnemyEyes.height = EnemyEyes.runAnim[1]:getHeight()
end

function EnemyEyes:update(dt)
   self:syncPhysics()
   self:animate(dt)
   self:playerDetected()
end

function EnemyEyes:playerDetected()
   
   if math.max(self.x - Player.x, - (self.x - Player.x)) < 200 then
      self.state = "fly"
      if self.x - Player.x > 0 then
        self.xVel = - 65
      elseif self.x - Player.x < 0 then
        self.xVel = 65
      end
      if self.y - Player.y > 0 then
        self.yVel = - 65
      elseif self.y -Player.y < 0 then
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
   --self.physics.body:setLinearVelocity(0, self.yVel)
end

function EnemyEyes:draw()
   local scaleX = 1
   if self.xVel < 0 then
      scaleX = -1
   end
   love.graphics.draw(self.animation.draw, self.x, self.y + self.offsetY, self.r, scaleX, 1, self.width / 2, self.height / 2)
end

function EnemyEyes.updateAll(dt)
   for i,instance in ipairs(ActiveEnemies) do
      instance:update(dt)
   end
end

function EnemyEyes.drawAll()
   for i,instance in ipairs(ActiveEnemies) do
      instance:draw()
   end
end

function EnemyEyes.beginContact(a, b, collision)
   for i,instance in ipairs(ActiveEnemies) do
      if a == instance.physics.fixture or b == instance.physics.fixture then
         if a == Player.physics.fixture or b == Player.physics.fixture then
            Player:takeDamage(instance.damage)
         end
      end
   end
end

return EnemyEyes