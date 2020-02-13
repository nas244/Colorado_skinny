Hump = require "libs.hump.class"
Vector = require "libs.hump.vector"
Bump = require "libs.bump.bump"

Puck = Class{
  init = function(self)
    self.img = puckImage
    self.name = "puck"
    
    self.h = self.img:getWidth() - 10
    self.w = self.h
    
    self.mass = 1
    
    self.x = window.width / 2 - self.w / 2
    self.y = window.height / 2 - self.h / 2
    
    self.speed = 10
    self.movement = Vector.randomDirection() * self.speed
    
    world:add(self, self.x, self.y, self.w, self.h)
  end,
  
  filter = function(item, other)
    if other == midWall then
      return "cross"
    elseif contains(walls, other) then
      return "bounce"
    end
    return "touch"
  end,
  
  update = function(self)
    --[[
    -- Take mouse movement, trim movements to 10 times max speed and scale down by ten
    local normMouse = Vector(mouse.x, mouse.y):trimmed(self.speed * 10) / 10
    
    -- Next, add mouse movement to puck movement and then clamp magnitude to max puck speed
    local newMove = (self.movement + normMouse):trimmed(self.speed)
    
    -- Set puck movement to new movement
    self.movement = newMove
    --]]
    
    self.movement = self.movement * 0.999
    
    local goalX, goalY = (Vector(self.x, self.y) + self.movement):unpack()
    
    local actualX, actualY, cols, len = world:move(self, goalX, goalY, self.filter)
    self.x , self.y = actualX, actualY
    
    self:react(cols)
    
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
  
  react = function(self, cols)
    
    for i, col in ipairs(cols) do
      local other = col.other
      if contains(walls, other) then
        
        local realX, realY = puck.x + puck.w / 2, puck.y + puck.h / 2
        
        local norm = col.normal
        
        local x,y,w,h = world:getRect(other)
        local nearX, nearY = Bump.rect.getNearestCorner( x,y,w,h, realX, realY)
        local cornerToPuck = Vector(realX - nearX, realY - nearY)
        
        local angleDiff = math.abs(cornerToPuck:angleTo(norm)) % math.pi
        
        -- If we're on one of the corners, and the angle to the puck is less than 90 degrees
        --   (because there are situations where the number is more than 90 which doesn't make sense
        --    and causes bizarre interactions)
        if (realX < other.x or realX > other.x + other.w) and (realY < other.y or realY > other.y + other.h)
          and angleDiff < math.pi / 2 then
            local currentSpeed = self.movement:len()
            local cornerBounce = cornerToPuck:trimmed(currentSpeed)
            self.movement = cornerBounce
        else
          self.movement = self.movement:mirrorOn(Vector(norm.x, norm.y):perpendicular())
        end
        
        self.movement = self.movement * 0.9
      elseif contains(mallets, other) then
        local toOther = Vector(other.x - self.x, other.y - self.y)
        local dist = toOther:len()
        
        if true then
          local v1 = self.movement:len()
          local v2 = other.movement:len()
          local theta1 = self.movement:angleTo()
          local theta2 = other.movement:angleTo()
          local phi = toOther:angleTo()
          local m1 = self.mass
          local m2 = other.mass

          local nvx = ((v1 * math.cos(theta1 - phi) * (m1 - m2)) + (2 * m2 * v2 * math.cos(theta2 - phi))) / (m1 + m2) * math.cos(phi) + v1 * math.sin(theta1 - phi) * math.cos(phi + math.pi / 2)
          local nvy = ((v1 * math.cos(theta1 - phi) * (m1 - m2)) + (2 * m2 * v2 * math.cos(theta2 - phi))) / (m1 + m2) * math.sin(phi) + v1 * math.sin(theta1 - phi) * math.sin(phi + math.pi / 2)
          
          local onvx = ((v2 * math.cos(theta2 - phi) * (m2 - m1)) + (2 * m1 * v1 * math.cos(theta1 - phi))) / (m1 + m2) * math.cos(phi) + v2 * math.sin(theta2 - phi) * math.cos(phi + math.pi / 2)
          local onvy = ((v2 * math.cos(theta2 - phi) * (m2 - m1)) + (2 * m1 * v1 * math.cos(theta1 - phi))) / (m1 + m2) * math.sin(phi) + v2 * math.sin(theta2 - phi) * math.sin(phi + math.pi / 2)
          
          
          other.movement = Vector(onvx, onvy):trimmed(other.speed)
          self.movement = Vector(nvx, nvy):trimmed(self.speed)
        end
      end
    end
  end,
}

return Puck