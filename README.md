# Rich Text

A simple library to use rich text effects.
Largely untested, so if you could use it and tell me about any bugs, that'd be great.

## API

```lua
local RichText = require("richtext")

-- A simple effect to color a section of text.
-- `text` is the rich text object.
-- `args` are the arguments passed to your effect.
-- `info` is a table containing the following info:
-- -- `char` is the character you're running your effect on.
-- -- `index` - the index of your char.
-- -- `length` - the length of the substring your effect is being applied to.
RichText.addEffect("color", function(text, args, info)
  text:setColor(args.r, args.g, args.b, args.a or 1)
end)

-- {color r=0 g=1 b=1} would use the effect defined above to change the color
-- {/color would end the effect, and return to white}
local text = RichText.new(
  love.graphics.newFont(20),
  "{color r=0 g=1 b=1}Hello! {/color}My name is {color r=1 g=0 b=0}iamcheeseman{/color}!")

-- If you don't like the parsing, you can just pass a table instead:
--[[
local text = RichText.new(
  love.graphics.newFont(20), 
  {{"color" r=0 g=1 b=1}, "Hello! ", {"/color"}, 
  "My name is ", {"color" r=1 g=0 b=0}, "iamcheeseman", {"/color"}, "!"})
]]

-- If you need to redraw your text, like, if you had an effect that changes over time, like a rainbow, then:
text:update()

function love.draw()
  text:draw(5, 5)
end
```

Here is how the above snippet looks:
![image](https://github.com/IAmCheeseman/love-rich-text/assets/64710123/1e365668-9415-484e-8f0a-2ca7e9b03b6f)
