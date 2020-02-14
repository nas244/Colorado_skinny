Vector = require "libs.hump.vector"
wf = require "libs.windfield"
-- Overall game controller

Puck = require "entities.puck"
LeftMallet = require "entities.leftMallet"
RightMallet = require "entities.rightMallet"

-- Ensure that image only loads once
puckImage = love.graphics.newImage("assets/red_puck.png")

mallets = {
  red = love.graphics.newImage("assets/red_mallet.png"),
  blue = love.graphics.newImage("assets/blue_mallet.png"),
}

boards = 
  {
    default = love.graphics.newImage("assets/Board_Min_Marked.png"),
    classic = love.graphics.newImage("assets/Classic_Board_Edged.png"),
  }

Game = Class{
  opponents = {
    quartz = {
      board = boards.default,
      mallet = mallets.blue
    }
  },
  
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
    
    local wallRestitution = 0.8
    local wallHeight = window.height / 3
    
    -- Let's get some WALLS goin
    function makeWall(x,y,w,h,name)
      local myWall = world:newRectangleCollider(x, y, w, h)
      myWall:setType("static")
      myWall:setCollisionClass(name or "Wall")
      myWall:setRestitution(0.8)
      
      return myWall
    end
    
    puckOut = 64
    
    walls = {
      top = makeWall(0,-puckOut,window.width,16 + puckOut),
      bot = makeWall(0,window.height - 16, window.width, 16 + puckOut),
      leftTop = makeWall(-puckOut, 16, 16 + puckOut, wallHeight),
      leftBot = makeWall(-puckOut, window.height - wallHeight - 16, 16 + puckOut, wallHeight),
      rightTop = makeWall(window.width - 16,16, 16 + puckOut, wallHeight),
      rightBot = makeWall(window.width - 16, window.height - wallHeight - 16, 16 + puckOut, wallHeight),
    }
    
    local scoreWidth = 64
    
    function makeScore(x)
      local myScore = world:newRectangleCollider(x - scoreWidth, 16 + wallHeight, scoreWidth, window.height - 2 * wallHeight - 32)
      myScore:setType("static")
      myScore:setCollisionClass("Score")
      myScore:setRestitution(0.8)
      
      return myScore
    end
    
    score = {
      left = makeScore(0),
      right = makeScore(window.width + scoreWidth)
    }
    
    local midWidth = 32
    midWall = makeWall(window.width / 2 - midWidth / 2, 0, midWidth, window.height, "Middle")
    
    self.opponent = choose(keys(self.opponents))
  end,
  
  update = function(self, dt)
    leftMallet:update()
    rightMallet:update()
    puck:update()
    rightMallet:update()
    world:update(dt)
  end,
  
  draw = function(self)
    love.graphics.setColor(1,1,1,0.9)
    
    local backScale = window.width / boards.default:getWidth()
    
    love.graphics.scale(backScale)
    love.graphics.draw(self.opponents[self.opponent].board,0,0)
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