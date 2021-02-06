
local txtCounter
local counter = 0

lui.new('Window', {
	x           = 100,
	y           = 100,
	width       = 200,
	height      = 200,
	closeButton = false,
	title       = "anchor L R T B"
}):new('Button', {
	anchor = {
		left   = 20,
		right  = 20,
		top    = 20,
		bottom = 20,
	},
})

lui.new('Window', {
	x           = 200,
	y           = 150,
	width       = 200,
	height      = 200,
	closeButton = false,
	title       = "anchor L R"
}):new('Button', {
	y      = 50,
	height = 40,
	anchor = {
		left   = 20,
		right  = 20,
	},
})

lui.new('Window', {
	x           = 300,
	y           = 200,
	width       = 200,
	height      = 200,
	closeButton = false,
	title       = "anchor T B"
}):new('Button', {
	x      = 50,
	width  = 80,
	anchor = {
		top     = 20,
		bottom  = 20,
	},
})

lui.new('Window', {
	x           = 400,
	y           = 250,
	width       = 200,
	height      = 200,
	closeButton = false,
	title       = "anchor T L"
}):new('Button', {
	width  = 80,
	height = 40,
	anchor = {
		top   = 20,
		left  = 20,
	},
})

lui.new('Window', {
	x           = 500,
	y           = 300,
	width       = 200,
	height      = 200,
	closeButton = false,
	title       = "anchor B R"
}):new('Button', {
	width  = 80,
	height = 40,
	anchor = {
		bottom = 20,
		right  = 20,
	},
})
