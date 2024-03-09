---@diagnostic disable: duplicate-set-field

local RichText = require("richtext")

local time = 0

RichText.addEffect("color", function(str, text, args, info)
  text:setFgColor(args.r, args.g, args.b, args.a or 1)
end)

RichText.addEffect("wave", function(str, text, args, info)
  local amp = args.amp or 2
  local freq = args.freq or 5

  local percentage = info.index / info.length

  local y = math.sin(percentage + time * freq) * amp
  text:setPosition(0, y)
end)

local format = "{color r=1 g=0 b=1}Hello, {/color}{wave freq=4 amp=7}world{/wave}!"
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
