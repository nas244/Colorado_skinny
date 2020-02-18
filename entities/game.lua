Vector = require "libs.hump.vector"
wf = require "libs.windfield"
-- Air hockey game controller state

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

Game = {
  opponents = {
    quartz = {
      board = boards.default,
      mallet = mallets.blue
    }
  },
  
  enter = function(self)
    self.optionSelect = 1
    
    -- Get that mouse going!
    love.mouse.setRelativeMode(true)
    
    self.paused = false
    self.pauseText = love.graphics.newText(font, "")
    
    world = wf.newWorld(0, 0, true)
    
    world:addCollisionClass("Wall")
    world:addCollisionClass("Score")
    world:addCollisionClass("Middle")
    world:addCollisionClass("Puck", {ignores = {"Middle", "Score"}})
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
    
    local puckOut = 64
    
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
  
  exit = function(self)
    love.mouse.setRelativeMode(false)
    
    world:destroy()
    
    walls = nil
    score = nil
    
    puck = nil
    leftMallet = nil
    rightMallet = nil
    
    self.opponent = nil
  end,
  
  update = function(self, dt)
    -- DEBUG: replace with menu thing
    local sensitivityDiff = bti(actions.increaseSensitivity) - bti(actions.decreaseSensitivity)
    
    if sensitivityDiff ~= 0 then
      leftMallet.sensitivity = clamp(leftMallet.sensitivity + sensitivityDiff, 1, 10)
      print("SENSITIVITY CHANGED")
    end
    
    if not self.paused then
      leftMallet:update()
      rightMallet:update()
      puck:update()
      rightMallet:update()
      world:update(dt)
    else
      self.optionSelect = keepBetween(self.optionSelect + actions.UD, 1, 3)
      
      if actions.start then
        if self.optionSelect == 1 then
          actions.pause = true
        elseif self.optionSelect == 2 then
          self:exit()
          self:enter()
        elseif self.optionSelect == 3 then
          GS.switch(Menu)
        end
      end
    end
    
    if actions.pause then
      self.paused = not self.paused
      self.optionSelect = 1
      
      love.mouse.setRelativeMode(not self.paused)
      
      self.pauseText:set( choose{"Need a break, huh?", "Paused.", "Hold on a minute...", "Wait wait wait!", "Air hockey ain't made for pausin'!", "Don't be too long!", "Strategy break.", "Time out!"} )
    end
    
    
    leftMallet.score = clamp(leftMallet.score, 0, 7)
    rightMallet.score = clamp(rightMallet.score, 0, 7)
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
    
    love.graphics.setFont(font)
    love.graphics.setColor(1,0.2,0.2, 1)
    drawShadow(love.graphics.print, tostring(leftMallet.score), 32, 20)
    drawShadow(love.graphics.print, tostring(rightMallet.score), window.width - 64, 20)
    
    love.graphics.setLineWidth(5)
    love.graphics.setColor(0,0,0)
    world:draw(128)
    
    if self.paused then
      local ww = self.pauseText:getWidth() / 2
      local hh = self.pauseText:getHeight() / 2
      local xx, yy = window.width / 2 - ww, window.height / 4
      
      love.graphics.setColor(0.5,0.5,1)
      
      love.graphics.setFont(font)
      drawShadow(love.graphics.draw, self.pauseText, xx, yy - hh)
      
      love.graphics.setFont(smallFont)
      
      local pauseOptions = {"Continue", "Restart", "Quit"}
      for i = 0,2 do
        local opt = pauseOptions[i + 1]
        if self.optionSelect == i + 1 then
          opt = "* " .. opt
        else
          opt = "  " .. opt
        end
        drawShadow(love.graphics.print, opt, window.width / 2.75, yy * 1.5 + 48 * i)
      end
    end
  end
}

return Game