Hump = require "libs.hump.class"
Vector = require "libs.hump.vector"

LeftMallet = Class{
  init = function(self)
    self.img = mallets.red
    self.name = "leftMallet"
    
    self.h = self.img:getWidth() - 10
    self.w = self.h
    
    self.x = window.width / 4 - self.w / 2
    self.y = window.height / 4 - self.h / 2
    
    self.speed = 100
    self.maxSpeed = 2000
    
    self.score = 0
    
    self.collider = world:newCircleCollider(self.x + self.w / 2, self.y + self.h / 2, self.w / 2)
    self.collider:setCollisionClass("Mallet")
    self.collider:setMass(10)
    
    -- Heavy linear damping to prevent sliding around
    self.collider:setLinearDamping(10)
  end,
  
  update = function(self)
    -- Take mouse movement, trim movements to 10 times max speed and scale down by ten
    local normMouse = Vector(mouse.x, mouse.y):trimmed(self.speed * 20) / 20
    
    -- Next, add mouse movement to puck movement and then clamp magnitude to max puck speed
    local newMove = normMouse:trimmed(self.speed) * 500 * settings.sensitivity * 2
    
    self.collider:applyLinearImpulse(newMove.x, newMove.y)
    
    self.collider:setLinearVelocity( Vector(self.collider:getLinearVelocity()):trimmed(self.maxSpeed):unpack() )
  end,
  
  draw = function(self)
    local ox, oy = self.img:getWidth() / 2, self.img:getHeight() / 2
    
    local xx, yy = self.collider:getPosition()
    
    drawShadow(love.graphics.draw, self.img, xx, yy, 0.5, 1, 1, ox, oy)
  end,
}

return LeftMallet