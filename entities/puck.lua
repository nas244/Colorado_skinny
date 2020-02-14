Hump = require "libs.hump.class"
Vector = require "libs.hump.vector"

Puck = Class{
  init = function(self)
    self.img = puckImage
    self.name = "puck"
    
    self.h = self.img:getWidth() - 10
    self.w = self.h
    
    self.x = window.width / 3 - self.w / 2
    self.y = window.height / 2 - self.h / 2
    
    self.speed = 100
    self.movement = Vector.randomDirection() * self.speed
    
    self.collider = world:newCircleCollider(self.x + self.w / 2, self.y + self.h / 2, self.w / 2)
    self.collider:setCollisionClass("Puck")
    self.collider:setMass(10)
  end,
  
  update = function(self)
    local outDist = self.w
    
    if self.x < -outDist or self.x > window.width + outDist or self.y < -outDist or self.y > window.height + outDist then
      -- Remove puck from physics
      
      
      -- Set global reference to puck to be a new puck
      
      
      -- Increase left mallet's score
      leftMallet.score = leftMallet.score + 1
      
      -- Probably unnecessary since the garbage collector should take care of it,
      --  but go ahead and unreference the old puck object directly anyway
      --self = nil
    end
  end,
  
  draw = function(self)
    local ox, oy = self.img:getWidth() / 2, self.img:getHeight() / 2
    
    local xx, yy = self.collider:getPosition()
    
    drawShadow(love.graphics.draw, self.img, xx, yy, 0.5, 1, 1, ox, oy)
  end,
}

return Puck