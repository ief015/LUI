
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

--[[
local txtCounter
local counter = 0

local window = lui.new('Window', {
	x = 200,
	y = 200,
	width = 300,
	height = 300,
	closeButton = false,
})

local button = window:new('Button', {
	x = 100,
	y = 80,
	width = 80,
	height = 50,
	text = "Hello!",
--	outline = { 0.75, 0.2, 0.2 },
--	outlineWidth = 1,
--	fill = { 0.5, 0.1, 0.1 },
})

txtCounter = window:new('Text', {
	text = "0",
	x = 200,
	y = 80,
})

button.onClick = function(me, button)
	if button ~= 1 then return end
	counter = counter + 1
	txtCounter.text = tostring(counter)
	if counter >= 10 then
		me.text = "...world?"
		me.locked = true
	end
end

window:new('Window', {
	x = 10,
	y = 10,
	width = 120,
	height = 80,
	title = "jamie window",
}):new('Button', {
	x = 30,
	y = 20,
	width = 30,
	height = 20,
	text = "!!!"
})
]]