Hump = require "libs.hump.class"
Vector = require "libs.hump.vector"

wallSound = love.audio.newSource("assets/Sounds/wall.mp3", "static")
malletSound = love.audio.newSource("assets/Sounds/mallet.mp3", "static")

Puck = Class{
  init = function(self, side)
    self.img = puckImage
    self.name = "puck"
    
    self.opacity = 1
    self.opacityDec = 1 / (60 * 2)
    
    self.side = side or 0
    self.sideTimer = 0
    
    self.lastCollide = nil
    
    self.h = self.img:getWidth() - 10
    self.w = self.h
    
    self.x = ((1 + self.side) * window.width) / 3 - self.w / 2
    self.y = window.height / 2 - self.h / 2
    
    self.speed = 100
    
    self.collider = world:newCircleCollider(self.x + self.w / 2, self.y + self.h / 2, self.w / 2)
    self.collider:setCollisionClass("Puck")
    self.collider:setMass(10)
    self.collider:setLinearDamping(0.25)
    
    self.collider:setPostSolve(
      function(collider_1, collider_2, contact, ni1, ti1, ni2, ti2)
        if collider_1.collision_class == "Puck" and collider_2.collision_class == "Wall" then
          if collider_2 ~= self.lastCollide then
            self.lastCollide = collider_2
            
            local px, py = collider_1:getLinearVelocity()
            
            local speed = Vector(px, py):len() / 200
            speed = clamp( speed, 0, 1)
            
            wallSound:setVolume(speed)
            wallSound:play()
          end
        
        elseif collider_1.collision_class == "Puck" and collider_2.collision_class == "Mallet" then
          
          self.lastCollide = nil
          
          local px, py = collider_1:getLinearVelocity()
          local mx, my = collider_2:getLinearVelocity()
          
          local speed = Vector(mx, my):len() / 200
          local speed2 = Vector(px, py):len() / 200
          speed = clamp( math.max(speed, speed2), 0, 1)
          
          malletSound:setVolume(speed)
          malletSound:play()
        end
      end
    )
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
        Game:reset(self.side)
      elseif (self.x < self.w / 2 or self.x > window.width - self.w / 2) and speed < 100 then
        local force = -outPush + (2 * outPush * self.side)
        self.collider:applyLinearImpulse(force,0)
      else
        self.opacity = self.opacity - self.opacityDec
        
        if self.opacity <= 0 then
          -- Reset puck to other side
          Game:reset(1 - self.side)
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
}

return Puck