Actor = Actor or require "src/actor"
local Asteroid = Actor:extend()

function Asteroid:new(x,y)
  Asteroid.super.new(self,"src/textures/Meteors/meteorBrown_big1.png",400,500,20,1,0)
end

function Asteroid:update(dt)
    Asteroid.super.update(self,dt)
end

function Asteroid:draw()
  local xx = self.position.x
  local ox = self.origin.x
  local yy = self.position.y
  local oy = self.origin.y
  local sx = self.scale.x
  local sy = self.scale.y
  local rr = self.rot
  love.graphics.draw(self.image,xx,yy,rr,sx,sy,ox,oy,0,0)
end

return Asteroid
