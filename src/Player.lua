Actor = Actor or require "src/actor"
local Player = Actor:extend()
local Vector = Vector or require "src/vector"
--local GrapplingHook = GrapplingHook or require "src/GrapplingHook"

Player = {} -- Joel(07/11): no se si esto serà lo que da el problema / Joel(07/11): esta solucionado pero el tio lo tiene puesto

function Player:new()
   --Player.super.new(self,"src/textures/PackNinja/IndividualSprites/adventurer-idle-00.png",400,500,20,1,0)
   self.image = "src/textures/PackNinja/IndividualSprites/adventurer-idle-00.png"
   self.x = 100
   self.y = 0
   self.width = 50
   self.height = 37
   self.xVel = 0
   self.yVel = 100
   self.maxSpeed = 200
   self.acceleration = 3500
   self.friction = 3000
   self.gravity = 1500
   self.jumpAmount = -500

   self.graceTime = 0 
   self.graceDuration = 0.1

   self.grappleactive = false
   self.grabbed = false
   self.direction = "right"
   self.state = "idle"
   self.grounded = false

   self:loadAssets {}

   self.physics = {}
   self.physics.body = love.physics.newBody(World, self.x, self.y, "dynamic")
   self.physics.body:setFixedRotation(true)
   self.physics.shape = love.physics.newRectangleShape(self.width / 2, self.height)
   self.physics.fixture = love.physics.newFixture(self.physics.body, self.physics.shape)
end

function Player:update(dt)
   --Player.super.update(self,dt)
   self:setState()
   self:setDirection()
   self:decreaseGraceTime(dt)
   self:animate(dt)
   self:syncPhysics()
   self:grapplinghook(dt)

   if not self.grabbed then
      self:move(dt)
      --self:applyGravity(dt)
   else
      self:movetograpple()
   end
   self:applyGravity(dt)

end

function Player:setState()
   if not self.grounded and not self.grabbed then
      self.state = "air"
   elseif self.xVel == 0 then
      self.state = "idle"
   elseif self.grabbed then
      self.state = "grapple"
   else
      self.state = "run"
   end
end

function Player:setDirection()
   if self.xVel <0 then
      self.direction = "left"
   elseif self.xVel>0 then
      self.direction = "right"
   end
end

function Player:animate(dt)
   self.animation.timer = self.animation.timer + dt
   if self.animation.timer > self.animation.rate then
      self.animation.timer = 0
      self:setNewFrame()
   end
end

function Player:decreaseGraceTime(dt)
   if not self.grounded then
      self.graceTime = self.graceTime - dt
   end
end

function Player:setNewFrame()
   local anim = self.animation[self.state]
   if anim.current < anim.total then
      anim.current = anim.current + 1
   else
      anim.current = 1
   end
   self.animation.draw = anim.img[anim.current]
end

function Player:loadAssets()
   self.animation = { timer = 0, rate = 0.1 }
   self.animation.run = { total = 6, current = 1, img = {} }
   for i = 1, self.animation.run.total do
      self.animation.run.img[i] = love.graphics.newImage("src/textures/PackNinja/IndividualSprites/Run/" .. i .. ".png")
   end

   self.animation.idle = { total = 4, current = 1, img = {} }
   for i = 1, self.animation.idle.total do
      self.animation.idle.img[i] = love.graphics.newImage("src/textures/PackNinja/IndividualSprites/Idle/" .. i ..".png")
   end

   self.animation.air = { total = 2, current = 1, img = {} }
   for i = 1, self.animation.air.total do
      self.animation.air.img[i] = love.graphics.newImage("src/textures/PackNinja/IndividualSprites/Jump/" .. i ..".png")
   end

   
   self.animation.grapple = { total = 2, current = 1, img = {} }
   for i = 1, self.animation.air.total do
      self.animation.grapple.img[i] = love.graphics.newImage("src/textures/PackNinja/IndividualSprites/Grapple/" .. i ..".png")
   end

   self.animation.attack = { total = 4, current = 1, img = {} }
   for i = 1, self.animation.air.total do
      self.animation.attack.img[i] = love.graphics.newImage("src/textures/PackNinja/IndividualSprites/Attack/" .. i ..".png")
   end

   self.animation.draw = self.animation.idle.img[1]
   self.animation.width = self.animation.draw:getWidth()
   self.animation.height = self.animation.draw:getHeight()


end

function Player:applyGravity(dt)
   if not self.grounded then
      self.yVel = self.yVel + self.gravity * dt
   end
end

function Player:move(dt)
   if love.keyboard.isDown("d", "right") then
      if self.xVel < self.maxSpeed then
         if self.xVel + self.acceleration * dt < self.maxSpeed then
            self.xVel = self.xVel + self.acceleration * dt
         else
            self.xVel = self.maxSpeed
         end
      end
   elseif love.keyboard.isDown("a", "left") then
      if self.xVel > -self.maxSpeed then
         if self.xVel - self.acceleration * dt > -self.maxSpeed then
            self.xVel = self.xVel - self.acceleration * dt
         else
            self.xVel = -self.maxSpeed
         end
      end
   else
      self:applyFriction(dt)
   end
end

function Player:applyFriction(dt)
   if self.xVel > 0 then
      if self.xVel - self.friction * dt > 0 then
         self.xVel = self.xVel - self.friction * dt
      else
         self.xVel = 0
      end
   elseif self.xVel < 0 then
      if self.xVel + self.friction * dt < 0 then
         self.xVel = self.xVel + self.friction * dt
      else
         self.xVel = 0
      end
   end
end

function Player:syncPhysics()
   self.x, self.y = self.physics.body:getPosition()
   self.physics.body:setLinearVelocity(self.xVel, self.yVel)
end

function Player:movetograpple()
   local direction = Vector.new(GrapplingHook.x - self.x, GrapplingHook.y - self.y)
   direction:normalize()

   self.xVel, self.yVel = direction.x * 350, direction.y * 350
end

function Player:beginContact(a, b, collision)
   if self.grounded == true then return end
   local nx, ny = collision:getNormal()
   if a == self.physics.fixture then
      if ny > 0 then
         self:land(collision)
      end
   elseif b == self.physics.fixture then
      if ny < 0 then
         self:land(collision)
      end
   end
end

function Player:land(collision)
   self.currentGroundCollision = collision
   self.yVel = 0
   self.grounded = true
   self.graceTime = self.graceDuration
end

function Player:jump(key)
   if (key == "w") then
      if self.graceTime>0 or self.grounded then
         self.yVel = self.jumpAmount
         self.grounded = false
         self.graceTime = 0 
      end
   end
end

function Player:grapplinghookkey(key)
   local g
   if (key == "e") and not self.grappleactive then
      self.grappleactive = true
      g = GrapplingHook:new()
      table.insert(actorList, g)

   elseif (key == "e") and self.grappleactive then
      self.grappleactive = false
      if self.grabbed then
         self.grabbed = false
         self.grounded = false
      end

      table.remove(actorList, g)
   end
   -- si le vuelvo a dar se cancela CHECK
end

function Player:attack(dt)
-- ANIMACION
--if then

--end
end

function Player:grapplinghook(dt)
   if self.grappleactive then
      GrapplingHook:update(dt)
   end
end

function Player:endContact(a, b, collision)
   if a == self.physics.fixture or b == self.physics.fixture then
      if self.currentGroundCollision == collision then
         self.grounded = false
      end
   end
end

function Player:draw()
   --local xx = self.position.x
   --local ox = self.origin.x
   --local yy = self.position.y
   --local oy = self.origin.y
   --local sx = self.scale.x/15
   --local sy = self.scale.y/15
   --local rr = self.rot

   --love.graphics.draw(self.image,xx,yy,rr,sx,sy,ox,oy,0,0)

   --love.graphics.rectangle("fill", self.x - self.width / 2, self.y - self.height / 2, self.width, self.height)

   local scaleX = 1
   if self.direction == "left" then
      scaleX = -1
   end
   love.graphics.draw(self.animation.draw, self.x, self.y, 0, scaleX, 1, self.animation.width / 2, self.animation.height / 2)

   if self.grappleactive then
      GrapplingHook:draw()
   end
end

return Player
