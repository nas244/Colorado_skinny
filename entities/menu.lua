GS = require "libs.hump.gamestate"

-- Menu state

menuBack = love.graphics.newImage("assets/Boards/Classic_Board_Rounded.png")

local function newButton(text,fn)
  return {text=text,fn=fn, now = false, last = false}
end
BUTTON_HEIGHT = 64
local buttons = {}
table.insert(buttons, newButton("Start Game", function() GS.switch(Game)end))
table.insert(buttons, newButton("Settings", function()end))
table.insert(buttons, newButton("Restart", function()end))
table.insert(buttons, newButton("Quit", function() love.event.push("quit") end))

Menu = {
  enter = function(self)
    love.mouse.setGrabbed(false)
  end,
  
  exit = function(self)
    
  end,
  
  update = function(self, dt)
    if actions.start then
      GS.switch(Game)
    end
  end,
  
  draw = function(self)
    local backScale = window.width / menuBack:getWidth()
    
    love.graphics.scale(backScale)
    love.graphics.draw(menuBack,0,0)
    love.graphics.origin()
    
    local ww = window.width
    local wh = window.height
    local margin = 16
    local total_height = BUTTON_HEIGHT + margin * #buttons
    local button_width = ww * (1/3)
    local cursor_y = 0
   
    
    for i, button in ipairs(buttons) do
      button.last = button.now
      
      local bx = (ww * 0.5) - (button_width * 0.5)
      local by = (wh * 0.5) - (total_height * 0.5) + cursor_y
      local color = {0.6, 0.0, 0.6, 1.0}
      local mx,my = love.mouse.getPosition()
      local hot = mx > bx and mx < bx + button_width and my > by and my < by + BUTTON_HEIGHT
      
      if hot then 
        color = {0.4, 0.0, 0.4, 1.0}
      end
      
      button.now = love.mouse.isDown(1)
      
      -- TODO: should move this out of draw, calling some functions from draw call can cause issues
      if button.now and not button.last and hot then
        button.fn()
      end
      love.graphics.setColor(unpack(color))
      love.graphics.rectangle("fill", bx, by, button_width, BUTTON_HEIGHT)
      
      love.graphics.setColor(0.8,0.5,0.8,1.0)
      local textW = font:getWidth(button.text)
      local textH = font:getHeight(button.text)
      love.graphics.print(button.text,font ,(ww * 0.5) - (textW * 0.5) ,by + (textH * 0.1))    
      cursor_y = cursor_y + (BUTTON_HEIGHT + margin)
    end
  
  end
}

return Menu