/******************************************************************************\
  Color support
\******************************************************************************/

local Clamp = math.Clamp
local floor = math.floor

local function RGBClamp(r,g,b)
	return Clamp(r,0,255),Clamp(g,0,255),Clamp(b,0,255)
end

local function ColorClamp(c)
	c.r = Clamp(c.r,0,255)
	c.g = Clamp(c.g,0,255)
	c.b = Clamp(c.b,0,255)
	c.a = Clamp(c.a,0,255)
	return c
end

--[[--Entity Colors--]]--

__e2setcost(2)

--- Returns the entities color
e2function vector entity:getColor()
	if !IsValid(this) then return {0,0,0} end

	local c = this:GetColor()
	return { c.r, c.g, c.b }
end

--- Returns the entities color and alpha
e2function vector4 entity:getColor4()
	if not IsValid(this) then return {0,0,0,0} end
	local c = this:GetColor()
	return {c.r,c.g,c.b,c.a}
end

--- Returns the entities alpha
e2function number entity:getAlpha()
	return IsValid(this) and this:GetColor().a or 0
end

--- Sets the entities color to given r,g,b
e2function void entity:setColor(r,g,b)
	if !IsValid(this) then return end
	if !isOwner(self, this) then return end

	this:SetColor(ColorClamp(Color(r,g,b,this:GetColor().a)))
end

--- Sets the entities color and alpha
e2function void entity:setColor(r,g,b,a)
	if !IsValid(this) then return end
	if !isOwner(self, this) then return end

	this:SetColor(ColorClamp(Color(r, g, b, this:IsPlayer() and this:GetColor().a or a)))
	this:SetRenderMode(this:GetColor().a == 255 and RENDERMODE_NORMAL or RENDERMODE_TRANSALPHA)
end

--- Sets the entities color to <c>
e2function void entity:setColor(vector c)
	if !IsValid(this) then return end
	if !isOwner(self, this) then return end

	this:SetColor(ColorClamp(Color(c[1],c[2],c[3],this:GetColor().a)))
end

--- Sets the entities color <c> and alpha <a>
e2function void entity:setColor(vector c, a)
	if !IsValid(this) then return end
	if !isOwner(self, this) then return end

	this:SetColor(ColorClamp(Color(c[1],c[2],c[3], this:IsPlayer() and this:GetColor().a or a)))
	this:SetRenderMode(this:GetColor().a == 255 and RENDERMODE_NORMAL or RENDERMODE_TRANSALPHA)
end

--- Sets the entities color and alpha to <c>
e2function void entity:setColor(vector4 c)
	if !IsValid(this) then return end
	if !isOwner(self, this) then return end

	this:SetColor(ColorClamp(Color(c[1],c[2],c[3], this:IsPlayer() and this:GetColor().a or c[4])))
	this:SetRenderMode(this:GetColor().a == 255 and RENDERMODE_NORMAL or RENDERMODE_TRANSALPHA)
end

--- Sets the entities alpha to <a>
e2function void entity:setAlpha(a)
	if !IsValid(this) then return end
	if !isOwner(self, this) then return end

	if this:IsPlayer() then return end
	
	local c = this:GetColor()
	c.a = Clamp(a, 0, 255)
	this:SetColor(c)
	this:SetRenderMode(c.a == 255 and RENDERMODE_NORMAL or RENDERMODE_TRANSALPHA)
end

--- Sets the entities render mode to <mode>
--- See [RENDERMODE Enum](http://wiki.garrysmod.com/page/Enums/RENDERMODE)
e2function void entity:setRenderMode(mode)
	if !IsValid(this) then return end
	if !isOwner(self, this) then return end
	if this:IsPlayer() then return end
	
	this:SetRenderMode(mode)
end

--[[--HSV Conversion--]]--

--- Converts <hsv> from the [HSV color space](http://en.wikipedia.org/wiki/HSV_color_space) to the [RGB color space](http://en.wikipedia.org/wiki/RGB_color_space)
e2function vector hsv2rgb(vector hsv)
	local col = HSVToColor(hsv[1], hsv[2], hsv[3])
	return { col.r, col.g, col.b }
end

--- Converts <hsv> from the [HSV color space](http://en.wikipedia.org/wiki/HSV_color_space) to the [RGB color space](http://en.wikipedia.org/wiki/RGB_color_space)
e2function vector hsv2rgb(h, s, v)
	local col = HSVToColor(h, s, v)
	return { col.r, col.g, col.b }
end

--- Converts <rgb> from the [RGB color space](http://en.wikipedia.org/wiki/RGB_color_space) to the [HSV color space](http://en.wikipedia.org/wiki/HSV_color_space)
e2function vector rgb2hsv(vector rgb)
	return { ColorToHSV(Color(rgb[1], rgb[2], rgb[3])) }
end

--- Converts <rgb> from the [RGB color space](http://en.wikipedia.org/wiki/RGB_color_space) to the [HSV color space](http://en.wikipedia.org/wiki/HSV_color_space)
e2function vector rgb2hsv(r, g, b)
	return { ColorToHSV(Color(r, g, b)) }
end

--[[--HSL Conversion--]]--

local function Convert_hue2rgb(p, q, t)
	if t < 0 then t = t + 1 end
	if t > 1 then t = t - 1 end
	if t < 1/6 then return p + (q - p) * 6 * t end
	if t < 1/2 then return q end
	if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end
	return p
end

local function Convert_hsl2rgb(h, s, l)
	local r = 0
	local g = 0
	local b = 0

	if s == 0 then
		r = l
		g = l
		b = l
	else
		local q = l + s - l * s
		if l < 0.5 then q = l * (1 + s) end
		local p = 2 * l - q
		r = Convert_hue2rgb(p, q, h + 1/3)
		g = Convert_hue2rgb(p, q, h)
		b = Convert_hue2rgb(p, q, h - 1/3)
	end

	return floor(r * 255), floor(g * 255), floor(b * 255)
end

local function Convert_rgb2hsl(r, g, b)
  	r = r / 255
  	g = g / 255
  	b = b / 255
	local max = math.max(r, g, b)
	local min = math.min(r, g, b)
	local h = (max + min) / 2
	local s = h
	local l = h

	if max == min then
		h = 0
		s = 0
	else
		local d = max - min
		s =  d / (max + min)
		if l > 0.5 then s = d / (2 - max - min) end
		if max == r then
			if g < b then
				h = (g - b) / d + 6
			else
				h = (g - b) / d + 0
			end
		elseif max == g then
			h = (b - r) / d + 2
		elseif max == b then
			h = (r - g) / d + 4
		end
		h = h / 6
	end

	return h, s, l
end

--- Converts <hsl> from the [HSL color space](http://en.wikipedia.org/wiki/HSL_color_space) to the [RGB color space](http://en.wikipedia.org/wiki/RGB_color_space)
e2function vector hsl2rgb(vector hsl)
	return { RGBClamp(Convert_hsl2rgb(hsl[1] / 360, hsl[2], hsl[3])) }
end

--- Converts <hsl> from the [HSL color space](http://en.wikipedia.org/wiki/HSL_color_space) to the [RGB color space](http://en.wikipedia.org/wiki/RGB_color_space)
e2function vector hsl2rgb(h, s, l)
	return { RGBClamp(Convert_hsl2rgb(h / 360, s, l)) }
end

--- Converts <rgb> from the [RGB color space](http://en.wikipedia.org/wiki/RGB_color_space) to the [HSL color space](http://en.wikipedia.org/wiki/HSL_color_space)
e2function vector rgb2hsl(vector rgb)
	local h,s,l = Convert_rgb2hsl(RGBClamp(rgb[1], rgb[2], rgb[3]))
	return { floor(h * 360), s, l }
end

--- Converts <rgb> from the [RGB color space](http://en.wikipedia.org/wiki/RGB_color_space) to the [HSL color space](http://en.wikipedia.org/wiki/HSL_color_space)
e2function vector rgb2hsl(r, g, b)
	local h,s,l = Convert_rgb2hsl(RGBClamp(r, g, b))
	return { floor(h * 360), s, l }
end

--[[--DigiScreen Conversion--]]--

local converters = {}
converters[0] = function(r, g, b)
	local r = Clamp(floor(r/28),0,9)
	local g = Clamp(floor(g/28),0,9)
	local b = Clamp(floor(b/28),0,9)

	return r*100000+g*10000+b*1000
end
converters[1] = false
converters[2] = function(r, g, b)
	return floor(r)*65536+floor(g)*256+floor(b)
end
converters[3] = function(r, g, b)
	return floor(r)*1000000+floor(g)*1000+floor(b)
end

--- Converts an RGB vector <rgb> to a number in digital screen format. <mode> Specifies a mode, either 0, 2 or 3, corresponding to Digital Screen color modes.
e2function number rgb2digi(vector rgb, mode)
	local conv = converters[mode]
	if not conv then return 0 end
	return conv(rgb[1], rgb[2], rgb[3])
end

--- Converts the RGB color (<r>,<g>,<b>) to a number in digital screen format. <mode> Specifies a mode, either 0, 2 or 3, corresponding to Digital Screen color modes.
e2function number rgb2digi(r, g, b, mode)
	local conv = converters[mode]
	if not conv then return 0 end
	return conv(r, g, b)
end
