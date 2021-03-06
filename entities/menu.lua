GS = require "libs.hump.gamestate"

-- Menu state

menuBack = love.graphics.newImage("assets/Main_Menu.png")
menuImg = love.graphics.newImage("assets/Game/menuLogo.png")

local function newButton(text, fn)
  local BUTTON_Y = window.height / 2.2
  local BUTTON_HEIGHT = 64
  local BUTTON_WIDTH = window.width / 1.8
  local BUTTON_GAP = 8

  local newButton = {
    text = text,
    fn = fn,
    x = window.width / 2 - BUTTON_WIDTH / 2,
    y = BUTTON_Y + (#buttons * (BUTTON_HEIGHT + BUTTON_GAP)),
    w = BUTTON_WIDTH,
    h = BUTTON_HEIGHT,
  }
  
  table.insert(buttons, newButton)
end


buttons = {}
newButton("New Game",
  function(self, act, lr)
    if act then
      settings.opponent=1
      GS.switch(Game)
    end
  end)
newButton("Continue Game",
  function(self, act, lr)
    if act then
      GS.switch(Game)
    end
  end)
newButton("< Volume : " .. settings.volume .. ">",
  function(self, act, lr)
    if lr ~= 0 then
      settings.volume = clamp(settings.volume + lr, 0, 10)
      love.audio.setVolume(settings.volume / 10)
      
      self.text = "< Volume : " .. settings.volume .. ">"
    end
  end)
newButton("< Sensitivity : " .. settings.sensitivity .. ">",
  function(self, act, lr)
    if lr ~= 0 then
      settings.sensitivity = clamp(settings.sensitivity + lr, 0, 10)
      
      self.text = "< Sensitivity : " .. settings.sensitivity .. ">"
    end
  end)
newButton("Quit",
  function(self, act, lr)
    if act then
      love.event.push("quit")
    end
  end)

Menu = {
  enter = function(self)
    love.mouse.setGrabbed(false)
    
    self.selected = 0
    
    self.logoX = 0
    self.logoXChange = 1 / 60
    
    self.useMouse = true
  end,
  
  leave = function(self)
    
  end,
  
  update = function(self, dt)
    self.logoX = clamp(self.logoX + self.logoXChange, 0, 1)
    
    local mx,my = love.mouse.getPosition()
    local mouseB = keyp.mouse1
    
    if actions.UD ~= 0 then
      self.useMouse = false
    elseif mouse.x ~= 0 or mouse.y ~= 0 then
      self.useMouse = true
    end
    
    if self.useMouse then
      self.selected = 0
      
      for i, button in ipairs(buttons) do
        local xx = mx > button.x and mx < button.x + button.w
        local yy = my > button.y and my < button.y + button.h
        if xx and yy then
          self.selected = i
          
          if mouseB then
            local mLR = 1 - 2 * bti(mx < window.width / 2)
            
            button:fn(mouseB, mLR)
          end
          break
        end
      end
    
    else
      if self.selected < 1 then
        self.selected = 1
      else
        self.selected = keepBetween(self.selected + actions.UD, 1, #buttons)
      end
      buttons[self.selected]:fn(actions.start, actions.LR)
    end
    
    if actions.pause then
      love.event.push("quit")
    end
  end,
  
  draw = function(self)
    local backScale = window.width / menuBack:getWidth()
    
    love.graphics.scale(backScale)
    love.graphics.draw(menuBack,0,0)
    love.graphics.origin()
    
    drawImg(menuImg, window.width * (-1 + self.logoX) ^ 3, 0, 0.5)
    
    for i, button in ipairs(buttons) do
      
      local color = {0.6, 0.0, 0.6, 1.0}
      
      local hot = self.selected == i
      
      if hot then 
        color = {0.4, 0.0, 0.4, 1.0}
      end
      
      love.graphics.setColor(unpack(color))
      love.graphics.rectangle("fill", button.x, button.y, button.w, button.h)
      
      love.graphics.setColor(0.8,0.5,0.8,1.0)
      local textW = font:getWidth(button.text)
      local textH = font:getHeight(button.text)
      love.graphics.print(button.text,font, button.x + button.w / 2 - (textW * 0.5), button.y + (textH * 0.1))    
    end
  
    love.graphics.setColor(0,0,0,1 - self.logoX)
    
    love.graphics.rectangle("fill", 0, 0, window.width, window.height)
  end
}

return Menu