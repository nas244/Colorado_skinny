Hump = require "libs.hump.class"
Vector = require "libs.hump.vector"

RightMallet = Class{
  init = function(self)
    self.img = mallets.blue
    self.name = "rightMallet"
    
    self.h = self.img:getWidth() - 10
    self.w = self.h
    
    self.x = 3 * window.width / 4 - self.w / 2
    self.y = 3 * window.height / 4 - self.h / 2
    
    self.speed = 100
    self.maxSpeed = 2000
    
    self.score = 0
    
    self.collider = world:newCircleCollider(self.x + self.w / 2, self.y + self.h / 2, self.w / 2)
    self.collider:setCollisionClass("Mallet")
    self.collider:setMass(10)
    self.collider:setLinearDamping(10)
  end,
  
  update = function(self)
    -- Take mouse movement, trim movements to 10 times max speed and scale down by ten
    --local normMouse = Vector(mouse.x, mouse.y):trimmed(self.speed * 10) / 10
    
    -- Next, add mouse movement to puck movement and then clamp magnitude to max puck speed
    --local newMove = normMouse:trimmed(self.speed) * 500
    local puckmovex,puckmovey = puck.collider:getLinearVelocity()
    local puckpositionx,puckpositiony = puck.collider:getPosition()
    local xx, yy = self.collider:getPosition()

    local difference = yy - (puckmovey/puckmovex)*xx+puckpositiony

    print(difference)

    if puckmovex == 0 and puckmovey == 0 then
      self.collider:setPosition(xx,yy)

    --elseif  then
      --print("equal")
      --self.collider:applyLinearImpulse(0,0)
      
    else
      print("change location")
      self.collider:setPosition(window.width / 1.3  + self.w / 2,(puckmovey/puckmovex)*xx+puckpositiony)
    end

    


    --self.collider:applyLinearImpulse(newMove.x, newMove.y)
  end,
  
  draw = function(self)
    local ox, oy = self.img:getWidth() / 2, self.img:getHeight() / 2
    
    local xx, yy = self.collider:getPosition()
    
    drawShadow(love.graphics.draw, self.img, xx, yy, 0.5, 1, 1, ox, oy)
  end,
}

return RightMallet