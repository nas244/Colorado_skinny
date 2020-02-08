Vector = require "libs.hump.vector"
Bump = require "libs.bump.bump"

-- Overall game controller

Game = Class{
  init = function(self)
    -- Defined globally /shrug
    puck = {
      img = love.graphics.newImage("assets/ball.png"),
      name = "puck",
      x = window.width / 2,
      y = window.height / 2,
      movement = Vector.randomDirection() * 5,
      speed = 5,
    }
    
    puck.w, puck.h = puck.img:getWidth(), puck.img:getHeight()
    
    -- Set up our world
    world = Bump.newWorld()
    
    world:add(puck, puck.x, puck.y, puck.w, puck.h)
    
    function makeWall(x,y,w,h)
      return {x = x, y = y, w = w, h = h}
    end
    
    local wallHeight = window.height / 3
    
    walls = {
      top = makeWall(0,0,window.width,16),
      bot = makeWall(0,window.height - 16, window.width, 16),
      leftTop = makeWall(0, 16, 16, wallHeight),
      leftBot = makeWall(0, window.height - wallHeight - 16, 16, wallHeight),
      rightTop = makeWall(window.width - 16,16, 16, wallHeight),
      rightBot = makeWall(window.width - 16, window.height - wallHeight - 16, 16, wallHeight),
    }
    
    for k,v in pairs(walls) do
      world:add(v, v.x, v.y, v.w, v.h)
    end
  end,
  
  update = function(self)
    local normMouse = Vector(mouse.x, mouse.y):trimmed(puck.speed * 10) / 10
    local newMove = (puck.movement + normMouse):trimmed(puck.speed)
    puck.movement = newMove
    
    local goalX, goalY = (Vector(puck.x, puck.y) + puck.movement):unpack()
    
    local actualX, actualY, cols, len = world:move(puck, goalX, goalY, function() return "bounce" end)
    puck.x , puck.y = actualX, actualY
    
    for i, col in ipairs(cols) do
      if contains(walls, col.other) then
        puck.movement = puck.movement:mirrorOn(Vector(col.normal.x, col.normal.y):perpendicular())
      end
    end
    
    local outDist = puck.w * 2
    if puck.x < -outDist or puck.x > window.width + outDist or puck.y < -outDist or puck.y > window.height + outDist then
      self:init()
    end
  end,
  
  draw = function(self)
    for k,v in pairs(walls) do
      -- Set up random colors based on position and size
      love.graphics.setColor(v.x / window.width, (v.h + v.y) / window.height, v.w / window.width, 0.8)
      love.graphics.rectangle("fill", v.x, v.y, v.w, v.h)
    end
    
    love.graphics.setColor(1,1,1)
    love.graphics.draw(puck.img, puck.x, puck.y)
    love.graphics.print("Font Test 2010", 0, 0)
  end
}

return Game