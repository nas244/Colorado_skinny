GS = require "libs.hump.gamestate"

-- Menu state

menuBack = love.graphics.newImage("assets/Classic_Board_Rounded.png")

Menu = {
  enter = function(self)
    
  end,
  
  exit = function(self)
    
  end,
  
  update = function(self, dt)
    if actions.start then
      GS.switch(Game)
    end
  end,
  
  draw = function(self)
    local yy = window.height / 3
    
    drawShadow(love.graphics.printf, "Colorado Skinny - Air Hockey Novice", 0, yy, window.width, "center")
    drawShadow(love.graphics.printf, "Press enter to begin", 0, yy * 2, window.width, "center")
  end
}

return Menu