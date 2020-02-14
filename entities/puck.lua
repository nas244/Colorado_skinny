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
    local outDist = self.w * 2
    
    self.x, self.y = self.collider:getPosition()
    
    if self.collider:enter("Score") then
      if not self.score then
        if self.x < window.width / 2 then
          self.score = -1
          leftMallet.score = leftMallet.score + 1
        else
          self.score = 1
          rightMallet.score = rightMallet.score + 1
        end
      end
    end
  end,
  
  draw = function(self)
    local ox, oy = self.img:getWidth() / 2, self.img:getHeight() / 2
    
    local xx, yy = self.collider:getPosition()
    
    drawShadow(love.graphics.draw, self.img, xx, yy, 0.5, 1, 1, ox, oy)
  end,
}

return Puck