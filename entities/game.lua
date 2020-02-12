Vector = require "libs.hump.vector"
Bump = require "libs.bump.bump"
-- Overall game controller

Puck = require "entities.puck"

-- Ensure that image only loads once
puckImage = love.graphics.newImage("assets/red_puck.png")
back = love.graphics.newImage("assets/board.png")

LeftMallet = Class{
  init = function(self)
    self.img = puckImage
    self.name = "leftMallet"
    
    self.h = self.img:getWidth() - 10
    self.w = self.h
    
    self.x = window.width / 4 - self.w / 2
    self.y = window.height / 4 - self.h / 2
    
    self.speed = 10
    self.movement = Vector()
    
    self.score = 0
    
    world:add(self, self.x, self.y, self.w, self.h)
  end,
  
  filter = function(item, other)
    if contains(walls, other) then
      return "slide"
    else
      return "bounce"
    end
  end,
  
  update = function(self)
    -- Take mouse movement, trim movements to 10 times max speed and scale down by ten
    local normMouse = Vector(mouse.x, mouse.y):trimmed(self.speed * 10) / 10
    
    -- Next, add mouse movement to puck movement and then clamp magnitude to max puck speed
    local newMove = (self.movement + normMouse):trimmed(self.speed)
    
    -- Set puck movement to new movement
    self.movement = newMove
    
    local goalX, goalY = (Vector(self.x, self.y) + self.movement):unpack()
    
    local actualX, actualY, cols, len = world:move(self, goalX, goalY, self.filter)
    self.x , self.y = actualX, actualY
  end,
}

Game = Class{
  init = function(self)
    world = Bump.newWorld()
    
    -- Defined globally /shrug
    puck = Puck()
    leftMallet = LeftMallet()
    mallets = {
      lm = leftMallet
    }
    
    -- Let's get some WALLS goin
    function makeWall(x,y,w,h)
      return {x = x, y = y, w = w, h = h}
    end
    
    local wallHeight = window.height / 3
    
    puckOut = 32
    
    walls = {
      top = makeWall(0,0,window.width,16),
      bot = makeWall(0,window.height - 16, window.width, 16),
      leftTop = makeWall(-puckOut, 16, 16 + puckOut, wallHeight),
      leftBot = makeWall(-puckOut, window.height - wallHeight - 16, 16 + puckOut, wallHeight),
      rightTop = makeWall(window.width - 16,16, 16 + puckOut, wallHeight),
      rightBot = makeWall(window.width - 16, window.height - wallHeight - 16, 16 + puckOut, wallHeight),
    }
    
    for k,v in pairs(walls) do
      world:add(v, v.x, v.y, v.w, v.h)
    end
  end,
  
  update = function(self)
    puck:update()
    leftMallet:update()
  end,
  
  draw = function(self)
    love.graphics.setColor(1,1,1,0.5)
    love.graphics.draw(back,0,0)
    
    for k,v in pairs(walls) do
      -- Set up random colors based on position and size
      love.graphics.setColor(v.x / window.width, (v.h + v.y) / window.height, v.w / window.width, 0.8)
      love.graphics.rectangle("fill", v.x, v.y, v.w, v.h)
    end
    
    love.graphics.setColor(1,1,1)
    
    local ox, oy = puck.img:getWidth() / 2, puck.img:getHeight() / 2
    drawShadow(love.graphics.draw, puck.img, puck.x + puck.w / 2, puck.y + puck.h / 2, 0.5, 1, 1, ox, oy)
    drawShadow(love.graphics.draw, leftMallet.img, leftMallet.x + leftMallet.w / 2, leftMallet.y + leftMallet.h / 2,
      0.5, 1, 1, ox, oy)
    
    love.graphics.setColor(1,0.2,0.2)
    drawShadow(love.graphics.print, tostring(leftMallet.score), 16, 8)
    
    love.graphics.setColor(1,1,1)
  end
}

return Game