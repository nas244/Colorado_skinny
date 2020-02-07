Class = require("libs.hump.class")
Bump = require("libs.bump.bump")
require("libs.useful")

window = {
  width = 640,
  height = 360,
  scale = 1
}

function love.conf(t)
	t.console = true
end

function love.keypressed(key)
  if key == "escape" then
    love.event.push("quit")
  elseif key == "r" and love.keyboard.isDown("lctrl","rctrl") then
    love.load()
  end
  
  keyp[key] = true
  keyh[key] = true
end

function love.keyreleased(key)
  keyh[key] = false
end

keyp = {}
keyh = {}

function love.load()
	love.graphics.setDefaultFilter("nearest","nearest",1)
  --  love.keyboard.setKeyRepeat(true)
  
  love.window.setTitle( "Colorado Skinny" )
  
  love.window.setMode(window.width * window.scale, window.height * window.scale)
	Canvas = love.graphics.newCanvas(window.width, window.height)
  
	actions = {}
  
  gameTime = 0
end

function love.update(dt)
  gameTime = gameTime + 1
  
  -- Actions
  
  keyp = {}
end

function love.draw(dt)
	love.graphics.setDefaultFilter("nearest","nearest",1)
  love.graphics.setCanvas(Canvas)
	love.graphics.scale(1)
	love.graphics.clear()
  
  
  
	love.graphics.scale(window.scale)
  love.graphics.setCanvas()
  love.graphics.draw(Canvas, 0, 0)
end