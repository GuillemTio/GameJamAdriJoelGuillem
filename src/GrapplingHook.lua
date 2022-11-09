Actor = Actor or require "src/actor"
local GrapplingHook = Actor:extend()
local Vector = Vector or require "src/vector"

function GrapplingHook:new()
    self.x = Player.x + 10
    self.y = Player.y - 10
    self.width = 6
    self.height = 6
    self.xVel = 200
    self.yVel = -200

    self.oldY = nil

    self.collided = false

    self.physics = {}
    self.physics.body = love.physics.newBody(World, self.x, self.y, "dynamic")
    self.physics.body:setFixedRotation(true)
    self.physics.shape = love.physics.newRectangleShape(self.width, self.height)
    self.physics.fixture = love.physics.newFixture(self.physics.body, self.physics.shape)
end

function GrapplingHook:update(dt)
    
    
    if self.collided then
        self:oncollision()
    else
        self:syncPhysics()
    end

    -- que se mueva en direccion (1,-1) CHECK
    -- a la que colisiona con algo, se queda quieto, y el jugador va hacia el gancho MEDIO CHECK
    -- si en x distancia no ha colisionado con nada se destruye y Player.grappleactive = false

end

function GrapplingHook:syncPhysics()
    self.oldY = self.y
    self.x, self.y = self.physics.body:getPosition()
    self.physics.body:setLinearVelocity(self.xVel, self.yVel)
    if self.y < 55  then
        self.xVel = 0
        self.yVel = 0
        self.collided = true
    end
end

function GrapplingHook:oncollision()
    Player.grabbed = true
end

function GrapplingHook:draw()
    love.graphics.rectangle("fill", self.x - self.width / 2, self.y - self.height / 2, self.width, self.height)
end
return GrapplingHook
