
lui.new('Text', {
	x = 200,
	y = 20,
	text = "Focused: ",
}).onPreUpdate = function(me)
	local elem = lui.getfocuselement()
	if elem then
		me.text = "Focused: " .. (elem:isType('Window') and elem.title or elem:getType())
	end
end

for i = 1, 5 do
	
	local wnd = lui.new('Window', {
		title = "Window "..i,
		x = 100 + (i*50),
		y = 100 + (i*50),
		width = 300,
		height = 300,
	--	closeButton = false,
	})
	
	wnd.counter = 0
	
	local btn = wnd:new('Button', {
		x = 30,
		y = 20,
		width = 60,
		height = 40,
		text = "0",
	})
	
	btn.onClick = function(self, button)
		if button == 1 then
			wnd.counter = wnd.counter + 1
		elseif button == 2 then
			wnd.counter = wnd.counter - 1
		else
			return
		end
		self.text = wnd.counter
		if wnd.counter >= 10 then
			self.locked = true
		end
	end
	
	local txt = wnd:new('TextInput', {
		x = 30,
		y = 70,
		width = 200,
		text = "",
		textPreview = "Type something ...",
	})
	
	
	local txt2 = wnd:new('TextInput', {
		x = 30,
		y = 100,
		width = 200,
		text = "",
		textPreview = "(limit 10 chars)",
		characterLimit = 10,
	})
	
	local btnLockTxt = wnd:new('Button', {
		x = 240,
		y = txt.y,
		width = 50,
		height = txt.height,
		text = "Lock",
	})
	
	btnLockTxt.onClick = function(self, button)
		if button ~= 1 then return end
		if txt.locked then
			btnLockTxt.text = "Lock"
			txt.locked = false
		else
			btnLockTxt.text = "Unlock"
			txt.locked = true
		end
	end
	
	local txtCloseAgain = wnd:new('Text', {
		x = 170,
		y = 2,
		text = "Click again to close ...",
		enabled = false
	})
	
	wnd.onClose = function(self)
		if not txtCloseAgain.enabled then
			txtCloseAgain.enabled = true
			return true
		end
	end
	
	wnd:new('Window', {
		x=50,y=50,
		width=100,height=100,
		title=""
	})
	
end
