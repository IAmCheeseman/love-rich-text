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
  effects[name] = fn
end

function RichText.new(font, ...)
  local instance = setmetatable({}, RichText)

  instance.font = font
  instance.format = {...}
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
        self.fgColor = {1, 1, 1, 1}

        local info = {
          index = i,
          length = #effectOrStr
        }
        for _, effect in pairs(currentEffects) do
          effect.fn(char, self, effect.args, info)
        end

        self.text:add({self.fgColor, char}, x + self.charx, self.chary)
        x = x + self.font:getWidth(char)
      end
    elseif type(effectOrStr) == "table" then
      local effectName = effectOrStr[1]
      if effectName:sub(1, 1) == "/" then
        currentEffects[effectName:sub(2, -1)] = nil
      else
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