
local w1 = lui.new('Window', {
	x           = 100,
	y           = 100,
	width       = 200,
	height      = 200,
	closeButton = false,
	title       = "anchor L R T B"
})
w1:new('Button', {
	anchor = {
		left   = 20,
		right  = 20,
		top    = 20,
		bottom = 20,
	},
}).onClick = function(me) me.text = (tonumber(me.text) or 0) + 1 end


local w2 = lui.new('Window', {
	x           = 200,
	y           = 150,
	width       = 200,
	height      = 200,
	closeButton = false,
	title       = "anchor L R"
})
w2:new('Button', {
	y      = 50,
	height = 40,
	anchor = {
		left   = 20,
		right  = 20,
	},
}).onClick = function(me) me.text = (tonumber(me.text) or 0) + 1 end


local w3 = lui.new('Window', {
	x           = 300,
	y           = 200,
	width       = 200,
	height      = 200,
	closeButton = false,
	title       = "anchor T B"
})
w3:new('Button', {
	x      = 50,
	width  = 80,
	anchor = {
		top     = 20,
		bottom  = 20,
	},
}).onClick = function(me) me.text = (tonumber(me.text) or 0) + 1 end


local w4 = lui.new('Window', {
	x           = 400,
	y           = 250,
	width       = 200,
	height      = 200,
	closeButton = false,
	title       = "anchor T L"
})
w4:new('Button', {
	width  = 80,
	height = 40,
	anchor = {
		top   = 20,
		left  = 20,
	},
}).onClick = function(me) me.text = (tonumber(me.text) or 0) + 1 end


local w5 = lui.new('Window', {
	x           = 500,
	y           = 300,
	width       = 200,
	height      = 200,
	closeButton = false,
	title       = "anchor B R"
})
w5:new('Button', {
	width  = 80,
	height = 40,
	anchor = {
		bottom = 20,
		right  = 20,
	},
}).onClick = function(me) me.text = (tonumber(me.text) or 0) + 1 end


function test.update()
	
	local baseW, baseH = 200, 200
	
	local w = baseW * ((math.sin(love.timer.getTime()) + 1) / 2) + (baseW * 0.5)
	local h = baseH * ((math.cos(love.timer.getTime()) + 1 ) / 2) + (baseH * 0.5)
	
	w1.width = w
	w2.width = w
	w3.width = w
	w4.width = w
	w5.width = w
	
	w1.height = h
	w2.height = h
	w3.height = h
	w4.height = h
	w5.height = h
	
end