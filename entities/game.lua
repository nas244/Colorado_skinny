Vector = require "libs.hump.vector"
Bump = require "libs.bump.bump"

-- Overall game controller


-- Ensure that image only loads once
puckImage = love.graphics.newImage("assets/red_puck.png")

Puck = Class{
  init = function(self)
    self.img = puckImage
    self.name = "puck"
    
    self.h = self.img:getWidth()
    self.w = self.h
    
    self.x = window.width / 2 - self.w / 2
    self.y = window.height / 2 - self.h / 2
    
    self.speed = 10
    self.movement = Vector.randomDirection() * self.speed
    
    
    world:add(self, self.x, self.y, self.w, self.h)
  end,
  
  update = function(self)
    -- Take mouse movement, trim movements to 10 times mouse speed and scale down by ten
    local normMouse = Vector(mouse.x, mouse.y):trimmed(self.speed * 10) / 10
    
    -- Next, add mouse movement to puck movement and then clamp magnitude to max puck speed
    local newMove = (self.movement + normMouse):trimmed(self.speed)
    
    -- Set puck movement to new movement
    self.movement = newMove
    
    local goalX, goalY = (Vector(self.x, self.y) + self.movement):unpack()
    
    local actualX, actualY, cols, len = world:move(self, goalX, goalY, function() return "bounce" end)
    self.x , self.y = actualX, actualY
    
    for i, col in ipairs(cols) do
      if contains(walls, col.other) then
        self.movement = self.movement:mirrorOn(Vector(col.normal.x, col.normal.y):perpendicular())
      end
    end
    
    -- If the puck has gone outside of the play area
    local outDist = self.w * 2
    if self.x < -outDist or self.x > window.width + outDist or self.y < -outDist or self.y > window.height + outDist then
      -- Remove puck from physics
      world:remove(self)
      
      -- Set global reference to puck to be a new puck
      puck = Puck()
      
      -- Increase left mallet's score
      leftMallet.score = leftMallet.score + 1
      
      -- Probably unnecessary since the garbage collector should take care of it,
      --  but go ahead and unreference the old puck object directly anyway
      self = nil
    end
  end,
}

Game = Class{
  init = function(self)
    world = Bump.newWorld()
    
    -- Defined globally /shrug
    puck = Puck()
    
    -- Just a table for now, probably will change later
    leftMallet = {
      img = love.graphics.newImage("assets/ball.png"),
      name = "leftMallet",
      x = window.width / 4,
      y = window.height / 2,
      movement = Vector(),
      speed = 0,
      score = 0,
    }
    
    -- Let's get some WALLS goin
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
    puck:update()
  end,
  
  draw = function(self)
    for k,v in pairs(walls) do
      -- Set up random colors based on position and size
      love.graphics.setColor(v.x / window.width, (v.h + v.y) / window.height, v.w / window.width, 0.8)
      love.graphics.rectangle("fill", v.x, v.y, v.w, v.h)
    end
    
    love.graphics.setColor(1,1,1)
    
    local ox, oy = puck.img:getWidth() / 2, puck.img:getHeight() / 2
    love.graphics.draw(puck.img, puck.x + ox, puck.y + oy, 0, 1, 1, ox, oy)
    love.graphics.print(tostring(leftMallet.score), 16, 8)
  end
}

return Game