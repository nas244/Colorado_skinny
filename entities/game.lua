Bump = require "libs.bump.bump"

-- Overall game controller

Game = Class{
  init = function(self)
    -- Defined globally /shrug
    local puckDir = love.math.random(math.pi * 2)
    puck = {
      img = love.graphics.newImage("assets/ball.png"),
      name = "puck",
      x = window.width / 2,
      y = window.height / 2,
      dx = math.cos(puckDir) * 5,
      dy = math.sin(puckDir) * 5,
    }
    
    puck.w, puck.h = puck.img:getWidth(), puck.img:getHeight()
    
    -- Set up our world
    world = Bump.newWorld()
    
    world:add(puck, puck.x, puck.y, puck.w, puck.h)
    
    function makeWall(x,y,w,h)
      return {x = x, y = y, w = w, h = h}
    end
    
    walls = {
      top = makeWall(0,0,window.width,16),
      bottom = makeWall(0,window.height - 16, window.width, 16),
      leftTop = makeWall(0,16, 16, window.height - 32),
      rightTop = makeWall(window.width - 16,16, 16, window.height - 32),
    }
    
    for k,v in pairs(walls) do
      world:add(v, v.x, v.y, v.w, v.h)
    end
  end,
  
  update = function(self)
    local goalX, goalY = puck.x + puck.dx, puck.y + puck.dy
    
    local actualX, actualY, cols, len = world:move(puck, goalX, goalY, function() return "bounce" end)
    puck.x , puck.y = actualX, actualY
    
    for i, col in ipairs(cols) do
      if contains(walls, col.other) then
        if col.normal.x ~= 0 then
          puck.dx = -puck.dx
        else
          puck.dy = -puck.dy
        end
      end
    end
  end,
  
  draw = function(self)
    for k,v in pairs(walls) do
      love.graphics.rectangle("fill", v.x, v.y, v.w, v.h)
    end
    
    love.graphics.draw(puck.img, puck.x, puck.y)
  end
}

return Game