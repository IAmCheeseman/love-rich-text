

local RichText = require("richtext")

local time = 0

RichText.addEffect("color", function(str, text, args, info)
  text:setFgColor(args.r, args.g, args.b, args.a or 1)
end)

RichText.addEffect("scale", function(str, text, args, info)
  local scalex = args.x or args.xy
  local scaley = args.y or scalex
  text:setScale(scalex, scaley)
end)

RichText.addEffect("skew", function(str, text, args, info)
  local skewx = args.x or args.xy or 0
  local skewy = args.y or 0
  text:setSkew(skewx, skewy)
end)

RichText.addEffect("rotate", function(str, text, args, info)
  local rot = math.rad(args.deg) or args.rad
  text:setRotation(rot)
end)

RichText.addEffect("wave", function(str, text, args, info)
  local amp = args.amp or 2
  local freq = args.freq or 5

  local percentage = info.index / info.length

  local y = math.sin(percentage + time * freq) * amp
  text:setPosition(0, y)
end)

RichText.addEffect("shake", function(str, text, args, info)
  local freq = args.freq or 12
  local amp = args.amp or 3
  local xOffset = args.xOffset or 100
  local t = time * freq + info.index
  local x = love.math.noise(t) * 2 - 1
  local y = love.math.noise(t + xOffset) * 2 - 1
  text:setPosition(x * amp, y * amp)
end)

local format = [[
  {color r=1 g=0 b=1}Hello, {/color}{shake}world{/shake}!
  {scale xy=2}SCALED{/scale} {rotate deg=12}Rotated!{/rotate}
  {skew x=-1}Skew'd!{/skew}
]]
local text = RichText.new(love.graphics.newFont(20), format)

function love.update(dt)
  time = time + dt

  text:render()
end

function love.draw()
  love.graphics.setColor(1, 1, 1)
  local tw, th = text.font:getWidth(text.rawText), text.font:getHeight()
  local ww, wh = love.graphics.getDimensions()
  text:draw(ww / 2 - tw / 2, wh / 2 - th / 2)
end
