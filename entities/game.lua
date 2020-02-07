-- Overall game controller

Game = Class{
  init = function(self)
    -- Defined globally /shrug
    puck = {
      img = love.graphics.newImage("assets/ball.png"),
      x = 0,
      y = 0,
      dx = 10,
      dy = 10,
    }
    puck.w, puck.h = puck.img:getWidth(), puck.img:getHeight()
  end,
  
  update = function(self)
    puck.x = puck.x + puck.dx
    puck.y = puck.y + puck.dy
    
    if puck.x < 0 or puck.x > window.width - puck.w then
      puck.x = clamp(puck.x, 0, window.width - puck.w)
      puck.dx = -puck.dx
    end
    
    if puck.y < 0 or puck.y > window.height - puck.h then
      puck.y = clamp(puck.y, 0, window.height - puck.h)
      puck.dy = -puck.dy
    end
  end,
  
  draw = function(self)
    love.graphics.draw(puck.img, puck.x, puck.y)
  end
}

return Game