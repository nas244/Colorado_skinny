Class = require("libs.hump.class")
Vector = require "libs.hump.vector"

require("libs.useful")

-- Set up window table with information
--  Width/height are BEFORE scaling
window = {
  width = 1280,
  height = 720,
  scale = 1
}

-- Configure to use console output
function love.conf(t)
	t.console = true
end

-- Key is pressed
function love.keypressed(key)
  -- Escape closes game instantly
  if key == "escape" then
    love.event.push("quit")
  
  -- Ctrl+R reloads game
  elseif key == "r" and love.keyboard.isDown("lctrl","rctrl") then
    love.load()
  end
  
  -- Set keypress and keyhold for this key to true
  keyp[key] = true
  keyh[key] = true
end

-- If key is released, disable its hold state
function love.keyreleased(key)
  keyh[key] = false
end

keyp = {}
keyh = {}

-- Mouse movement table
mouse = Vector(0,0)

-- Update mouse table every mouse move
function love.mousemoved( x, y, dx, dy, istouch )
  local newMouse = Vector(dx, dy)
  
  -- Optional if statement to limit mouse movement to 
  --   only larger movements to prevent extremely small
  --   twitches from affecting gameplay
  --if newMouse:len() > 1 then
    mouse = newMouse
  --end
end

-- Runs on load
function love.load()
  -- Disable linear filtering (i hate that crap)
	love.graphics.setDefaultFilter("linear","linear",16)
  --  love.keyboard.setKeyRepeat(true)
  
  -- Colorado Skinny Visits The Stars
  love.window.setTitle( "Colorado Skinny - Air Hockey Novice" )
  
  -- Set our window to the right size, adjusting for our current scale
  love.window.setMode(window.width * window.scale, window.height * window.scale)
  
  -- Create a canvas, without scaling
	Canvas = love.graphics.newCanvas(window.width, window.height)
  
  font = love.graphics.newFont("assets/scoreboard.ttf", 60)
  love.graphics.setFont(font)
  
  -- Set up our action table
	actions = {}
  
  -- Get that mouse going!
  love.mouse.setRelativeMode(true)
  
  -- Overall game timer for fun (and sin functions)
  gameTime = 0
  
  -- Get our game controller
  Game = require("entities.game")
  Game:init()
end

-- Line for mouse drawing
mouseDraw = {x = 0, y = 0}

function love.update(dt)
  gameTime = gameTime + 1
  
  -- Actions
  actions.test = keyp.f
  
  -- Update our game function
  Game:update(dt)
  
  -- Reset keypresses
  keyp = {}
  
  -- Update info for drawing the mouse lines
  mouseDraw.x, mouseDraw.y = mouse.x, mouse.y
  
  -- Reset mouse at end of every frame
  --   This is because of an issue I've found with my mouse,
  --   where if you accelerate quickly and then lift the mouse,
  --   Love2D won't call love.mousemoved, so the fast movement
  --   will remain as the last move indefinitely
  mouse.x, mouse.y = 0, 0
end

function love.draw(dt)
	love.graphics.setDefaultFilter("nearest","nearest",1)
  love.graphics.setCanvas(Canvas)
	love.graphics.clear()
  
  Game:draw()
  
  local xx, yy = window.width / 2, window.height / 2
  love.graphics.line(xx, yy, xx + mouseDraw.x * 5 , yy + mouseDraw.y * 5 )
  
	love.graphics.scale(window.scale)
  love.graphics.setCanvas()
  love.graphics.draw(Canvas, 0, 0)
end