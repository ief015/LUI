local Window = { }

Window.x      = 0
Window.y      = 0
Window.width  = 200
Window.height = 200
Window.closeButton               = true
Window.title                     = "Window"
Window.titleColor                = lui.theme.color.text
Window.titleColorFocus           = lui.theme.color.text
Window.titleBackgroundColor      = lui.theme.color.paneForeground
Window.titleBackgroundColorFocus = lui.theme.color.paneForeground
Window.backgroundColor           = lui.theme.color.paneBackground
Window.borderColor               = lui.theme.color.borderInactive
Window.borderColorFocus          = lui.theme.color.borderActive
Window.borderWidth               = 1
Window.cornerRadius              = 2


-- Called when requested to close window.
-- function(Window self)
-- Window self : This element.
-- Returns [boolean]: (Optional) If true, try to cancel closing the window.
Window.onClose = nil


------------------------------------------------------------------------------------------------------------------------
local function drawNiceRect( x, y, w, h, borderWidth, cornerRadius, fillColor, borderColor )
	-- Draws a nice rectangle and inside borders with support for transparent colours.
	local offset       = math.max(0, borderWidth * 0.5)
	local cornerInside = math.max(0, cornerRadius - borderWidth * 0.5)
	love.graphics.setColor(fillColor)
	love.graphics.rectangle('fill', borderWidth, borderWidth, w - borderWidth * 2, h - borderWidth * 2, cornerInside)
	love.graphics.setColor(borderColor)
	love.graphics.setLineWidth(borderWidth)
	love.graphics.rectangle('line', offset, offset, w - borderWidth, h - borderWidth, cornerRadius)
end


------------------------------------------------------------------------------------------------------------------------
function Window:invalidate( )
	
	self._titleHeight = self._txtTitle.height + 6
	
	self._panel.width  = math.floor(self.width) - 4
	self._panel.height = math.floor(self.height - self._titleHeight) - 2
	self._panel.x      = 2
	self._panel.y      = math.floor(self._titleHeight)
	
	self._btnClose.width  = math.floor(self._txtTitle.height)
	self._btnClose.height = math.floor(self._txtTitle.height)
	self._btnClose.x      = math.floor(self.width - self._txtTitle.height) - 3
	self._btnClose.y      = 3
	
	self._btnClose.enabled = self.closeButton
	
end


------------------------------------------------------------------------------------------------------------------------
local function postDrawCloseButton( btnClose )
	
	-- Draw x-cross on close button
	
	local margin = 5 - 0.5
	
	--[[
	love.graphics.setColor(
		btnClose.locked and btnClose.borderColorLock or
		btnClose:isHeld() and btnClose.borderColorDown or
		btnClose._hover and btnClose.borderColorHover or
		lui.theme.color.borderInactive)
	]]
	
	--[[love.graphics.setColor(
		btnClose.locked and lui.theme.color.borderActive or
		btnClose._hover and lui.theme.color.text or
		lui.theme.color.textInactive)
	]]
	
	love.graphics.setLineWidth(1)
	love.graphics.setColor(lui.theme.color.text)
	love.graphics.line(margin, margin, btnClose.width - margin, btnClose.height - margin)
	love.graphics.line(margin, btnClose.height - margin, btnClose.width - margin, margin)
	
end


------------------------------------------------------------------------------------------------------------------------
function Window:new( element, properties )
	assert(lui.isvalid(self._panel), "could not add element: Panel is invalid in Window")
	return lui.new(element, properties, self._panel)
end


------------------------------------------------------------------------------------------------------------------------
function Window:init( )
	
	self._txtTitle = lui.new('Text', {
		x = 3,
		y = 3,
		text = self.title,
		textColor = { 0.9, 0.9, 0.9, 1 },
		font = lui.theme.font.windowTitle,
	}, self)
	
	self._btnClose = lui.new('Button', {
		text                 = "",
		borderWidth = 0,
		-- TODO: add to theme?
		backgroundColor      = { 0.3, 0.3, 0.3, 0 },
		backgroundColorLock  = { 0.32, 0.32, 0.32, 1 },
		backgroundColorHover = { 0.8, 0.2, 0.2, 1 },
		backgroundColorDown  = { 0.4, 0.1, 0.1, 1 },
	}, self)
	
	self._btnClose.onPostDraw = postDrawCloseButton
	
	self._panel = lui.new('Panel', {
		backgroundColor = self.backgroundColor,
		cornerRadius    = 0,
		borderWidth     = 1,
		borderColor     = { 0, 0, 0, 0.5 },
	}, self)
	
	self._btnClose.onClick = function(me, button)
		self:close()
	end
	
	self._held = false
	
	self:invalidate()
	
end


------------------------------------------------------------------------------------------------------------------------
function Window:destroyed( )
	
end


------------------------------------------------------------------------------------------------------------------------
function Window:update( dt )
	
	self:invalidate()
	
end


------------------------------------------------------------------------------------------------------------------------
function Window:draw( )
	
	local focus = self:hasFocus()
	
	self._txtTitle.textColor = focus and self.titleColorFocus or self.titleColor
	
	--[[ OLD DRAW CODE (Feb 3)
	if self:hasFocus() then
		love.graphics.setColor(self.borderColorFocus)
	else
		love.graphics.setColor(self.borderColor)
	end
	love.graphics.rectangle('fill', -1, -1, self.width + 2, self.height + 2, self.cornerRadius)
	
	love.graphics.setColor(self.titleBackgroundColor)
	love.graphics.rectangle('fill', 0, 0, self.width, self.height, self.cornerRadius)
	]]
	
	
	local titleBgCol = focus and
		self.titleBackgroundColorFocus or self.titleBackgroundColor
	
	if self.borderWidth > 0 then
		
		local borderCol = focus and self.borderColorFocus or self.borderColor
		
		drawNiceRect(0, 0, self.width, self.height,
			self.borderWidth, self.cornerRadius, titleBgCol, borderCol)
		
	else
		
		love.graphics.setColor(titleBgCol)
		love.graphics.rectangle('fill', 0, 0, self.width, self.height, self.cornerRadius)
		
	end
	
end


------------------------------------------------------------------------------------------------------------------------
function Window:keypressed( key, scancode, isrepeat )
	
end


------------------------------------------------------------------------------------------------------------------------
function Window:keyreleased( key, scancode )
	
end


------------------------------------------------------------------------------------------------------------------------
function Window:textedited( text, start, length )
	
end


------------------------------------------------------------------------------------------------------------------------
function Window:textinput( text )
	
end


------------------------------------------------------------------------------------------------------------------------
function Window:mousemoved( x, y, dx, dy, istouch )
	
	if self._held then
		
		self.x = self.x + dx
		self.y = self.y + dy
		
	end
	
end


------------------------------------------------------------------------------------------------------------------------
function Window:mousepressed( x, y, button, istouch, presses )
	
	if button == 1 and self:isHovering() then
		
		if x >= 0 and y >= 0 and x < self.width and y < self._titleHeight then
			
			self._held = true
			
		end
		
	end
	
end


------------------------------------------------------------------------------------------------------------------------
function Window:mousereleased( x, y, button, istouch, presses )
	
	if button == 1 then
		
		self._held = false
		
	end
	
end


------------------------------------------------------------------------------------------------------------------------
function Window:wheelmoved( x, y )
	
end


------------------------------------------------------------------------------------------------------------------------
function Window:close( forced )
	
	if self:invoke('onClose') and not forced then return end
	
	--[[ TODO: close anim
	self:anim('_closeAlpha', {
		start = 1.0,
		keyframes = {
			{ time = 1.0, value = 0.0, call = function() self:destroy() end }
		},
	}):play()
	]]
	
	self:destroy()
	
end


------------------------------------------------------------------------------------------------------------------------
function Window:getClientSize( )
	
	if not lui.isvalid(self._panel) then
		return 0, 0
	end
	
	return self._panel.width, self._panel.height
	
end


------------------------------------------------------------------------------------------------------------------------
function Window:setClientSize( w, h )
	
	if not lui.isvalid(self._panel) then
		return
	end
	
	-- TODO: too hardcoded... what if these change?
	self.width  = w + 4
	self.height = h + self._titleHeight + 2
	
	self:invalidate()
	
end


------------------------------------------------------------------------------------------------------------------------
function Window:getClientWidth( )
	
	if not lui.isvalid(self._panel) then
		return 0
	end
	
	return self._panel.width
	
end


------------------------------------------------------------------------------------------------------------------------
function Window:getClientHeight( )
	
	if not lui.isvalid(self._panel) then
		return 0
	end
	
	return self._panel.height
	
end


lui.register('Window', Window)
