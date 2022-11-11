

local Enemies = {img = love.graphics.newImage("src/textures/Monsters_Creatures_Fantasy/Goblin/Idle.png")}
Enemies._index = Enemies

Enemies.width = Enemies.img:getWidth()
Enemies.height = Enemies.img:getHeight()

local ActiveEnemies = {}

function Enemies:new(x, y)
    local instance = setmetatable({}, Enemies)
    instance.x = x
    instance.y = y
    instance.r = 0

    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "dynamic")
    instance.physics.shape = love.physics.newRectangleShape(instance.width, instance.height)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    instance.physics.body:setMass(25)
    table.insert(ActiveEnemies, instance)
end

function Enemies:update(dt)
    self:syncPhysics()
end

function Enemies:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
    self.r = self.physics.body:getAngle()
end

function Enemies:draw()
    love.graphics.draw(self.img, self.x, self.y, self.r, self.scaleX, 1, self.width / 2, self.height / 2)
end

function Enemies.updateAll(dt)
    for i, instance in ipairs(ActiveEnemies) do
        instance:update(dt)
    end
end

function Enemies.drawAll()
    for i, instance in ipairs(ActiveEnemies) do
        instance:draw()
    end
end

return Enemies