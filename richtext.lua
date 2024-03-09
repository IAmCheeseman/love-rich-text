--[[
  The MIT License (MIT)

  Copyright (c) 2024 iamcheeseman

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.
]]

local RichText = {}
RichText.__index = RichText

local effects = {}

function RichText.addEffect(name, fn)
  if effects[name] then
    error("Effect '" .. name .. "' already exists.")
  end

  effects[name] = fn
end

function RichText.parse(format)
  local tformat = {}

  for match, text in format:gmatch("({.-})([^{]*)") do
    if match then
      local inner = match:sub(2, -2)
      local args = {}
      local name = inner:match("^[/%a]+")
      args[1] = name
      for k, v in inner:gmatch("(%w-)=([%w%.%-]+)") do
        if not v:match("^%-?%d*%.?%d*$") then
          error("Invalid effect arg '" .. k .. "'. Numbers are the only supported type.")
        end
        args[k] = tonumber(v)
      end
      table.insert(tformat, args)
    end
    if text then
      table.insert(tformat, text)
    end
  end

  return tformat
end

function RichText.new(font, format)
  local instance = setmetatable({}, RichText)

  instance.font = font
  if type(format) == "table" then
    instance.format = format
  elseif type(format) == "string" then
    instance.format = RichText.parse(format)
  end
  instance:render()

  return instance
end

function RichText:setFgColor(r, g, b, a)
  self.fgColor = {r, g, b, a}
end

function RichText:getFgColor()
  return unpack(self.fgColor)
end

function RichText:setPosition(x, y)
  self.charx = x
  self.chary = y
end

function RichText:getPosition()
  return self.charx, self.chary
end

function RichText:setScale(x, y)
  self.scalex = x
  self.scaley = y
end

function RichText:getScale()
  return self.scalex, self.scaley
end

function RichText:setSkew(x, y)
  self.skewx = x
  self.skewy = y
end

function RichText:getSkew()
  return self.skewx, self.skewy
end

function RichText:setRotation(rotation)
  self.rotation = rotation
end

function RichText:getRotation()
  return self.rotation
end

function RichText:render()
  self.text = love.graphics.newText(self.font)

  local currentEffects = {}

  local x = 0

  self.rawText = ""

  for _, effectOrStr in ipairs(self.format) do
    if type(effectOrStr) == "string" then
      self.rawText = self.rawText .. effectOrStr
      for i=1, #effectOrStr do
        local char = effectOrStr:sub(i, i)
        self.charx = 0
        self.chary = 0
        self.scalex = 1
        self.scaley = 1
        self.skewx = 0
        self.skewy = 0
        self.rotation = 0
        self.fgColor = {1, 1, 1, 1}

        local info = {
          index = i,
          length = #effectOrStr
        }
        for _, effect in pairs(currentEffects) do
          effect.fn(char, self, effect.args, info)
        end

        self.text:add(
          {self.fgColor, char},
          x + self.charx, self.chary,
          self.rotation,
          self.scalex, self.scaley,
          0, 0, self.skewx, self.skewy)
        x = x + self.font:getWidth(char) * self.scalex
      end
    elseif type(effectOrStr) == "table" then
      local effectName = effectOrStr[1]
      if effectName:sub(1, 1) == "/" then
        effectName = effectName:sub(2, -1)

        if not currentEffects[effectName] then
          error("Effect '" .. effectName .. "' does not have a matching opening tag.")
        end

        currentEffects[effectName] = nil
      else
        if not effects[effectName] then
          error("Effect '" .. effectName .. "' does not exist.")
        end

        currentEffects[effectName] = {
          fn = effects[effectName],
          args = effectOrStr,
        }
      end
    end
  end
end

function RichText:draw(...)
  love.graphics.draw(self.text, ...)
end

return RichText
