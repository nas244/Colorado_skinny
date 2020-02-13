Hump = require "libs.hump.class"
Vector = require "libs.hump.vector"
Bump = require "libs.bump.bump"

LeftMallet = Class{
  init = function(self)
    self.img = puckImage
    self.name = "leftMallet"
    
    self.h = self.img:getWidth() - 10
    self.w = self.h
    
    self.x = window.width / 4 - self.w / 2
    self.y = window.height / 4 - self.h / 2
    
    self.mass = 1
    
    self.speed = 10
    self.movement = Vector()
    
    self.score = 0
    
    world:add(self, self.x, self.y, self.w, self.h)
  end,
  
  filter = function(item, other)
    if contains(walls, other) then
      return "slide"
    else
      return "bounce"
    end
  end,
  
  update = function(self)
    -- Take mouse movement, trim movements to 10 times max speed and scale down by ten
    local normMouse = Vector(mouse.x, mouse.y):trimmed(self.speed * 10) / 10
    
    -- Next, add mouse movement to puck movement and then clamp magnitude to max puck speed
    local newMove = (self.movement + normMouse):trimmed(self.speed)
    
    -- Set puck movement to new movement
    self.movement = newMove
    
    local goalX, goalY = (Vector(self.x, self.y) + self.movement):unpack()
    
    local actualX, actualY, cols, len = world:move(self, goalX, goalY, self.filter)
    self.x , self.y = actualX, actualY
    
    self:react(cols)
  end,
  
  react = function(self, cols)
    for k,col in pairs(cols) do
      local other = col.other
      
      if other == puck then
        local toOther = Vector(other.x - self.x, other.y - self.y)
        local dist = toOther:len()
        
        if dist <= self.w + 2 or true then
          local v1 = self.movement:len()
          local v2 = other.movement:len()
          local theta1 = self.movement:angleTo()
          local theta2 = other.movement:angleTo()
          local phi = toOther:angleTo()
          local m1 = 4
          local m2 = 1

          local nvx = ((v1 * math.cos(theta1 - phi) * (m1 - m2)) + (2 * m2 * v2 * math.cos(theta2 - phi))) / (m1 + m2) * math.cos(phi) + v1 * math.sin(theta1 - phi) * math.cos(phi + math.pi / 2)
          local nvy = ((v1 * math.cos(theta1 - phi) * (m1 - m2)) + (2 * m2 * v2 * math.cos(theta2 - phi))) / (m1 + m2) * math.sin(phi) + v1 * math.sin(theta1 - phi) * math.sin(phi + math.pi / 2)
          
          local onvx = ((v2 * math.cos(theta2 - phi) * (m2 - m1)) + (2 * m1 * v1 * math.cos(theta1 - phi))) / (m1 + m2) * math.cos(phi) + v2 * math.sin(theta2 - phi) * math.cos(phi + math.pi / 2)
          local onvy = ((v2 * math.cos(theta2 - phi) * (m2 - m1)) + (2 * m1 * v1 * math.cos(theta1 - phi))) / (m1 + m2) * math.sin(phi) + v2 * math.sin(theta2 - phi) * math.sin(phi + math.pi / 2)
          
          
          other.movement = Vector(onvx, onvy):trimmed(other.speed)
          self.movement = Vector(nvx, nvy):trimmed(self.speed)
        end
      end
      
      self.movement = self.movement * 0.9
    end
  end
}

return LeftMallet