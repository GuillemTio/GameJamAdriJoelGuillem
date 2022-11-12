Actor = Actor or require "src/actor"
local StartMenu = Actor:extend()

local w, h = love.graphics.getDimensions()

function StartMenu:new()
    local font = love.graphics.newFont("src/textures/pong.ttf", 40)
    love.graphics.setFont(font)
    self.fontSize = 1

    self.tittle = "GOBBLINCHASE"
    self.titleX = 100
    self.titleY = 50

    self.startButtonPosX = w/3
    self.startButtonPosY = h/3

    self.quitButtonPosX = w/3
    self.quitButtonPosY = h - 100

    self.rectangleWidth, self.rectangleHeight = 150, 75

    self.mousePositionX, self.mousePositionY = love.mouse.getPosition()
end

function StartMenu:update(dt)
    if(love.mouse.isDown(1))then
        if(self.mousePositionX> self.startButtonPosX and self.mousePositionY > self.startButtonPosY) then
            print("startinggame")
        end
        if(self.mousePositionX> self.quitButtonPosX and self.mousePositionY > self.startButtonPosY) then
            love.event.quit()
        end
    end
end

function StartMenu:draw()
    love.graphics.print(self.tittle, self.titleX, self.titleY, 0, self.fontSize*2, self.fontSize*2) 
    love.graphics.rectangle("line", self.startButtonPosX, self.startButtonPosY, self.rectangleWidth, self.rectangleHeight)
    love.graphics.rectangle("line", self.quitButtonPosX, self.quitButtonPosY, self.rectangleWidth, self.rectangleHeight)
end