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
    self.collider:setLinearVelocity( Vector(self.collider:getLinearVelocity()):trimmed(self.maxSpeed):unpack() )
  end,
  
  draw = function(self)
    local ox, oy = self.img:getWidth() / 2, self.img:getHeight() / 2
    
    local xx, yy = self.collider:getPosition()
    
    drawShadow(love.graphics.draw, self.img, xx, yy, 0.5, 1, 1, ox, oy)
  end,
}

return RightMallet