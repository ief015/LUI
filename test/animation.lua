
local text = lui.new('Text', {
	x = 200,
	y = 20,
	text = "Test value: ",
})




local window = lui.new('Window', {
	width = 300,
	height = 300,
	closeButton = false,
})

window:anim('moveX', {
	{ delay=1, value=300, transition='sin' },
	{ delay=1, value=200, transition='sin' },
}, 200, { loops = -1 }):play()

window:anim('moveY', {
	{ delay=1, value=300, transition='sin' },
	{ delay=1, value=200, transition='sin' },
}, 200, { loops = -1 }):play()


function test.update(dt)
	
	window.x = window:anim('moveX').value
	window.y = window:anim('moveY').value
	
end