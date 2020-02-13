Vector = require "libs.hump.vector"
Bump = require "libs.bump.bump"
-- Overall game controller

Puck = require "entities.puck"
LeftMallet = require "entities.leftMallet"

-- Ensure that image only loads once
puckImage = love.graphics.newImage("assets/red_puck.png")
back = love.graphics.newImage("assets/Board_Min_Marked.png")

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
    
    puckOut = 64
    
    walls = {
      top = makeWall(0,-puckOut,window.width,16 + puckOut),
      bot = makeWall(0,window.height - 16, window.width, 16 + puckOut),
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
    leftMallet:update()
    puck:update()
  end,
  
  draw = function(self)
    love.graphics.setColor(1,1,1,0.5)
    
    local backScale = window.width / back:getWidth()
    
    love.graphics.scale(backScale)
    love.graphics.draw(back,0,0)
    love.graphics.origin()
    
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
    drawShadow(love.graphics.print, "hi there" .. tostring(leftMallet.score), 16, 8)
    
    love.graphics.setColor(1,1,1)
  end
}

return Game