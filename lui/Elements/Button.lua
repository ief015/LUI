local Button = { }

Button.width                = 60
Button.height               = 40
Button.text                 = "Button"
Button.locked               = false
Button.textColor            = lui.theme.color.text
Button.textColorHover       = lui.theme.color.text
Button.textColorDown        = lui.theme.color.text
Button.textColorLock        = lui.theme.color.textInactive
Button.font                 = lui.theme.font.default
Button.borderWidth          = 1
Button.borderColor          = lui.theme.color.borderInactive
Button.borderColorHover     = lui.theme.color.borderInactive
Button.borderColorDown      = lui.theme.color.borderInactive
Button.borderColorLock      = lui.theme.color.borderInactive
Button.backgroundColor      = lui.theme.color.button
Button.backgroundColorHover = lui.theme.color.buttonHover
Button.backgroundColorDown  = lui.theme.color.buttonDown
Button.backgroundColorLock  = lui.theme.color.buttonLock
Button.cornerRadius         = 3


-- Called when the button has been clicked.
-- function(Button self, number button)
-- Button self   : This element.
-- number button : Button index that clicked the button.
Button.onClick = nil


local utf8 = require 'utf8'


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
function Button:init( )
	
	self._held = { }
	self._hover = false
	
end


------------------------------------------------------------------------------------------------------------------------
function Button:destroyed( )
	
end


------------------------------------------------------------------------------------------------------------------------
function Button:update( dt )
	
	if self.locked then return end
	
	self._hover = self:isHovering()
	
end


------------------------------------------------------------------------------------------------------------------------
function Button:draw( )
	
	local down = self:isHeld()
	
	--[[ OLD DRAW CODE (Feb 3)
	-- Fill
	love.graphics.setColor(
		self.locked and self.backgroundColorLock or
		down and self.backgroundColorDown or
		self._hover and self.backgroundColorHover or
		self.backgroundColor)
	if self.borderWidth > 0 then
		local offset       = self.borderWidth * 0.5
		local insideRadius = math.max(0, self.cornerRadius - self.borderWidth * 0.5)
		love.graphics.rectangle('fill', self.borderWidth, self.borderWidth,
			self.width - self.borderWidth * 2, self.height - self.borderWidth * 2, insideRadius)
	else
		love.graphics.rectangle('fill', 0, 0, self.width, self.height, self.cornerRadius)
	end
	
	-- Border
	if self.borderWidth > 0 then
		
		love.graphics.setColor(
			)
		
		local offset = self.borderWidth * 0.5
		
		love.graphics.setLineWidth(self.borderWidth)
		love.graphics.rectangle('line', offset, offset,
			self.width - self.borderWidth, self.height - self.borderWidth, self.cornerRadius)
	end
	]]
	
	local fillcol =
		self.locked and self.backgroundColorLock or
		down and self.backgroundColorDown or
		self._hover and self.backgroundColorHover or
		self.backgroundColor
		
	if self.borderWidth > 0 then
		
		local bordercol =
			self.locked and self.borderColorLock or
			down and self.borderColorDown or
			self._hover and self.borderColorHover or
			self.borderColor
		
		drawNiceRect(0, 0, self.width, self.height, self.borderWidth, self.cornerRadius, fillcol, bordercol)
		
	else
		
		love.graphics.setColor(fillcol)
		love.graphics.rectangle('fill', 0, 0, self.width, self.height, self.cornerRadius)
		
	end
	
	-- Text
	if self.text and self.font and utf8.len(self.text) > 0 then
		
		love.graphics.setColor(
			self.locked and self.textColorLock or
			down and self.textColorDown or
			self._hover and self.textColorHover or
			self.textColor)
			
		local vertPos = math.floor(self.height / 2) - math.floor(self.font:getHeight() / 2)
		love.graphics.printf(self.text, self.font, down and 1 or 0, vertPos, self.width, 'center')
		
	end
	
end


------------------------------------------------------------------------------------------------------------------------
function Button:keypressed( key, scancode, isrepeat )
	
end


------------------------------------------------------------------------------------------------------------------------
function Button:keyreleased( key, scancode )
	
end


------------------------------------------------------------------------------------------------------------------------
function Button:textedited( text, start, length )
	
end


------------------------------------------------------------------------------------------------------------------------
function Button:textinput( text )
	
end


------------------------------------------------------------------------------------------------------------------------
function Button:mousemoved( x, y, dx, dy, istouch )
	
end


------------------------------------------------------------------------------------------------------------------------
function Button:mousepressed( x, y, button, istouch, presses )
	
	if self.locked then return end
	
	if self._hover then
		
		self._held[button] = true
		
	end
	
end


------------------------------------------------------------------------------------------------------------------------
function Button:mousereleased( x, y, button, istouch, presses )
	
	if self._held[button] then
		
		self._held[button] = false
		
		if not self.locked and self._hover then
			
			self:invoke('onClick', button)
			
		end
		
	end
	
end


------------------------------------------------------------------------------------------------------------------------
function Button:wheelmoved( x, y )
	
end


------------------------------------------------------------------------------------------------------------------------
function Button:isHeld( )
	for k,v in pairs(self._held) do
		if v then return true end
	end
	return false
end


lui.register('Button', Button)
