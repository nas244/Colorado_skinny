Hump = require "libs.hump.class"
Vector = require "libs.hump.vector"

Puck = Class{
  init = function(self, side)
    self.img = puckImage
    self.name = "puck"
    
    self.opacity = 1
    self.opacityDec = 1 / (60 * 2)
    
    self.side = side or 0
    self.sideTimer = 0
    
    self.h = self.img:getWidth() - 10
    self.w = self.h
    
    self.x = ((1 + self.side) * window.width) / 3 - self.w / 2
    self.y = window.height / 2 - self.h / 2
    
    self.speed = 100
    
    self.collider = world:newCircleCollider(self.x + self.w / 2, self.y + self.h / 2, self.w / 2)
    self.collider:setCollisionClass("Puck")
    self.collider:setMass(10)
    self.collider:setLinearDamping(0.25)
  end,
  
  update = function(self)
    
    local xx = self.collider:getPosition()
    
    if xx < window.width / 2 then
      self.side = 0
    else
      self.side = 1
    end
    
    local movement = {self.collider:getLinearVelocity()}
    local moving = (movement[1] ~= 0) or (movement[2] ~= 0)
    if (self.sideTimer == 0 and moving) or self.collider:enter("Middle") then
      self.sideTimer = 1
    
    elseif self.sideTimer ~= 0 and not self.scored then
      self.sideTimer = self.sideTimer + 1
      
      if self.sideTimer >= 7 * 60 then
        self:score(1 - self.side)
      end
    end
    
    -- Setup for out-of-bounds behavior
    local outDist = self.w * 2
    local outPush = 50
    
    self.x, self.y = self.collider:getPosition()
    
    -- If we've entered a scoring zone
    if self.collider:enter("Score") then
      
      self:score(1 - self.side)
    elseif self.scored then
      -- Get X velcoity, throw out Y
      local speed = math.abs(self.collider:getLinearVelocity())
      
      if self.x < -outDist or self.x > window.width + outDist then
        -- Reset puck to side just scored on
        self:reset(self.side)
      elseif (self.x < self.w / 2 or self.x > window.width - self.w / 2) and speed < 100 then
        local force = -outPush + (2 * outPush * self.side)
        self.collider:applyLinearImpulse(force,0)
      else
        self.opacity = self.opacity - self.opacityDec
        
        if self.opacity <= 0 then
          -- Reset puck to other side
          self:reset(1 - self.side)
        end
      end
    end
  end,
  
  draw = function(self)
    local ox, oy = self.img:getWidth() / 2, self.img:getHeight() / 2
    
    local xx, yy = self.collider:getPosition()
    
    love.graphics.setColor(1,1,1,self.opacity)
    drawShadow(love.graphics.draw, self.img, xx, yy, 0.5, 1, 1, ox, oy)
    love.graphics.setColor(1,1,1,1)
  end,
  
  score = function(self, side)
    -- If this puck hasn't scored yet
    if not self.scored then
      -- Increment the correct side's score
      self.scored = true
      
      if side == 0 then
        leftMallet.score = leftMallet.score + 1
      else
        rightMallet.score = rightMallet.score + 1
      end
    end
  end,
  
  reset = function(self, side)
    self.collider:destroy()
    puck = Puck(side)
    self = nil
  end,
}

return Puck