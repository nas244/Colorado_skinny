GS = require "libs.hump.gamestate"

-- Video playing state

Video = {
  enter = function(self, previous, filename, skipIntro)
    if not filename then
      GS.switch(Menu)
      return
    end
    self.video = love.graphics.newVideo(filename)
    
    self.video:setFilter("nearest", "nearest", 1)
    self.video:play()
    
    self.clicks = 0
    
    if skipIntro ~= nil then
      self.skipIntro = skipIntro
    else
      self.skipIntro = true
    end
  end,
  
  leave = function(self)
    self.video = nil
  end,
  
  update = function(self, dt)
    self.clicks = self.clicks + bti(actions.skip)
    
    if self.clicks >= 10 or not self.video:isPlaying() then
      self.video:pause()
      
      GS.switch(Game, self.skipIntro)
    end
  end,
  
  draw = function(self)
    local scale = window.height / self.video:getHeight()
    love.graphics.scale(scale)
    
    love.graphics.draw(self.video, 0, 0)
    
    love.graphics.origin()
  end
}

return Video