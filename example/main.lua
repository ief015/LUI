lui = require 'lui/lui'

function love.load( arg, unfilteredArg )
	txtOutput = lui.new('Text', {
		text = "Hello, text!",
		x = 5,
		y = 5,
	})
	wnd = lui.new('Window', {
		title = "Print",
		x = 40,
		y = 40,
		width = 140,
		height = 100,
	})
	txtInput = wnd:new('TextInput', {
		textPreview = "Type here",
		x = 10,
		y = 10,
		width = 120,
	})
	btnPrint = wnd:new('Button', {
		text = "Print",
		x = 10,
		y = 10 + txtInput.y + txtInput.height,
		width = 60,
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
	love.graphics.clear( 0.15, 0.15, 0.15 )
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