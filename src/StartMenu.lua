Actor = Actor or require "src/actor"
local StartMenu = Actor:extend()

local w, h = love.graphics.getDimensions()

function StartMenu:new()
    self.backgroundMusic = love.audio.newSource("src/music/SanAndreas.wav","static")
    self.backgroundMusic:setVolume(0.2)
    self.backgroundMusic:setLooping(true)
    self.backgroundMusic:play()

    self.background = love.graphics.newImage("src/textures/background/background_layer_1.png")
    self.background2 = love.graphics.newImage("src/textures/background/background_layer_2.png")
    self.background3 = love.graphics.newImage("src/textures/background/background_layer_3.png")

    self.woodButton = love.graphics.newImage("src/textures/background/cartel.png")

    self.font = love.graphics.newFont("src/font/EnchantedLand.otf", 40)
    love.graphics.setFont(self.font)
    self.fontSize = 1

    self.title = "BROOK THE HOOK"
    self.titleX = w/5.15
    self.titleY = h/7.5

    self.imageStartPosX = w/2.75
    self.imageStartPosY = h/4
    self.startButtonPosX = w/2.45
    self.startButtonPosY = h/2

    self.imageQuitPosX = w/2.75
    self.imageQuitPosY = h/2
    self.quitButtonPosX = w/2.45
    self.quitButtonPosY = h - 175

    self.rectangleWidth, self.rectangleHeight = 250, 150
end

function StartMenu:update(dt)
    self.mousePositionX, self.mousePositionY = love.mouse.getPosition()

    if(love.mouse.isDown(1)) then
        if ((self.mousePositionX > self.startButtonPosX and self.mousePositionX < self.rectangleWidth + self.startButtonPosX) and (self.mousePositionY > self.startButtonPosY and self.mousePositionY < self.rectangleHeight + self.startButtonPosY)) then
            print("startinggame")
            gameStarted = true
            self.backgroundMusic:stop()
            love.load()
            --MAP_LEVEL
        end
        if ((self.mousePositionX > self.quitButtonPosX and self.mousePositionX < self.rectangleWidth + self.quitButtonPosX) and (self.mousePositionY > self.quitButtonPosY and self.mousePositionY < self.rectangleHeight + self.quitButtonPosY)) then
            love.event.quit()
        end
    end
end

function StartMenu:draw()
    love.graphics.draw(self.background, 0, 0, 0, 5, 5) -- this is for our future background, it should be always before the map
    love.graphics.draw(self.background2, 0, 0, 0, 5, 5)
    love.graphics.draw(self.background3, 0, 0, 0, 5, 5)

    

    love.graphics.print(self.title, self.titleX, self.titleY, 0, self.fontSize * 3, self.fontSize * 3) 

    love.graphics.draw(self.woodButton,self.imageQuitPosX, self.imageQuitPosY)
    love.graphics.draw(self.woodButton,self.imageStartPosX, self.imageStartPosY, 0, 1, 1)

    love.graphics.print("START",self.startButtonPosX + 45, self.startButtonPosY + 45, 0, self.fontSize * 1.4 , self.fontSize * 1.4) 
    love.graphics.print("QUIT",self.quitButtonPosX + 70, self.quitButtonPosY + 45, 0, self.fontSize * 1.4 , self.fontSize * 1.4) 

    if gameWon then
        love.graphics.print("CONGRATS!!", 30 , h-150, 0, self.fontSize *1.8, self.fontSize *1.8)
    end

    --love.graphics.rectangle("line", self.startButtonPosX, self.startButtonPosY, self.rectangleWidth, self.rectangleHeight)
    --love.graphics.rectangle("line", self.quitButtonPosX, self.quitButtonPosY, self.rectangleWidth, self.rectangleHeight)

end



return StartMenu