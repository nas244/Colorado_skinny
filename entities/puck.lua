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
    
    self.collider = world:newCircleCollider(self.x + self.w / 2, self.y + self.h / 2, self.w / 2)
    self.collider:setCollisionClass("Puck")
    self.collider:setMass(10)
    self.collider:setLinearDamping(0.25)
  end,
  
  update = function(self)
    -- Setup for out-of-bounds behavior
    local outDist = self.w * 2
    local outPush = 50
    
    self.x, self.y = self.collider:getPosition()
    
    -- If we've entered a scoring zone
    if self.collider:enter("Score") then
      
      -- If this puck hasn't scored yet
      if not self.score then
        
        -- Figure out where we are, then set our score side
        --   1 being the right side, -1 being the left side
        --   and increment the correct side's score
        if self.x > window.width / 2 then
          self.score = 1
          leftMallet.score = leftMallet.score + 1
        else
          self.score = -1
          rightMallet.score = rightMallet.score + 1
        end
      end
    else
      local speed = Vector(self.collider:getLinearVelocity()):len()
      print(speed)
      
      if self.x < -outDist or self.x > window.width + outDist then
        self.collider:destroy()
        puck = Puck()
        self = nil
      elseif self.score and (self.x < self.w / 2 or self.x > window.width - self.w / 2) and speed < 100 then
        self.collider:applyLinearImpulse(self.score * outPush,0)
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