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
    local px, py = puck.collider:getPosition()
    local xx, yy = self.collider:getPosition()
    local pmx, pmy = puck.collider:getLinearVelocity()
    local mmx, mmy = self.collider:getLinearVelocity()

    local slope = (pmy / pmx) / love.physics.getMeter()
    local newY = clamp(py + slope * xx, 0, window.height)
    local goal = (window.height/2-yy)

    print(mmx,mmy)

    if pmx <= 0 or pmy == 0 then
      self.collider:setPosition(xx,yy)
      self.collider:applyLinearImpulse(5,5)

    elseif -2<=yy-newY and yy-newY<=2 then
      print("apply momentum")
      self.collider:applyLinearImpulse(px*-5,goal*5)
      self.collider:setLinearVelocity( Vector(self.collider:getLinearVelocity()):trimmed(self.maxSpeed):unpack() )
      
    else
      print("change location")
      self.collider:setPosition(window.width / 1.3  + self.w / 2, newY )
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