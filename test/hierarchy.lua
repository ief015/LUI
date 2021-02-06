
for i,v in ipairs({"A","B","C"}) do
	
	lui.new('Window', {
		x = i * 100,
		y = i * 100,
		width = 300,
		height = 300,
		closeButton = false,
		title = "Window "..v.."1",
	}):new('Window', {
		x = 50,
		y = 50,
		width = 200,
		height = 200,
		closeButton = false,
		title = "Window "..v.."2",
	}):new('Window', {
		x = 40,
		y = 40,
		width = 100,
		height = 100,
		closeButton = false,
		title = "Window "..v.."3a",
	}):getParent():new('Window', {
		x = 60,
		y = 60,
		width = 100,
		height = 100,
		closeButton = false,
		title = "Window "..v.."3b",
	})
	
end
