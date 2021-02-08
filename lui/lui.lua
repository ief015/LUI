------------------------------------------------------------------------------------------------------------------------
-- MIT License
-- 
-- Copyright (c) 2021 Nathan Cousins
-- 
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
-- 
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
------------------------------------------------------------------------------------------------------------------------


if lui ~= nil then return end
lui = { }

-- Enable or disable this interface entirely.
lui.enabled         = true

-- When true, child elements are scissored and can only render inside their parent's boundaries.
lui.culledRendering = true

-- Utilities for debugging.
lui.debug = { }

-- Enables or disables debugging mode.
lui.debug.enabled = false

-- When true, an outside bounds border is drawn on top every element.
lui.debug.drawBounds = true
lui.debug.colorBounds           = { 1, 0, 0, 1 } -- Default bounds colour
lui.debug.colorBoundsFocus      = { 1, 1, 0, 1 } -- Bounds colour if element has focus
lui.debug.colorBoundsInputFocus = { 0, 1, 0, 1 } -- Bounds colour if element has input focus

-- Internally used values not intended to be directly read or modified outside of LUI.
lui._ = { }

-- Registry for available element types.
lui._.registry = { }

-- Root/top-level element instances.
lui._.elements = { }

-- Elements currently being hovered over.
lui._.hoverElements = { }

-- Elements currently focused. Last element has input focus.
lui._.focusElements = { }


------------------------------------------------------------------------------------------------------------------------
local function checkarg( val, typ )
	local actual = type(val)
	assert(actual == typ, "invalid argument: expected "..typ..", got "..actual)
end


------------------------------------------------------------------------------------------------------------------------
local function clone( tbl )
	-- Modified from http://lua-users.org/wiki/CopyTable
	local copy
	if type(tbl) == 'table' then
		copy = {}
		for k,v in next, tbl, nil do
			copy[clone(k)] = clone(v)
		end
	else
		copy = tbl
	end
	return copy
end


------------------------------------------------------------------------------------------------------------------------
-- Register a new element type.
-- Unprovided element properties will be given default values during registry.
-- The master element table will be registered by reference.
-- string newType        : Name of the new element type. Name is case-insensitive.
--                         If type already exists, it will overwrite it.
-- Element masterElement : The master table used to create instances from.
-- Returns nil.
function lui.register( newType, masterElement )
	
	checkarg(newType, 'string')
	checkarg(masterElement, 'table')
	
	newType = string.lower(newType)
	
	for k,v in pairs(clone(lui._.defaults)) do
		if masterElement[k] == nil then
			masterElement[k] = v
		end
	end
	
	masterElement._.type = newType
	
	lui._.registry[newType] = masterElement
	
end


------------------------------------------------------------------------------------------------------------------------
-- Create a new instance of an element.
-- string element     : The type name of element to create. Case-insensitive.
-- [table properties] : (Optional) A table of properties to apply on the new instance.
-- [Element parent]   : (Optional) Parent element to attach the new element to.
-- Returns table: a new instance of the given element type.
function lui.new( element, properties, parent )
	
	checkarg(element, 'string')
	if properties ~= nil then
		checkarg(properties, 'table')
	end
	element = string.lower(element)
	
	local registeredElement = lui._.registry[element]
	assert(registeredElement ~= nil, "invalid element type given ("..element..")")
	
	-- Clone a new instance
	local newElement = setmetatable(clone(registeredElement), { __index = lui._.baseElement })
	setmetatable(newElement._.animator, { __index = lui._.baseAnimator })
	newElement._.parent = parent
	
	-- Apply user-defined properties
	if properties then
		for k,v in pairs(properties) do
			newElement[k] = v
		end
	end
	
	if parent == nil then
		table.insert(lui._.elements, newElement)
	else
		assert(lui.isvalid(parent), "invalid parent given")
		table.insert(parent._.elements, newElement)
	end
	
	if newElement.init then
		newElement:init()
	end
	
	return newElement
	
end


------------------------------------------------------------------------------------------------------------------------
function lui.destroy( element )
	
	if not lui.isvalid(element) then return end
	
	if element.destroyed then
		element:destroyed()
	end
	
	local p = element._.parent
	
	-- Disassociate with parent
	if p == nil then
		p = lui
	else
		element._.parent = nil
	end
	for i=1, #p._.elements do
		if p._.elements[i] == element then
			table.remove(p._.elements, i)
			break
		end
	end
	
	-- Become invalid
	element._.valid = false
	
	-- Child iterations don't need to disassociate
	local children = element._.elements
	element._.elements = { }
	
	-- Invalidate children
	for k,ch in ipairs(children) do
		lui.destroy(ch)
	end
	
end


------------------------------------------------------------------------------------------------------------------------
function lui.clear( )
	
	while #lui._.elements > 0 do
		
		lui.destroy(lui._.elements[1])
		
	end
	
	lui._.hoverElements = { }
	lui._.focusElements = { }
	
end


------------------------------------------------------------------------------------------------------------------------
function lui.update( dt, _parent )
	
	-- TODO: implement lui.culledRendering
	assert(lui.culledRendering, "lui.culledRendering not implemented")
	
	if not lui.enabled then return end
	
	if _parent == nil then
		
		-- Initial call, update hovering elements
		local tr = lui.trace(love.mouse.getPosition())
		local hovering = { }
		
		-- Include all unfocusable elements, and lastly the first focusable/blocking element
		for i=#tr, 1, -1 do
			local elem = tr[i]
			table.insert(hovering, elem)
			if elem.enabled and elem.focusable then
				break
			end
		end
		
		lui._.hoverElements = hovering
		
	end
	
	local p = ((_parent == nil) and lui or _parent)
	
	for k,elem in ipairs(p._.elements) do
		
		if elem.enabled then
			
			lui.invoke(elem, 'onPreUpdate')
			
			elem._.animator:update(dt)
			
			lui.invalidate(elem)
			
			if elem.update then
				elem:update(dt)
			end
			
			lui.update(dt, elem)
			
			lui.invoke(elem, 'onPostUpdate')
			
		end
		
	end
	
end


------------------------------------------------------------------------------------------------------------------------
function lui.draw( _parent )
	
	if not lui.enabled then return end
	
	if _parent == nil then
		-- LUI render completed
		love.graphics.setScissor()
	end
	
	local p = ((_parent == nil) and lui or _parent)
	
	for k,elem in ipairs(p._.elements) do
		
		if elem.enabled then
			
			love.graphics.push()
			love.graphics.translate(elem.x, elem.y)
			
			lui.invoke(elem, 'onPreDraw')
			
			-- Draw child element
			if elem.draw then
				elem:draw()
			end
			
			-- Draw nested children elements
			if #elem._.elements > 0 then
				
				local gx, gy = lui.getglobalpos(elem)
				local prevSci = { love.graphics.getScissor() }
				
				-- Nested children draw calls will be scissored within parent's dimensions
				love.graphics.intersectScissor(gx, gy, elem.width, elem.height)
				
				lui.draw(elem)
				
				-- Restore scissor
				love.graphics.setScissor(unpack(prevSci))
				
			end
			
			lui.invoke(elem, 'onPostDraw')
			
			if lui.debug.enabled then
				
				local hasInputFocus = lui.hasinputfocus(elem)
				local hasFocus = hasInputFocus or lui.hasfocus(elem)
				
				if hasInputFocus then
					love.graphics.setColor(lui.debug.colorBoundsInputFocus)
				elseif hasFocus then
					love.graphics.setColor(lui.debug.colorBoundsFocus)
				else
					love.graphics.setColor(lui.debug.colorBounds)
				end
				love.graphics.setLineWidth(1)
				love.graphics.rectangle('line',-0.5,-0.5,elem.width+1,elem.height+1)
				
			end
			
			love.graphics.pop()
			
		end
		
	end
	
	if _parent == nil then
		-- LUI render completed
		love.graphics.setScissor()
	end
	
end


------------------------------------------------------------------------------------------------------------------------
function lui.keypressed( key, scancode, isrepeat, _parent )
	
	if not lui.enabled then return end
	
	local p = ((_parent == nil) and lui or _parent)
	
	for k,elem in ipairs(p._.elements) do
		
		if elem.enabled then
			
			if elem.keypressed then
				elem:keypressed(key, scancode, isrepeat)
			end
			
			lui.keypressed(key, scancode, isrepeat, elem)
			
		end
		
	end
	
end


------------------------------------------------------------------------------------------------------------------------
function lui.keyreleased( key, scancode, _parent )
	
	if not lui.enabled then return end
	
	local p = ((_parent == nil) and lui or _parent)
	
	for k,elem in ipairs(p._.elements) do
		
		if elem.enabled then
			
			if elem.keyreleased then
				elem:keyreleased(key, scancode)
			end
			
			lui.keyreleased(key, scancode, elem)
			
		end
		
	end
	
end


------------------------------------------------------------------------------------------------------------------------
function lui.textedited( text, start, length, _parent )
	
	if not lui.enabled then return end
	
	local p = ((_parent == nil) and lui or _parent)
	
	for k,elem in ipairs(p._.elements) do
		
		if elem.enabled then
			
			if elem.textedited then
				elem:textedited(text, start, length)
			end
			
			lui.textedited(text, start, length, elem)
			
		end
		
	end
	
end


------------------------------------------------------------------------------------------------------------------------
function lui.textinput( text, _parent )
	
	if not lui.enabled then return end
	
	local p = ((_parent == nil) and lui or _parent)
	
	for k,elem in ipairs(p._.elements) do
		
		if elem.enabled then
			
			if elem.textinput then
				elem:textinput(text)
			end
			
			lui.textinput(text, elem)
			
		end
		
	end
	
end


------------------------------------------------------------------------------------------------------------------------
function lui.mousemoved( x, y, dx, dy, istouch, _parent )
	
	if not lui.enabled then return end
	
	local p = ((_parent == nil) and lui or _parent)
	
	for k,elem in ipairs(p._.elements) do
		
		if elem.enabled then
			
			if elem.mousemoved then
				elem:mousemoved(x - elem.x, y - elem.y, dx, dy, istouch)
			end
			
			lui.mousemoved(x - elem.x, y - elem.y, dx, dy, istouch, elem)
			
		end
		
	end
	
end


------------------------------------------------------------------------------------------------------------------------
function lui.mousepressed( x, y, button, istouch, presses, _parent )
	
	if not lui.enabled then return end
	
	local p = ((_parent == nil) and lui or _parent)
	
	if _parent == nil then
		-- Initial call, update focused elements
		lui._.focusElements = lui.trace(x, y, true)
		
		-- Bring focused elements to front
		local count = #lui._.focusElements
		if #lui._.focusElements > 0 then
			local front = lui._.focusElements[count]
			if lui.isvalid(front) then
				lui.bringalltofront(front)
			end
		end
	end
	
	for k,elem in ipairs(p._.elements) do
		
		if elem.enabled then
			
			if elem.mousepressed then
				elem:mousepressed(x - elem.x, y - elem.y, button, istouch, presses)
			end
			
			lui.mousepressed(x - elem.x, y - elem.y, button, istouch, presses, elem)
			
		end
		
	end
	
end


------------------------------------------------------------------------------------------------------------------------
function lui.mousereleased( x, y, button, istouch, presses, _parent )
	
	if not lui.enabled then return end
	
	local p = ((_parent == nil) and lui or _parent)
	
	for k,elem in ipairs(p._.elements) do
		
		if elem.enabled then
			
			if elem.mousereleased then
				elem:mousereleased(x - elem.x, y - elem.y, button, istouch, presses)
			end
			
			lui.mousereleased(x - elem.x, y - elem.y, button, istouch, presses, elem)
			
		end
		
	end
	
end


------------------------------------------------------------------------------------------------------------------------
function lui.wheelmoved( x, y, _parent )
	
	if not lui.enabled then return end
	
	local p = ((_parent == nil) and lui or _parent)
	
	for k,elem in ipairs(p._.elements) do
		
		if elem.enabled then
			
			if elem.wheelmoved then
				elem:wheelmoved(x, y)
			end
			
			lui.wheelmoved(x, y, elem)
			
		end
		
	end
	
end


------------------------------------------------------------------------------------------------------------------------
-- Returns true if the value givin is an Element, but does not check if it is valid. (See lui.isvalid)
function lui.iselement( element )
	
	local mt = getmetatable(element)
	return mt and ( mt.__index == lui._.baseElement )
	
end


------------------------------------------------------------------------------------------------------------------------
-- Returns true if the value given is an Element that is also valid.
function lui.isvalid( element )
	
	local mt = getmetatable(element)
	return mt and ( mt.__index == lui._.baseElement ) and ( element._.valid == true )
	
end


------------------------------------------------------------------------------------------------------------------------
function lui.trace( x, y, onlyFocusable )
	
	local results = { }
	local p = lui
	local finished = false
	
	repeat
		
		finished = true
		
		for i = #p._.elements, 1, -1  do
			
			local elem = p._.elements[i]
			
			if lui.isvalid(elem) and elem.enabled then
				
				local tx = x - elem.x
				local ty = y - elem.y
				
				if tx >= 0 and ty >= 0 and tx < elem.width and ty < elem.height then
					
					if elem.focusable or not onlyFocusable then
						
						table.insert(results, elem)
						p = elem
						finished = false
						x = tx
						y = ty
						break
						
					end
					
					--   OR, instead of the above if-block,
					--   use this and it will skip iterating inside unfocusable elements
					--   TODO: not yet sure which method would prove more useful...
					--[[       I think this alternative method would make more sense than the above?
					
					if elem.focusable then
						
						table.insert(results, elem)
						p = elem
						finished = false
						x = tx
						y = ty
						break
						
					elseif not onlyFocusable then
						
						-- Insert, but don't let it block further tracing
						table.insert(results, elem)
						
					end
					]]
					
				end
				
			end
			
		end
		
	until finished
	
	return results
	
end


------------------------------------------------------------------------------------------------------------------------
function lui.ishovering( element, x, y )
	
	local tr = (x == nil or y == nil) and lui._.hoverElements or lui.trace(x, y)
	
	for k,elem in ipairs(tr) do
		
		if elem == element then
			
			return true
			
		end
		
	end
	
	return false
	
end


------------------------------------------------------------------------------------------------------------------------
function lui.getglobalpos( element )
	
	if not lui.isvalid(element) then return 0, 0 end
	
	local gx = element.x
	local gy = element.y
	local p = element._.parent
	while p ~= nil do
		gx = gx + p.x
		gy = gy + p.y
		p = p._.parent
	end
	
	return gx, gy
	
end


------------------------------------------------------------------------------------------------------------------------
function lui.getfocuselement( )
	
	local count = #lui._.focusElements
	
	if count == 0 then return nil end
	
	return lui._.focusElements[count]
	
end


------------------------------------------------------------------------------------------------------------------------
function lui.gainfocus( element )
	
	if not lui.isvalid(element) then return end
	
	-- TODO: not tested
	lui._.focusElements = { element }
	
end


------------------------------------------------------------------------------------------------------------------------
function lui.bringtofront( element )
	
	if not lui.isvalid(element) then return end
	
	local p = element._.parent or lui
	
	local idx
	
	local count = #p._.elements
	
	for i=count, 1, -1 do
	
		local elem = p._.elements[i]
		
		if elem == element then
			
			idx = i
			break
			
		end
		
	end
	
	if idx and idx < count then
		
		table.insert(p._.elements, table.remove(p._.elements, idx))
		
	end
	
end


------------------------------------------------------------------------------------------------------------------------
function lui.bringalltofront( element )
	
	if not lui.isvalid(element) then return end
	
	local elem = element
	
	while elem ~= lui do
		
		lui.bringtofront(elem)
		
		elem = elem._.parent or lui
		
	end
	
	lui.bringtofront(elem)
	
end


------------------------------------------------------------------------------------------------------------------------
function lui.hasfocus( element )
	
	if not lui.isvalid(element) then return false end
	
	for k,elem in ipairs(lui._.focusElements) do
		
		if elem == element then
			
			return true
			
		end
		
	end
	
	return false
	
end

------------------------------------------------------------------------------------------------------------------------
function lui.hasinputfocus( element )
	
	if not lui.isvalid(element) then return false end
	
	local count = #lui._.focusElements
	
	if count > 0 then
		
		if lui._.focusElements[count] == element then
			
			return true
			
		end
		
	end
	
	return false
	
end


------------------------------------------------------------------------------------------------------------------------
function lui.invoke( element, event, ... )
	
	if not lui.isvalid(element) then return end
	
	-- TODO: support event as function?
	
	local hook = element[event]
	local htype = type(hook)
	
	if htype == 'function' then
		
		return hook(element, ...)
		
	elseif htype == 'table' then
		
		-- First hook to return a value is returned to the caller
		-- No further hooks will be called afterwards
		for i,fn in ipairs(hook) do
			
			local ret = { fn() }
			
			if #ret > 0 then
				return unpack(ret)
			end
			
		end
		
	end
	
end


------------------------------------------------------------------------------------------------------------------------
function lui.getElement( idx, element )
	
	if element == nil then
		element = lui
	end
	
	assert(idx > 0 and idx <= #element._.elements, "index out of range")
	
	return element._.elements[idx]
	
end


------------------------------------------------------------------------------------------------------------------------
function lui.getElements( element )
	
	if element == nil then
		element = lui
	end
	
	return { unpack(element._.elements) }
	
end


------------------------------------------------------------------------------------------------------------------------
function lui.getElementCount( element )
	
	if element == nil then
		element = lui
	end
	
	return #self._.elements
	
end


------------------------------------------------------------------------------------------------------------------------
function lui.event( element, event, func )
	
	if not lui.isvalid(element) then return nil end
	
	checkarg(event, 'string')
	checkarg(func, 'function')
	
	local hooks = element[event]
	
	-- TODO: is multiple callbacks per event even needed?
	if type(hooks) ~= 'table' then
		-- Any function assigned will be replaced
		hooks = { func }
		element[event] = hooks
	end
	
	table.insert(hooks, func)
	
	return element
	
end

------------------------------------------------------------------------------------------------------------------------
function lui.animation( element, name, keyframes, start, flags )
	
	if not lui.isvalid(element) then return nil end
	
	local animator = element._.animator
	
	if type(name) ~= 'string' then
		-- self:anim() returns animation state for this element
		return animator
	end
	
	if type(animator._anims) ~= 'table' then
		animator._anims = { }
	end
	
	if type(keyframes) ~= 'table' then
		-- self:anim('name') returns animation 'name'
		return animator._anims[name]
	end
	
	assert(start ~= nil, "start value cannot be nil")
	
	local newAnim = setmetatable({
		
		-- Public properties
		name  = name,
		start = start,
		value = start,
		
		-- Flags
		loops        = 0,
		deleteOnStop = false,
		
		-- Private properties for internal use only
		_animator = animator,
		_playing  = false,
		_position = 0,
		_frames   = { },
		_frameIdx = 0,
		_duration = 0,
		
	}, { __index = lui._.baseAnimation })
	animator._anims[name] = newAnim
	
	if type(flags) == 'table' then
		
		if flags.loops ~= nil then
			newAnim.loops = flags.loops
		end
		
		if flags.deleteOnStop ~= nil then
			newAnim.deleteOnStop = flags.deleteOnStop
		end
		
	end
	
	local duration = 0
	
	for i,kf in ipairs(keyframes) do
		
		local frame = { }
		
		for k,v in pairs(kf) do
			
			if k == 'delay' then
				
				assert(type(v) == 'number', "keyframe property 'delay' must be a number")
				frame.delay = math.max(0, v)
				
			elseif k == 'value' then
				
				frame.value = v
				
			elseif k == 'transition' then
				
				if type(v) == 'string' then
					
					assert(newAnim._transitions[v] ~= nil, "keyframe property 'transition' is invalid")
					frame.transition = v
					
				elseif type(v) == 'table' then
					
					assert(#v == 4, "keyframe property 'transition' is not a table of 4 numbers")
					for j=1,4 do
						assert(type(v[j]) == 'number', "keyframe property 'transition' is not a table of 4 numbers")
					end
					
					frame.transition = { unpack(v) }
					
				else
					
					error("keyframe property 'transition' must be a string or table")
					
				end
				
			elseif k == 'call' then
				
				assert(type(v) == 'function', "keyframe property 'call' must be a function")
				frame.call = v
				
			end
			
		end
		
		newAnim._duration = newAnim._duration + (frame.delay or 0)
		
		table.insert(newAnim._frames, frame)
		
	end
	
	return newAnim
	
	--[[ TODO: not yet implemented
	
	self:anim('name', keyframes, 0, flags) -- creates/overwrites and returns animation 'name', starting value 0
	self:anim('name')                      -- returns animation 'name', nil if doesn't exist
	self:anim('name'):play()               -- plays and returns animation 'name'
	self:anim('name'):pause()              -- pauses and returns animation 'name'
	self:anim('name'):stop()               -- stops playing and resets to the beginning, value will be assigned to ...
	                                       -- ... starting value. returns animation 'name'
	self:anim('name'):duration()           -- returns the duration of the animation in seconds
	self:anim('name'):tell()               -- returns the current position of the animation in seconds
	self:anim('name'):seek( offset )       -- sets the current position of the animation in seconds
	self:anim('name'):isPlaying()          -- returns true if animation is currently playing
	self:anim('name'):isPaused()           -- returns true if animation is currently paused
	self:anim('name'):isStopped()          -- returns true if animation is currently stopped
	self:anim('name'):delete()             -- deletes the animation from this element.
	
	self:anim('name').value                -- the current value of the animation
	self:anim('name').deleteOnStop         -- If true, the animation is automatically deleted when stopped.
	self:anim('name').loops                -- Number of time to loop the animation before stopping.
	
	-- Global animation functions?
	self:anim()         -- gets animation state for this element
	self:anim():play()  -- plays all animations
	self:anim():pause() -- pauses all animations
	self:anim():stop()  -- stops all animations
	self:anim():all()   -- get table of all animations (i.e. for name,anim in pairs(self:anim():all()) do ... end)
	self:anim():clear() -- deletes all animations
	
	When creating a new animation, name, keyframes, and start arguments are required, flags is optional.
	
	keyframes = {
		
		{
			
			-- Determines the amount of time in seconds it takes to transition from the previous frame (or beginning).
			-- Defaults 0. If delay is 0 or negative, value is applied immediately and callback function invoked, and immediately
			-- moves to the next keyframe.
			number delay,
			
			-- The final value when this keyframe is reached.
			-- Only number values transition between keyframes. Other value types will simply assign the new value when
			-- the keyframe is reached.
			-- Changing value types is allowed, if desired.
			anytype value,
			
			-- The type of transition to use for number values. Can be a string or table.
			-- Transition strings are:
			-- 'none', 'linear', 'ease', 'ease-in', 'ease-out', 'ease-in-out', 'sin', 'sin-inverse'
			-- A table can be used instead as parameters for a cubic-bezier transition.
			-- Only a table with a length of 4 is allowed. An error is raised if table format is incorrect.
			-- Format: { number x1, number y1, number x2, number y2 }
			-- Optional. Defaults 'linear'.
			string/table[4] transition,
			
			-- Callback function invoked when this keyframe is reached.
			-- Passes the new value as an argument.
			function( v ) call,
			
		}, ...
		
		
		-- Keyframes will be played in order that they were provided.
		-- An example:
		
		{ delay = 1, value = 10 },
		{ delay = 1 },
		{ delay = 2, value = 100,      transition = 'ease' },
		{ delay = 2, value = 1000000,  transition = {x1,y1,x2,y2} }, -- table given for custom cubic-bezier
		{ delay = 5, value = 10000000, call = function(val) doSomething() end }, 
		
	}
	
	transition curves are:
	'none'
	'linear'   -- = { 0,    0,   1,    1 } -- should be done without curves
	'ease'        = { 0.25, 0.1, 0.25, 1 }
	'ease-in'     = { 0.4,  0,   1,    1 }
	'ease-out'    = { 0,    0,   0.6,  1 }
	'ease-in-out' = { 0.4,  0,   0.6,  1 }
	'sin'         = { (pi-2)/pi, 0, 1 - (pi-2)/pi, 1}
	'sin-inverse' = { 0, (pi-2)/pi, 1, 1 - (pi-2)/pi}
	
	flags = {
		
		-- Number of time to loop the animation before stopping.
		-- If less than 0, repeats forever.
		-- If 0, doesn't repeat.
		-- If 1 or higher, repeats that many times before stopping.
		-- Defaults 0.
		number loops = 0,
		
		-- If true, the animation is automatically deleted when stopped.
		boolean deleteOnStop = false,
		
	}
	
	]]
	
end


------------------------------------------------------------------------------------------------------------------------
function lui.invalidate( element )
	
	-- Invalidate position and size based on anchoring
	
	if not lui.isvalid(element) then return end
	if type(element.anchor) ~= 'table' then return end
	
	local anchor = element.anchor
	local parent = element:getParent()
	
	if anchor.left then
		
		element.x = anchor.left
		
		if anchor.right then
			
			local pw = ( lui.iselement(parent) and parent.width or love.graphics.getWidth() )
			
			element.width = math.max(0, pw - anchor.left - anchor.right)
			
		end
		
	elseif anchor.right then
		
		local pw = ( lui.iselement(parent) and parent.width or love.graphics.getWidth() )
		
		element.x = pw - element.width - anchor.right
		
	end
	
	
	if anchor.top then
		
		element.y = anchor.top
		
		if anchor.bottom then
			
			local ph = ( lui.iselement(parent) and parent.height or love.graphics.getHeight() )
			
			element.height = math.max(0, ph - anchor.top - anchor.bottom)
			
		end
		
	elseif anchor.bottom then
		
		local ph = ( lui.iselement(parent) and parent.height or love.graphics.getHeight() )
		
		element.y = ph - element.height - anchor.bottom
		
	end
	
end


------------------------------------------------------------------------------------------------------------------------
-- Default values applied (by value) on every registered element type
lui._.defaults = {
	
	-- Default base properties
	x         = 0,
	y         = 0,
	width     = 0,
	height    = 0,
	focusable = true, -- While false, this element won't block mouse actions and cannot be focused.
	enabled   = true, -- While false, this element and children will not be visible, updated, nor recieve events.
	anchor    = { -- If nil, no anchor is used. Ignored if element has no parent (root element).
		-- TODO: implement
		left   = nil,
		right  = nil,
		top    = nil,
		bottom = nil,
	},
	
	-- Base private values
	-- (Internally used values not intended to be directly read or modified outside of LUI.)
	_ = {
		type     = '',   -- Element type name.
		parent   = nil,  -- Parent element containing this element.
		elements = { },  -- Children elements.
		valid    = true, -- Used to check if an element is destroyed.
		animator = { },  -- Animation state.
	},
	
}


------------------------------------------------------------------------------------------------------------------------
-- Metatable applied on all elements
lui._.baseElement = {
		
	-- Base methods
	
	anim = function( self, name, keyframes, start, flags )
		return lui.animation(self, name, keyframes, start, flags)
	end,
	
	bringToFront = function( self )
		return lui.bringtofront(self)
	end,
	
	destroy = function( self )
		return lui.destroy(self)
	end,
	
	-- TODO: is multiple callbacks per event even needed?
	event = function( self, event, func )
		return lui.event(self, event, func)
	end,
	
	getElement = function( self, idx )
		return lui.getElement( idx, self )
	end,
	
	getElements = function( self )
		return lui.getElements( self )
	end,
	
	getElementCount = function( self )
		return lui.getElementCount( self )
	end,
	
	getGlobalPos = function( self )
		return lui.getglobalpos(self)
	end,
	
	getLeft = function( self )
		return self.x
	end,
	
	getRight = function( self )
		return self.x + self.width
	end,
	
	getTop = function( self )
		return self.y
	end,
	
	getBottom = function( self )
		return self.y + self.height
	end,
	
	getParent = function( self )
		return self._.parent
	end,
	
	getType = function( self )
		return self._.type
	end,
	
	invoke = function( self, event, ... )
		return lui.invoke(self, event, ...)
	end,
	
	isType = function( self, type )
		return self._.type == string.lower(type)
	end,
	
	hasFocus = function( self )
		return lui.hasfocus(self)
	end,
	
	hasInputFocus = function( self )
		return lui.hasinputfocus(self)
	end,
	
	hasParent = function( self )
		return lui.isvalid(self._.parent)
	end,
	
	isHovering = function( self )
		return lui.ishovering(self)
	end,
	
	isValid = function( self )
		return lui.isvalid(self)
	end,
	
	new = function( self, element, properties )
		return lui.new(element, properties, self)
	end,
	
	-- Base events
	
	onPreUpdate   = nil, -- function( Element self, number dt )
	onPostUpdate  = nil, -- function( Element self, number dt )
	onPreDraw     = nil, -- function( Element self )
	onPostDraw    = nil, -- function( Element self )
	
}


------------------------------------------------------------------------------------------------------------------------
-- Metatable applied on the animator on all elements
lui._.baseAnimator = {
	
	-- plays all animations
	play = function( self )
		
		for i,kf in pairs(self._anims) do
			kf:play()
		end
		
	end,
	
	-- pauses all animations
	pause = function( self )
		
		for i,kf in pairs(self._anims) do
			kf:pause()
		end
		
	end,
	
	-- stops and resets all animations
	stop = function( self )
		
		for i,kf in pairs(self._anims) do
			kf:stop()
		end
		
	end,
	
	-- returns a copy table of all animations (i.e. for name,anim in pairs(self:anim():all()) do ... end)
	all = function( self )
		
		return { unpack(self._anims) }
		
	end,
	
	-- deletes all animations
	clear = function( self )
		
		self._anims = { }
		
	end,
	
	-- updates all animations
	update = function( self, dt )
		
		if self._anims == nil then return end
		
		for i,kf in pairs(self._anims) do
			kf:update(dt)
		end
		
	end,
	
}


------------------------------------------------------------------------------------------------------------------------
-- Metatable applied on all animation tables
lui._.baseAnimation = {
	
	_transitions = {
		-- Cubic-bezier formatted as { x1, y1, x2, y2 }
		['none']        = true,
		['linear']      = true, -- { 0,    0,   1,    1 } -- should be done without curves
		['ease']        = { 0.25, 0.1, 0.25, 1 },
		['ease-in']     = { 0.4,  0,   1,    1 },
		['ease-out']    = { 0,    0,   0.6,  1 },
		['ease-in-out'] = { 0.4,  0,   0.6,  1 },
		['sin']         = { (math.pi-2)/math.pi, 0, 1 - (math.pi-2)/math.pi, 1 },
		['sin-inverse'] = { 0, (math.pi-2)/math.pi, 1, 1 - (math.pi-2)/math.pi },
	},
	
	-- plays and returns animation 'name'
	play = function( self )
		
		self._playing = true
		
	end,
	
	-- pauses and returns animation 'name'
	pause = function( self )
		
		self._playing = false
		
	end,
	
	-- stops playing and resets to the beginning, value will be assigned to starting value
	-- returns animation 'name'
	stop = function( self )
		
		self._playing  = false
		self._position = 0
		self._frameIdx = 0
		
	end,
	
	-- returns the duration of the animation in seconds
	duration = function( self )
		
		return self._duration
		
	end,
	
	-- returns the current position of the animation in seconds
	tell = function( self )
		
		return self._position
		
	end,
	
	-- sets current position of the animation in seconds
	seek = function( self, seconds )
		
		-- TODO: implement
		error("not yet implemented")
		
		self:update(0) -- only need to update value
		
	end,
	
	-- returns true if animation is currently playing
	isPlaying = function( self )
		
		return self._playing
		
	end,
	
	-- returns true if animation is currently paused
	isPaused = function( self )
		
		return not self._playing
		
	end,
	
	-- returns true if animation is currently stopped
	isStopped = function( self )
		
		return not self._playing and self._position == 0 and self._frameIdx == 0
		
	end,
	
	-- deletes the animation from this element
	delete = function( self )
		
		self._animator._anims[self.name] = nil
		
	end,
	
	-- updates and advances the animation by 'dt' seconds
	update = function( self, dt )
		
		-- TODO: implement
		
	end,
	
}


------------------------------------------------------------------------------------------------------------------------
-- Setup standard theme
lui.theme = { }
lui.theme.color = { }
lui.theme.font  = { }

lui.theme.color.paneBackground      = { 0.20, 0.20, 0.20, 1 }
lui.theme.color.paneForeground      = { 0.30, 0.30, 0.30, 1 }
lui.theme.color.borderActive        = { 0.50, 0.50, 0.50, 1 }
lui.theme.color.borderInactive      = { 0.10, 0.10, 0.10, 1 }
lui.theme.color.button              = { 0.30, 0.30, 0.30, 1 }
lui.theme.color.buttonHover         = { 0.40, 0.40, 0.40, 1 }
lui.theme.color.buttonDown          = { 0.25, 0.25, 0.25, 1 }
lui.theme.color.buttonLock          = { 0.17, 0.17, 0.17, 1 }
lui.theme.color.text                = { 0.90, 0.90, 0.90, 1 }
lui.theme.color.textInactive        = { 0.10, 0.10, 0.10, 1 }
lui.theme.color.textInputBackground = { 0.25, 0.25, 0.25, 1 }

lui.theme.font.default     = love.graphics.newFont(12)
lui.theme.font.windowTitle = love.graphics.newFont(11)


------------------------------------------------------------------------------------------------------------------------
-- Load standard elements
require 'lui.Elements.Panel'
require 'lui.Elements.Text'
require 'lui.Elements.Image'
require 'lui.Elements.Button'
require 'lui.Elements.ScrollBar'
require 'lui.Elements.Window'
require 'lui.Elements.TextInput'

return lui