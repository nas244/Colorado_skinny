Vector = require "libs.hump.vector"
wf = require "libs.windfield"
-- Air hockey game controller state

Puck = require "entities.puck"
LeftMallet = require "entities.leftMallet"
RightMallet = require "entities.rightMallet"

-- Ensure that images only loads once
puckImage = love.graphics.newImage("assets/Game/red_puck.png")

mallets = 
  {
    red = love.graphics.newImage("assets/Game/red_mallet.png"),
    blue = love.graphics.newImage("assets/Game/blue_mallet.png"),
  }

boards = 
  {
    default = love.graphics.newImage("assets/Boards/Board_Min_Marked.png"),
    classic = love.graphics.newImage("assets/Boards/Classic_Board_Edged.png"),

  }

function getVid(vid)
  return "assets/Videos/" .. vid .. ".ogg"
end

Game = {
  opponents = {
    [1] = {
      board = boards.default,
      mallet = mallets.blue,
      pre = "intro",
      lose = "reggy-lose",
      win = "reggy-win",
    },
    [2] = {
      board = boards.classic,
      mallet = mallets.blue,
      pre = "quartz-pre",
      lose = "quartz-lose",
      win = "quartz-win",
    },
    [3] = {
      board = boards.default,
      mallet = mallets.blue,
      pre = "little-t-pre",
      lose = "little-t-lose",
      win = "little-t-win",
    },
    [4] = {
      board = boards.classic,
      mallet = mallets.blue,
      pre = "tiny-pre",
      lose = "tiny-lose",
      win = "tiny-win",
    }
  },
  
  pauseText = love.graphics.newText(font, ""),
  
  enter = function(self, current, skipIntro)
    skipIntro = skipIntro or false
    
    opponent = settings.opponent
    if opponent > #self.opponents then
      GS.switch(Menu)
      settings.opponent = 1
      return
    end
    
    self.opponent = opponent
    
    if not skipIntro then
      GS.switch( Video, getVid( self.opponents[self.opponent].pre ) )
      
      return
    end
    
    self.optionSelect = 1
    
    -- Get that mouse going!
    love.mouse.setRelativeMode(true)
    
    self.fade = 0
    self.fadeAmount = 2 / 60
    
    self.paused = false
    self.pauseFade = 0
    
    self.endWin = false
    self.endText = nil
    self.endTimer = 5 * 60 / 5
    
    world = wf.newWorld(0, 0, true)
    
    world:addCollisionClass("Wall")
    world:addCollisionClass("Score")
    world:addCollisionClass("Middle")
    
    world:addCollisionClass("Puck", {ignores = {"Middle", "Score"}})
    world:addCollisionClass("GhostPuck", {ignores = {"Middle", "Puck", "Score"}})
    
    world:addCollisionClass("Mallet", {ignores = {}})
    
    -- Defined globally /shrug
    puck = Puck()
    leftMallet = LeftMallet()
    rightMallet = RightMallet(self.opponent)
    
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
    
    local midWidth = 16
    midWall = makeWall(window.width / 2 - midWidth / 2, 0, midWidth, window.height, "Middle")
  end,
  
  leave = function(self)
    love.mouse.setRelativeMode(false)
    
    if world then
      world:destroy()
      world = nil
    end
    
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
    local volumeDiff = (bti(actions.increaseVolume) - bti(actions.decreaseVolume))
    
    if sensitivityDiff ~= 0 then
      print("SENSITIVITY CHANGED")
      settings.sensitivity = clamp(settings.sensitivity + sensitivityDiff, 1, 10)
    
    elseif volumeDiff ~= 0 then
      print("VOLUME CHANGED")
      settings.volume = clamp(settings.volume + volumeDiff, 0, 10)
      love.audio.setVolume(settings.volume / 10)
    end
    
    self.fade = clamp(self.fade + self.fadeAmount, 0, 1)
    
    self.pauseFade = lerp(self.pauseFade, bti(self.paused), 0.5)
    
    if not self.paused then
      leftMallet:update()
      rightMallet:update()
      
      if puck then
        puck:update()
      end
      
      rightMallet:update()
      world:update(dt)
      
      local scoreMax = 1
      
      if leftMallet.score >= scoreMax then
        self.endText = "You win!"
        self.endWin = true
        
      elseif rightMallet.score >= scoreMax then
        self.endText = "You lose..."
        
      end
    else
      self.optionSelect = keepBetween(self.optionSelect + actions.UD, 1, 3)
      
      if actions.start then
        if self.optionSelect == 1 then
          actions.pause = true
        elseif self.optionSelect == 2 then
          self:leave()
          self:enter()
        elseif self.optionSelect == 3 then
          GS.switch(Menu)
        end
      end
    end
    
    if self.endText then
      self.endTimer = self.endTimer - 1
      
      if self.endTimer <= 0 then
        if self.endWin then
          GS.switch(Video, getVid( self.opponents[self.opponent].win ), false )
          
          settings.opponent = settings.opponent + 1
        else
          GS.switch(Video, getVid( self.opponents[self.opponent].lose ))
          
          return
        end
      end
    
    elseif actions.pause then
      self.paused = not self.paused
      self.optionSelect = 1
      
      love.mouse.setRelativeMode(not self.paused)
      
      self.pauseText:set( choose{"Need a break, huh?", "Paused.", "Hold on a minute...", "Wait wait wait!", "Air hockey ain't made for pausin'!", "Don't be too long!", "Strategy break.", "Time out!", "Not to scale."} )
    end
  end,
  
  draw = function(self)
    love.graphics.setColor(1,1,1,0.9)
    
    local backScale = window.width / boards.default:getWidth()
    
    love.graphics.scale(backScale)
    love.graphics.draw(self.opponents[self.opponent].board,0,0)
    love.graphics.origin()
    
    love.graphics.setColor(1,1,1)
    
    if puck then
      puck:draw()
    end
    
    leftMallet:draw()
    rightMallet:draw()
    
    love.graphics.setLineWidth(5)
    love.graphics.setColor(0,0,0)
    world:draw(0.5)
    
    love.graphics.setFont(font)
    love.graphics.setColor(1,0.2,0.2, 1)
    drawShadow(love.graphics.print, tostring(leftMallet.score), 32, 20)
    drawShadow(love.graphics.print, tostring(rightMallet.score), window.width - 64, 20)
    
    if puck and not self.endText then
      local puckTimer = tostring(math.floor(math.abs(puck.sideTimer / 60)))
      drawShadow(love.graphics.printf, puckTimer, 0, 32, window.width, "center")
    end
    
    love.graphics.setColor(0.5,0.5,1,self.pauseFade / 2)
    love.graphics.rectangle("fill", 0, 0, window.width, window.height)
    
    love.graphics.setFont(font)
    
    if self.endText then
      local yy = window.height / 4
      
      love.graphics.setColor(0.5,0.5,1)
      
      drawShadow(love.graphics.printf, self.endText, 0, yy, window.width, "center")
    
    elseif self.paused then
      local ww = self.pauseText:getWidth() / 2
      local hh = self.pauseText:getHeight() / 2
      local xx, yy = window.width / 2 - ww, window.height / 4
      
      love.graphics.setColor(0.5,0.5,1)
      
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
    
    local fades = math.max(1 - self.fade, 1 - self.endTimer / 60)
    
    love.graphics.setColor(0,0,0,fades)
    love.graphics.rectangle("fill", 0, 0, window.width, window.height)
  end,
  
  reset = function(self, side)
    puck.collider:destroy()
    
    puck = nil
    
    if not self.endText then
      puck = Puck(side)
    end
  end,
}

return Game