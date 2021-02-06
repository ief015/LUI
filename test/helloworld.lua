
local prev = lui.new('Panel', {
	x = 50,
	y = 50,
})

prev = lui.new('Text', {
	x = prev.x,
	y = prev.y + prev.height,
	text = "Hello, text",
})

prev = lui.new('Button', {
	x = prev.x,
	y = prev.y + prev.height,
})
prev.onClick = function( me, button )
	me.clickCounter = (me.clickCounter or 0) + (button == 1 and 1 or -1)
	me.text = tostring(me.clickCounter)
	if me.clickCounter >= 5 then
		me.locked = true
	end
end

prev = lui.new('TextInput', {
	x = prev.x,
	y = prev.y + prev.height,
	textPreview = "TextInput",
})

prev = lui.new('Window', {
	x = prev.x,
	y = prev.y + prev.height,
})



-- Hover element type (follows mouse)
lui.new('Text').onPreUpdate = function( me, dt )

	local mx, my = love.mouse.getPosition()
	local trace = lui.trace(mx, my)
	
	if #trace > 0 and trace[#trace] ~= me then
		me.enabled = true
		me.text = trace[#trace]:getType()
		me.x = mx + 16
		me.y = my
		me:bringToFront()
	else
		me.enabled = false
	end
	
end
