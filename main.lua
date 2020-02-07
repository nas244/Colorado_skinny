Class = require("libs.hump.class")
Bump = require("libs.bump.bump")
require("libs.useful")

-- Set up window table with information
--  Width/height are BEFORE scaling
window = {
  width = 640,
  height = 360,
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

-- Runs on load
function love.load()
  -- Disable linear filtering (i hate that crap)
	love.graphics.setDefaultFilter("nearest","nearest",1)
  --  love.keyboard.setKeyRepeat(true)
  
  -- Colorado Skinny Visits The Stars
  love.window.setTitle( "Colorado Skinny" )
  
  -- Set our window to the right size, adjusting for our current scale
  love.window.setMode(window.width * window.scale, window.height * window.scale)
  
  -- Create a canvas, without scaling
	Canvas = love.graphics.newCanvas(window.width, window.height)
  
  -- Set up our action table
	actions = {}
  
  -- Overall game timer for fun (and sin functions)
  gameTime = 0
  
  -- Get our game controller
  Game = require("entities.game")
  Game.init()
end

function love.update(dt)
  gameTime = gameTime + 1
  
  -- Actions
  actions.test = keyp.f
  
  Game.update()
  
  keyp = {}
end

function love.draw(dt)
	love.graphics.setDefaultFilter("nearest","nearest",1)
  love.graphics.setCanvas(Canvas)
	love.graphics.scale(1)
	love.graphics.clear()
  
  Game.draw()
  
	love.graphics.scale(window.scale)
  love.graphics.setCanvas()
  love.graphics.draw(Canvas, 0, 0)
end