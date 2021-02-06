
local txt = lui.new('TextInput', {
	x = 300,
	y = 100,
	width = 180,
	font = love.graphics.newFont(11),
})
txt.height = txt.font:getHeight() + 8

lui.new('Text', {
	x = txt.x + 0,
	y = txt.y + txt.height,
	text = "",
}).onPreDraw = function(me)
	me.text = "pos=" .. txt:getCursorPosition()
end

lui.new('Text', {
	x = txt.x + 60,
	y = txt.y + txt.height,
	text = "",
}).onPreDraw = function(me)
	me.text = "len=" .. txt:getLengthUtf8()
end

lui.new('Text', {
	x = txt.x + 120,
	y = txt.y + txt.height,
	text = "",
}).onPreDraw = function(me)
	me.text = "bytes=" .. txt:getLength()
end
