Vector = Vector or require "src/vector"
Object = Object or require "lib/object"
local Actor = Object:extend()

function Actor:new(image,x,y,speed,fx,fy)
    self.position = Vector.new(x or 0, y or 0)
    self.scale = Vector.new(1,1)
    self.forward = Vector.new(fx or 1,fy or 0)
    self.speed = speed or 30
    self.rot = 0
    self.image = love.graphics.newImage(image or "src/textures/background.jpg")
    self.origin = Vector.new(self.image:getWidth()/2 ,self.image:getHeight()/2)
    self.height = self.image:getHeight()
    self.width  = self.image:getWidth()
end

function Actor:update(dt)
  self.position = self.position + self.forward * self.speed * dt
end

function Actor:draw()
end

function Actor.dist(a,b)
  v=b.position - a.position
  return v:len()
end

return Actor