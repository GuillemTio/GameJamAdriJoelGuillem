local EnemyGoblin = {}
EnemyGoblin._index = EnemyGoblin
local Player = require("src/Player")

local ActiveEnemies = {}

function EnemyGoblin:new(x, y)
    local instance = setmetatable({}, EnemyGoblin)
    instance.x = x
    instance.y = y
    instance.r = 0

    instance.state = "run"

    instance.animation = {timer = 0, rate = 0.1}
    instance.animation.run = {total = 8, current = 1, img = EnemyGoblin.runAnimation}
    instance.animation.draw = instance.animation.run.img[1]
    
    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "dynamic")
    instance.physics.body:setFixedRotation(true)
    instance.physics.shape = love.physics.newRectangleShape(5 * 0.4, 5 * 0.75)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    instance.physics.body:setMass(25)
    table.insert(ActiveEnemies, instance)
end

function EnemyGoblin.loadAssets()
    EnemyGoblin.runAnimation = {}
    for i=1,8 do
        EnemyGoblin.runAnimation[i] = love.graphics.newImage("src/textures/Monsters_Creatures_Fantasy/Goblin/Run"..i..".png")
    end

    EnemyGoblin.width = EnemyGoblin.runAnimation[1]:getWidth()
    EnemyGoblin.height = EnemyGoblin.runAnimation[1]:getHeight()
end

function EnemyGoblin:update(dt)
    self:syncPhysics()
    self:animate(dt)
end

function EnemyGoblin:animate(dt)
    self.animation.timer = self.animation.timer + dt
    if self.animation.timer > self.animation.rate then
       self.animation.timer = 0
       self:setNewFrame()
    end
end
 
function EnemyGoblin:setNewFrame()
    local anim = self.animation[self.state]
    if anim.current < anim.total then
       anim.current = anim.current + 1
    else
       anim.current = 1
    end
    self.animation.draw = anim.img[anim.current]
end

function EnemyGoblin:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
    self.r = self.physics.body:getAngle()
end

function EnemyGoblin:draw()
    love.graphics.draw(self.animation.draw, self.x, self.y, self.r, self.scaleX, 1, self.width / 2, self.height / 2)
end

function EnemyGoblin.updateAll(dt)
    for i,instance in ipairs(ActiveEnemies) do
        instance:update(dt)
    end
end

function EnemyGoblin.drawAll()
    for i,instance in ipairs(ActiveEnemies) do
        instance:draw()
    end
end

return EnemyGoblin