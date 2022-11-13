local HUD = {}
local Player = require("src/Player")

function HUD:load()
   self.hearts = {}
   self.hearts.img = love.graphics.newImage("src/textures/heart/tile000.png")
   self.hearts.width = self.hearts.img:getWidth()
   self.hearts.height = self.hearts.img:getHeight()
   self.hearts.x = 0
   self.hearts.y = 20
   self.hearts.scale = 0.15
   self.hearts.spacing = self.hearts.width * self.hearts.scale + 20
end

function HUD:update(dt)

end

function HUD:draw()
   self:displayHearts()
end

function HUD:displayHearts()
   for i=1,Player.health.current do
      local x = self.hearts.x + self.hearts.spacing * i
      love.graphics.setColor(0,0,0,0.5)
      love.graphics.draw(self.hearts.img, x + 2, self.hearts.y + 2, 0, self.hearts.scale, self.hearts.scale)
      love.graphics.setColor(1,1,1,1)
      love.graphics.draw(self.hearts.img, x, self.hearts.y, 0, self.hearts.scale, self.hearts.scale)
   end
end

return HUD