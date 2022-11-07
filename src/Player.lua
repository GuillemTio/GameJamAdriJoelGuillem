Actor = Actor or require "src/actor"
local Player = Actor:extend()
local Vector = Vector or require"src/vector"

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

    self.grounded = false
    
    self.physics = {}
    self.physics.body = love.physics.newBody(World, self.x, self.y, "dynamic")
    self.physics.body:setFixedRotation(true)
    self.physics.shape = love.physics.newRectangleShape(self.width,self.height) 
    self.physics.fixture = love.physics.newFixture(self.physics.body, self.physics.shape)
end

function Player:update(dt)
    --Player.super.update(self,dt)
    self:syncPhysics()
    self:move(dt)
    self:applyGravity(dt)
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
    self.physics.body:setLinearVelocity(self.xVel,self.yVel)
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
end

function Player:jump(key)
    if (key == "space") and self.grounded then
       self.yVel = self.jumpAmount
       self.grounded = false
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

    love.graphics.rectangle("fill", self.x - self.width / 2, self.y - self.height / 2, self.width, self.height)
end

  return Player