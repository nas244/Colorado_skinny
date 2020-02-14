Vector = require "libs.hump.vector"
wf = require "libs.windfield"
-- Overall game controller

Puck = require "entities.puck"
LeftMallet = require "entities.leftMallet"
RightMallet = require "entities.rightMallet"

-- Ensure that image only loads once
puckImage = love.graphics.newImage("assets/red_puck.png")
back = love.graphics.newImage("assets/Board_Min_Marked.png")

Game = Class{
  init = function(self)
    world = wf.newWorld(0, 0, true)
    
    world:addCollisionClass("Wall")
    world:addCollisionClass("Score")
    world:addCollisionClass("Middle")
    world:addCollisionClass("Puck", {ignores = {"Middle"}})
    world:addCollisionClass("Mallet", {ignores = {"Middle"}})
    
    -- Defined globally /shrug
    puck = Puck()
    leftMallet = LeftMallet()
    rightMallet = RightMallet()
    mallets = {
      lm = leftMallet,
      rm = rightMallet
    }
    
    -- Let's get some WALLS goin
    function makeWall(x,y,w,h,name)
      local myWall = world:newRectangleCollider(x, y, w, h)
      myWall:setType("static")
      myWall:setCollisionClass(name or "Wall")
      myWall:setRestitution(0.5)
      
      return myWall
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
    
    local midWidth = 32
    midWall = makeWall(window.width / 2 - midWidth / 2, 0, midWidth, window.height, "Middle")
    
  end,
  
  update = function(self, dt)
    leftMallet:update()
    rightMallet:update()
    puck:update()
    world:update(dt)
  end,
  
  draw = function(self)
    love.graphics.setColor(1,1,1,0.9)
    
    local backScale = window.width / back:getWidth()
    
    love.graphics.scale(backScale)
    love.graphics.draw(back,0,0)
    love.graphics.origin()
    
    love.graphics.setColor(1,1,1)
    
    puck:draw()
    leftMallet:draw()
    rightMallet:draw()
    
    love.graphics.setColor(1,0.2,0.2)
    drawShadow(love.graphics.print, "hi there" .. tostring(leftMallet.score), 16, 8)
    
    love.graphics.setLineWidth(5)
    love.graphics.setColor(0,0,0)
    world:draw(128)
    
    love.graphics.setColor(1,1,1)
  end
}

return Game