-- Creates deep copy of table
function dupeTable(tab)
  local orig = tab
  local dupe = {}
  if type(orig) == "table" then
    for i,j in pairs(tab) do
      dupe[i] = dupeTable(j)
    end
    return dupe
  else
    return orig
  end
end

-- Loops number around min and max inclusively
--  e.g. x, 3, 5, with x increasing
--       3 4 5 3 4 5 3 4 5
function keepBetween(x,mi,mx)
  local diff = mx - mi + 1
  x = ((x - mi) % diff) + mi
  return x
end

-- Randomly choose value from table
function choose(tab)
  return tab[ love.math.random(#tab) ]
end

-- Get a list of all keys in a table
function keys(tab)
  local key = {}
  
  for k,v in pairs(tab) do
    table.insert(key, k)
  end
  return key
end

-- rounds numbers to neatest of value (0.1 to nearest tenth, 10 to nearest ten, etc)
function round(num, dec)
  dec = dec or 1
  return math.floor(num / dec + 0.5) * dec
end

-- Returns string, rounded to the given number of decimal places
function roundStr(num, numDecimalPlaces)
  return string.format("%." .. (numDecimalPlaces or 0) .. "f", num)
end

-- Converts boolean to integer (true to 1, false to 0)
function bti(bool)
  return ((bool) and 1 or 0)
end

-- Linear interpolation
function lerp(a,b,t)
  return ( (a * (1 - t) ) + (b * t) )
end

-- Clamps between min and max inclusively
-- e.g. x, 3, 5, x is 1 to 7
--      3, 3, 3, 4, 5, 5, 5
function clamp(x,mn,mx)
	mix = math.max(mn,mx)
	man = math.min(mn,mx)
  return math.max(math.min(x,mix),man)
end

-- Converts table to string for debug purposes
function tableToStr(name)
  if name == nil then
    return nil
  elseif type(name) ~= "table" then
    return tostring(name)
  end
  
  function keyPrep(key)
    if type(key) == "string" then
      return '"' .. key .. '"'
    else
      return key
    end
  end
  
  local returnStr = "{"
  
  for k,v in pairs(name) do
    local key = keyPrep(k)
    if type(v) == "table" then
      local tableStr = tableToStr(v)
      returnStr = returnStr .. '[' .. key .. '] = ' .. tableStr .. ","
    elseif type(v) == "boolean" then
      returnStr = returnStr ..'[' .. key .. '] = ' .. (v and "true" or "false") .. ","
    elseif type(v) == "string" then
      returnStr = returnStr ..'[' .. key .. '] = [[' .. v .. ']],'
    else
      returnStr = returnStr ..'[' .. key .. '] = ' .. tostring(v) .. ","
    end
  end
  return returnStr:sub(1, -2) .. "}"
end

-- Runs draw function, but creates shadow offset by one pixel in both x and y
--   e.g. drawShadow(love.graphics.draw, sprite, x, y, etc)
function drawShadow(...)
  args = {...}
  local func = args[1]
  table.remove(args, 1)
  local r,g,b,a = love.graphics.getColor()
  
  love.graphics.setColor(0,0,0)
  args[2], args[3] = args[2] + 1, args[3] + 1
  func(unpack(args))
  
  love.graphics.setColor(r,g,b,a)
  args[2], args[3] = args[2] - 1, args[3] - 1
  func(unpack(args))
end

-- If table contains a value
function contains(tab, val)
  for k, v in pairs(tab) do
    if v == val then
      return true
    end
  end
  return false
end

-- Draw an image (optionally centered), with certain scaling
function drawImg(img, x, y, scale, center)
  local center = center or false
  local x = (x or 0) - bti(center) * (img:getWidth() * scale / 2)
  local y = (y or 0) - bti(center) * (img:getHeight() * scale / 2)
  love.graphics.draw(img, x, y, 0, scale or 1, scale or 1)
end