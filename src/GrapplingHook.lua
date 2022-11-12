Actor = Actor or require "src/actor"
local GrapplingHook = Actor:extend()
local Vector = Vector or require "src/vector"

function GrapplingHook:new()
    self.image = love.graphics.newImage("src/textures/gancho.png")
    self.x = Player.x + 10
    self.y = Player.y - 10
    self.width = 8
    self.height = 8
    self.xVel = 250
    self.yVel = -250

    self.firstY = self.y
    self.currentYDistance = 0
    self.maxYDistanceToGrab = 180
    self.distanceToLetGo = 50

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
        self:checkdistancefromplayer(true)
    else
        self:syncPhysics()
        self:checkdistancefromplayer(false)
    end

    -- que se mueva en direccion (1,-1) CHECK
    -- a la que colisiona con algo, se queda quieto, y el jugador va hacia el gancho CHECK
    -- si en x distancia no ha colisionado con nada se destruye y Player.grappleactive = false CHECK

end

function GrapplingHook:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
    self.physics.body:setLinearVelocity(self.xVel, self.yVel)
end

function GrapplingHook:checkdistancefromplayer(playeriscoming)
    if playeriscoming then
        local actualDistanceFromPlayer = math.sqrt(((self.x - Player.x) ^ 2) + ((-(self.y - Player.y)) ^ 2))
        if actualDistanceFromPlayer < self.distanceToLetGo then
            Player.grappleactive = false
            Player.grabbed = false
            Player.grounded = false
            for _, v in ipairs(actorList) do
                if v == self then
                    table.remove(actorList, v)
                end
            end
        end
    else
        if self.currentYDistance < self.maxYDistanceToGrab then
            self.currentYDistance = -(self.y - self.firstY)
        else
            Player.grappleactive = false
            for _, v in ipairs(actorList) do
                if v == self then
                    table.remove(actorList, v)
                end
            end
        end
    end
end

function GrapplingHook:beginContact(a, b, collision)
    self.xVel = 0
    self.yVel = 0
    self.collided = true
end

function GrapplingHook:oncollision()
    Player.grabbed = true
end

function GrapplingHook:draw()
    love.graphics.draw(self.image,self.x,self.y,0,1.5,1.5,self.width/2,self.height/2)
    --love.graphics.rectangle("fill", self.x - self.width / 2, self.y - self.height / 2, self.width, self.height)
    love.graphics.line(Player.x, Player.y, self.x, self.y)
end

return GrapplingHook
