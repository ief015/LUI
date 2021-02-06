local TextInput = { }

TextInput.font        = lui.theme.font.default
TextInput.x           = 0
TextInput.y           = 0
TextInput.width       = 100
TextInput.height      = TextInput.font:getHeight() + 8
TextInput.text        = ""
TextInput.textPreview = ""
TextInput.locked               = false
TextInput.insertMode           = true -- false = Overtype, true = Insert
TextInput.characterLimit       = 0
TextInput.backgroundColor      = lui.theme.color.textInputBackground
TextInput.backgroundColorFocus = lui.theme.color.textInputBackground
TextInput.backgroundColorLock  = lui.theme.color.buttonLock
TextInput.borderColor          = lui.theme.color.borderInactive
TextInput.borderColorFocus     = lui.theme.color.borderActive
TextInput.borderColorLock      = lui.theme.color.borderInactive
TextInput.borderWidth          = 1
TextInput.cornerRadius         = 3
TextInput.textColor            = lui.theme.color.text
TextInput.textColorLock        = lui.theme.color.textInactive
TextInput.cursorColor          = lui.theme.color.text
TextInput.cursorBlinkRate      = 1
TextInput.cursorWidth          = 1
TextInput.textViewMargin       = 4


-- Called when the user finishes entering text (by hitting Return/Enter)
-- function(TextInput self)
-- TextInput self : This element.
TextInput.onTextEnter = nil

-- Called any time the user changes the text (by typing)
-- function(TextInput self)
-- TextInput self : This element.
TextInput.onTextChanged = nil


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
function TextInput:init( )
	
	self._cursorPos       = 0
	self._cursorTime      = 0
	self._cursorBlinkShow = true
	
	self._viewOffset = 0
	
end


------------------------------------------------------------------------------------------------------------------------
function TextInput:destroyed( )
	
end


------------------------------------------------------------------------------------------------------------------------
function TextInput:update( dt )
	
	if self.locked or not self:hasInputFocus() then return end
	
	local half = self.cursorBlinkRate / 2
	self._cursorTime = self._cursorTime + dt
	
	if self._cursorTime > half then
		self._cursorTime      = self._cursorTime - half
		self._cursorBlinkShow = not self._cursorBlinkShow
	end

end


------------------------------------------------------------------------------------------------------------------------
function TextInput:draw( )
	
	local focused = self:hasInputFocus()
	
	--[[ OLD DRAW CODE (Feb 3)
	-- Border
	love.graphics.setColor(
		self.locked and self.borderColorLock or
		focused and self.borderColorFocus or
		self.borderColor)
	love.graphics.rectangle('fill', 0, 0, self.width, self.height, self.cornerRadius )
	
	-- Background
	love.graphics.setColor(
		self.locked and self.backgroundColorLock or
		focused and self.backgroundColorFocus or
		self.backgroundColor)
	love.graphics.rectangle('fill', 1, 1, self.width - 2, self.height - 2, self.cornerRadius )
	]]
	
	local fillCol =
		self.locked and self.backgroundColorLock or
		focused and self.backgroundColorFocus or
		self.backgroundColor
	
	if self.borderWidth > 0 then
		
		local borderCol =
			self.locked and self.borderColorLock or
			focused and self.borderColorFocus or
			self.borderColor
		
		drawNiceRect(0, 0, self.width, self.height, self.borderWidth, self.cornerRadius, fillCol, borderCol)
		
	else
		
		love.graphics.rectangle('fill', 0, 0, self.width, self.height, self.cornerRadius)
		
	end
	
	-- Contents rendered outside of the textbox will be culled
	local gx, gy  = self:getGlobalPos()
	local prevSci = { love.graphics.getScissor() }
	local offset  = math.max(0, self.borderWidth)
	love.graphics.intersectScissor(gx + offset, gy + offset,
		math.max(self.width - offset * 2), math.max(0, self.height - offset * 2))
	
	-- Text
	if utf8.len(self.text) > 0 then
		
		love.graphics.setColor(
			self.locked and self.textColorLock or
			self.textColor)
		love.graphics.print(self.text, self.font, self.textViewMargin - self._viewOffset, self.textViewMargin)
		
	elseif utf8.len(self.textPreview) > 0 and not self.locked then
		
		love.graphics.setColor(self.textColorLock)
		love.graphics.print(self.textPreview, self.font, self.textViewMargin, self.textViewMargin)
		
	end
	
	-- Cursor
	if focused and not self.locked and self._cursorBlinkShow then
		
		love.graphics.setColor(self.cursorColor)
		love.graphics.setLineWidth(self.cursorWidth)
		
		local cursorX = self.textViewMargin + self:getCursorDistance() - self._viewOffset - 0.5
		
		if self.insertMode then
			
			love.graphics.line(cursorX, self.textViewMargin - 0.5,
				cursorX, self.textViewMargin - 0.5 + self.font:getHeight())
			
		else
			
			local low = self.textViewMargin - 0.5 + self.font:getHeight()
			local tail
			
			if self._cursorPos >= utf8.len(self.text) then
				tail = self.font:getWidth('_')
			else
				tail = self.font:getWidth(self:sub(self._cursorPos + 1, self._cursorPos + 1))
			end
			
			love.graphics.line(cursorX + 1, low, cursorX + math.floor(tail), low)
			
		end
		
	end
	
	-- Restore scissor
	love.graphics.setScissor(unpack(prevSci))
	
end


------------------------------------------------------------------------------------------------------------------------
function TextInput:keypressed( key, scancode, isrepeat )
	
	if self.locked or not self:hasInputFocus() then return end
	
	if key == 'backspace' then
		
		local changed = false
		
		if self._cursorPos == utf8.len(self.text) then
			self.text = self:sub(1, -2)
			changed = true
		elseif self._cursorPos > 0 then
			self.text = self:sub(1, self._cursorPos - 1) .. self:sub(self._cursorPos + 1)
			changed = true
		end
		
		self:setCursorPosition(math.max(0, self._cursorPos - 1))
		
		if changed then
			self:invoke('onTextChanged')
		end
		
	elseif key == 'delete' then
		
		local changed = false
		
		if self._cursorPos == 0 then
			self.text = self:sub(2)
			changed = true
		elseif self._cursorPos < utf8.len(self.text) then
			self.text = self:sub(1, self._cursorPos) .. self:sub(self._cursorPos + 2)
			changed = true
		end
		
		if changed then
			self:invoke('onTextChanged')
		end
		
	elseif key == 'return' then
		
		self:invoke('onTextEnter')
		
	elseif key == 'insert' then
		
		self.insertMode = not self.insertMode
		
	elseif key == 'left' then
		
		self:setCursorPosition(math.max(0, self._cursorPos - 1))
		
	elseif key == 'right' then
		
		self:setCursorPosition(self._cursorPos + 1)
		
	elseif key == 'home' then
		
		self:setCursorPosition(0)
		
	elseif key == 'end' then
		
		self:setCursorPosition(-1)
		
	end
	
	self:resetCursorBlink()
	
end


------------------------------------------------------------------------------------------------------------------------
function TextInput:keyreleased( key, scancode )
	
end


------------------------------------------------------------------------------------------------------------------------
function TextInput:textedited( text, start, length )
	
end


------------------------------------------------------------------------------------------------------------------------
function TextInput:textinput( text )
	
	if self.locked or not self:hasInputFocus() then return end
	
	if self.characterLimit > 0 then
		
		if utf8.len(self.text) >= self.characterLimit then return end
		
		-- Trim the input text to fit character limit
		local size = utf8.len(self.text) + utf8.len(text)
		
		if size > self.characterLimit then
			-- TODO: this needs to be tested with utf8
			local offset = utf8.offset(text, self.characterLimit - size - 1) or 0
			text = text:sub(1, offset)
			
		end
		
	end
	
	if self._cursorPos == utf8.len(self.text) then
		
		self.text = self.text .. text
		
	else
		
		if self.insertMode then
			self.text = self:sub(1, self._cursorPos) .. text .. self:sub(self._cursorPos + 1)
		else
			self.text = self:sub(1, self._cursorPos) .. text .. self:sub(self._cursorPos + 2)
		end
		
	end
	
	self:setCursorPosition(self._cursorPos + utf8.len(text))
	
	self:invoke('onTextChanged')
	
end


------------------------------------------------------------------------------------------------------------------------
function TextInput:mousemoved( x, y, dx, dy, istouch )
	
end


------------------------------------------------------------------------------------------------------------------------
function TextInput:mousepressed( x, y, button, istouch, presses )
	
	if self.locked or not self:hasInputFocus() then return end
	
	self:resetCursorBlink( )
	
end


------------------------------------------------------------------------------------------------------------------------
function TextInput:mousereleased( x, y, button, istouch, presses )
	
end


------------------------------------------------------------------------------------------------------------------------
function TextInput:wheelmoved( x, y )
	
end


------------------------------------------------------------------------------------------------------------------------
function TextInput:resetCursorBlink( )
	
	self._cursorTime      = 0
	self._cursorBlinkShow = true
	
end


------------------------------------------------------------------------------------------------------------------------
function TextInput:getLength( )
	
	return string.len(self.text)
	
end


------------------------------------------------------------------------------------------------------------------------
function TextInput:getLengthUtf8( )
	
	return utf8.len(self.text)
	
end


------------------------------------------------------------------------------------------------------------------------
function TextInput:sub( i, j )
	
	i = utf8.offset(self.text, i) or 0
	
	if j ~= nil then
		j = (utf8.offset(self.text, j + 1) or 0) - 1
	end
	
	return string.sub(self.text, i, j)
	
end


------------------------------------------------------------------------------------------------------------------------
function TextInput:getCursorPosition( )
	
	return self._cursorPos
	
end


------------------------------------------------------------------------------------------------------------------------
function TextInput:setCursorPosition( idx )
	
	-- Allow negative index
	local len = utf8.len(self.text)
	idx = math.min(len, idx)
	if idx < 0 then
		idx = len - math.abs(idx + 1)
	end
	
	self._cursorPos = idx
	
	local dist = self:getCursorDistance()
	
	if dist < self._viewOffset then
		
		self._viewOffset = math.max(0, dist - (self.width * 0.5 + self.textViewMargin))
		
	else
		
		local textViewSize = self.width - (self.textViewMargin * 2)
		
		if dist > self._viewOffset + textViewSize then
			
			local max = self.font:getWidth(self.text) - self.textViewMargin
			self._viewOffset = math.min(max, dist - (self.width * 0.5 + self.textViewMargin))
			
		end
		
	end
	
end


------------------------------------------------------------------------------------------------------------------------
function TextInput:getCursorDistance( )
	
	if self._cursorPos >= utf8.len(self.text) then
		return self.font:getWidth(self.text)
	elseif self._cursorPos > 0 then
		return self.font:getWidth(self:sub(1, self._cursorPos))
	end
	
	return 0
	
end


lui.register('TextInput', TextInput)
