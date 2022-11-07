Actor = Actor or require "src/actor"
local Player = Actor:extend()
local Vector = Vector or require"src/vector"

function Player:new(x,y)
    Player.super.new(self,"src/textures/PackNinja/IndividualSprites/adventurer-idle-00",400,500,20,1,0)

    self.x = 100
    self.y = 0
    self.width = 50
    self.height = 37
    
    self.physics = {}
    self.physics.body = love.physics.newBody(World,self.x,self.y,"dynamic")
    self.physics.body:setFixedRotation(true)
    self.physics.shape = love.physics.newRectangleShape(self.width/2,self.height)
end

function Player:update(dt)
    Player.super.update(self,dt)
end

function Player:draw()
    local xx = self.position.x
    local ox = self.origin.x
    local yy = self.position.y
    local oy = self.origin.y
    local sx = self.scale.x/15
    local sy = self.scale.y/15
    local rr = self.rot
    love.graphics.draw(self.image,xx,yy,rr,sx,sy,ox,oy,0,0)
  end

  return Player