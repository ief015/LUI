# LUI - pronounced 'Louie'
### Version 0.1.0 (Very early alpha - not yet ready for normal use)

A lightweight retained-mode GUI library for [LÖVE](https://love2d.org/). Get a lovely GUI up and running fast.


### Objective

LUI is the middle-ground between the immediate-mode GUI libraries and the powerhouse GUI libraries:

- Fast: Ready out-of-box for getting a retained UI running very quickly.
- Extendable: Easily create your own UI elements, if preferred.
- Minimalist: Not the end-all/be-all GUI library. Just the fundamental tools you need to create an effective, clean UI.


### Features

- Includes a clean and simple default interface with essentials
- Friendly API for making new element types
- Custom themes
- UTF-8 support
- Hierarchy-based parenting system
- Optional layout anchoring system **(Coming soon)**
- Z-Ordering  **(Coming soon)**
- Tab indexing **(Coming soon)**
- Element rendering is culled outside parent's bounds (togglable, on by default) **(Coming soon)**
- Many callbacks can be assigned to an element event
- Keyframe value animation system **(Coming soon)**


### Example

![example/main.lua](example/example.gif "example/main.lua")

```lua
lui = require 'lui/lui'

function love.load( )
	txtOutput = lui.new('Text', {
		text = "Hello, text!",
		x    = 5,
		y    = 5,
	})
	wnd = lui.new('Window', {
		title  = "Print",
		x      = 40,
		y      = 40,
		width  = 140,
		height = 100,
	})
	txtInput = wnd:new('TextInput', {
		textPreview = "Type here",
		x           = 10,
		y           = 10,
		width       = 120,
	})
	btnPrint = wnd:new('Button', {
		text   = "Print",
		x      = 10,
		y      = 10 + txtInput.y + txtInput.height,
		width  = 60,
		height = 25,
	})
	btnPrint.onClick = function()
		txtOutput.text = txtInput.text
	end
	love.keyboard.setKeyRepeat(true)
end

function love.update( dt )
	lui.update(dt)
end

function love.draw( )
	love.graphics.clear(0.15, 0.15, 0.15)
	lui.draw()
end

function love.keypressed( key, scancode, isrepeat )
	lui.keypressed(key, scancode, isrepeat)
end

function love.keyreleased( key, scancode )
	lui.keyreleased(key, scancode)
end

function love.textedited( text, start, length )
	lui.textedited(text, start, length)
end

function love.textinput( text )
	lui.textinput(text)
end

function love.mousemoved( x, y, dx, dy, istouch )
	lui.mousemoved(x, y, dx, dy, istouch)
end

function love.mousepressed( x, y, button, istouch, presses )
	lui.mousepressed(x, y, button, istouch, presses)
end

function love.mousereleased( x, y, button, istouch, presses )
	lui.mousereleased(x, y, button, istouch, presses)
end

function love.wheelmoved( x, y )
	lui.wheelmoved(x, y)
end
```
