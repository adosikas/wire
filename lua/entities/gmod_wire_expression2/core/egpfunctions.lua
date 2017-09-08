local function Update(self,this)
	self.data.EGP.UpdatesNeeded[this] = true
end

__e2setcost(15)

--[[--Shapes--]]--

--- Creates a filled box with <pos> and <size>
e2function void wirelink:egpBox( number index, vector2 pos, vector2 size )
	if (!EGP:IsAllowed( self, this )) then return end
	local bool, obj = EGP:CreateObject( this, EGP.Objects.Names["Box"], { index = index, w = size[1], h = size[2], x = pos[1], y = pos[2] }, self.player )
	if (bool) then EGP:DoAction( this, self, "SendObject", obj ) Update(self,this) end
end

--- Creates a box outline with <pos> and <size>
e2function void wirelink:egpBoxOutline( number index, vector2 pos, vector2 size )
	if (!EGP:IsAllowed( self, this )) then return end
	local bool, obj = EGP:CreateObject( this, EGP.Objects.Names["BoxOutline"], { index = index, w = size[1], h = size[2], x = pos[1], y = pos[2] }, self.player )
	if (bool) then EGP:DoAction( this, self, "SendObject", obj ) Update(self,this) end
end

--- Creates a filled rounded box with <pos> and <size>. The radius of the corners is set by egpRadius
e2function void wirelink:egpRoundedBox( number index, vector2 pos, vector2 size )
	if (!EGP:IsAllowed( self, this )) then return end
	local bool, obj = EGP:CreateObject( this, EGP.Objects.Names["RoundedBox"], { index = index, w = size[1], h = size[2], x = pos[1], y = pos[2] }, self.player )
	if (bool) then EGP:DoAction( this, self, "SendObject", obj ) Update(self,this) end
end

--- Creates a rounded box outline with <pos> and <size>. The radius of the corners is set by egpRadius
e2function void wirelink:egpRoundedBoxOutline( number index, vector2 pos, vector2 size )
	if (!EGP:IsAllowed( self, this )) then return end
	local bool, obj = EGP:CreateObject( this, EGP.Objects.Names["RoundedBoxOutline"], { index = index, w = size[1], h = size[2], x = pos[1], y = pos[2] }, self.player )
	if (bool) then EGP:DoAction( this, self, "SendObject", obj ) Update(self,this) end
end

--- Controls the <radius> of a RoundedBox object
e2function void wirelink:egpRadius( number index, number radius )
	if (!EGP:IsAllowed( self, this )) then return end
	local bool, k, v = EGP:HasObject( this, index )
	if (bool) then
		if (EGP:EditObject( v, { radius = radius } )) then EGP:DoAction( this, self, "SendObject", v ) Update(self,this) end
	end
end

--- Returns the radius of a RoundedBox object
e2function number wirelink:egpRadius( number index )
	local bool, k, v = EGP:HasObject( this, index )
	if (bool) then
		if (v.radius) then
			return v.radius
		end
	end
	return -1
end

--- Creates a line between <pos1> and <pos2>
e2function void wirelink:egpLine( number index, vector2 pos1, vector2 pos2 )
	if (!EGP:IsAllowed( self, this )) then return end
	local bool, obj = EGP:CreateObject( this, EGP.Objects.Names["Line"], { index = index, x = pos1[1], y = pos1[2], x2 = pos2[1], y2 = pos2[2] }, self.player )
	if (bool) then EGP:DoAction( this, self, "SendObject", obj ) Update(self,this) end
end

--- Creates a filled circle (ellipsoid with size x!=y) with <pos> and <size>
e2function void wirelink:egpCircle( number index, vector2 pos, vector2 size )
	if (!EGP:IsAllowed( self, this )) then return end
	local bool, obj = EGP:CreateObject( this, EGP.Objects.Names["Circle"], { index = index, x = pos[1], y = pos[2], w = size[1], h = size[2] }, self.player )
	if (bool) then EGP:DoAction( this, self, "SendObject", obj ) Update(self,this) end
end

--- Creates a circle (ellipsoid with size x!=y) outline with <pos> and <size>
e2function void wirelink:egpCircleOutline( number index, vector2 pos, vector2 size )
	if (!EGP:IsAllowed( self, this )) then return end
	local bool, obj = EGP:CreateObject( this, EGP.Objects.Names["CircleOutline"], { index = index, x = pos[1], y = pos[2], w = size[1], h = size[2] }, self.player )
	if (bool) then EGP:DoAction( this, self, "SendObject", obj ) Update(self,this) end
end


--- Creates a filled triangle with the corners <v1>, <v2>, <v3>
e2function void wirelink:egpTriangle( number index, vector2 v1, vector2 v2, vector2 v3 )
	if (!EGP:IsAllowed( self, this )) then return end
	local vertices = { { x = v1[1], y = v1[2] }, { x = v2[1], y = v2[2] }, { x = v3[1], y = v3[2] } }
	local bool, obj = EGP:CreateObject( this, EGP.Objects.Names["Poly"], { index = index, vertices = vertices }, self.player )
	if (bool) then EGP:DoAction( this, self, "SendObject", obj ) Update(self,this) end
end

--- Creates a triangle outline with the corners <v1>, <v2>, <v3>
e2function void wirelink:egpTriangleOutline( number index, vector2 v1, vector2 v2, vector2 v3 )
	if (!EGP:IsAllowed( self, this )) then return end
	local vertices = { { x = v1[1], y = v1[2] }, { x = v2[1], y = v2[2] }, { x = v3[1], y = v3[2] } }
	local bool, obj = EGP:CreateObject( this, EGP.Objects.Names["PolyOutline"], { index = index, vertices = vertices }, self.player )
	if (bool) then EGP:DoAction( this, self, "SendObject", obj ) Update(self,this) end
end

--[[--Polygon Shapes--]]--

__e2setcost(20)

local function maxvertices() return EGP.ConVars.MaxVertices:GetInt() end

--- Creates a filled polygon with any number of corners. Accepts vector2(x,y) or vector4(x,y,u,v) for UV
--- This is drawn as a series of triangles ("Triangle-Fan") around the first vector.
--- To draw correctly all vectors must have "line-of-sight" inside the polygon to the first vector
--- and be ordered either clockwise or counterclockwise around it.
e2function void wirelink:egpPoly( number index, ... )
	if (!EGP:IsAllowed( self, this )) then return end
	if (!EGP:ValidEGP( this )) then return end
	local args = {...}
	if (#args<3) then return end -- No less than 3

	local max = maxvertices()

	-- Each arg must be a vec2 or vec4
	local vertices = {}
	for k,v in ipairs( args ) do
		if (typeids[k] == "xv2" or typeids[k] == "xv4") then
			n = #vertices
			if (n > max) then break end
			vertices[n+1] = { x = v[1], y = v[2] }
			if (typeids[k] == "xv4") then
				vertices[n+1].u = v[3]
				vertices[n+1].v = v[4]
			end
		end
	end

	local bool, obj = EGP:CreateObject( this, EGP.Objects.Names["Poly"], { index = index, vertices = vertices }, self.player )
	if (bool) then EGP:DoAction( this, self, "SendObject", obj ) Update(self,this) end
end

--- Works like egpPoly(index, ...) but with the vectors inside an array
e2function void wirelink:egpPoly( number index, array args )
	if (!EGP:IsAllowed( self, this )) then return end
	if (!EGP:ValidEGP( this )) then return end
	if (#args<3) then return end -- No less than 3

	local max = maxvertices()

	-- Each arg must be a vec2 or vec4
	local vertices = {}
	for k,v in ipairs( args ) do
		if istable(v) and (#v == 2 or #v == 4) then
			n = #vertices
			if (n > max) then break end
			vertices[n+1] = { x = v[1], y = v[2] }
			if (#v == 4) then
				vertices[n+1].u = v[3]
				vertices[n+1].v = v[4]
			end
		end
	end

	local bool, obj = EGP:CreateObject( this, EGP.Objects.Names["Poly"], { index = index, vertices = vertices }, self.player )
	if (bool) then EGP:DoAction( this, self, "SendObject", obj ) Update(self,this) end
end

--- Draws lines connecting all vectors in order and the last with the first
e2function void wirelink:egpPolyOutline( number index, ... )
	if (!EGP:IsAllowed( self, this )) then return end
	if (!EGP:ValidEGP( this )) then return end
	local args = {...}
	if (#args<3) then return end -- No less than 3

	local max = maxvertices()

	-- Each arg must be a vec2 or vec4
	local vertices = {}
	for k,v in ipairs( args ) do
		if (typeids[k] == "xv2" or typeids[k] == "xv4") then
			n = #vertices
			if (n > max) then break end
			vertices[n+1] = { x = v[1], y = v[2] }
			if (typeids[k] == "xv4") then
				vertices[n+1].u = v[3]
				vertices[n+1].v = v[4]
			end
		end
	end

	local bool, obj = EGP:CreateObject( this, EGP.Objects.Names["PolyOutline"], { index = index, vertices = vertices }, self.player )
	if (bool) then EGP:DoAction( this, self, "SendObject", obj ) Update(self,this) end
end

--- Like egpPolyOutline(index, ...) but with the vectors inside an array
e2function void wirelink:egpPolyOutline( number index, array args )
	if (!EGP:IsAllowed( self, this )) then return end
	if (!EGP:ValidEGP( this )) then return end
	if (#args<3) then return end -- No less than 3

	local max = maxvertices()

	-- Each arg must be a vec2 or vec4
	local vertices = {}
	for k,v in ipairs( args ) do
		if istable(v) and (#v == 2 or #v == 4) then
			n = #vertices
			if (n > max) then break end
			vertices[n+1] = { x = v[1], y = v[2] }
			if (#v == 4) then
				vertices[n+1].u = v[3]
				vertices[n+1].v = v[4]
			end
		end
	end

	local bool, obj = EGP:CreateObject( this, EGP.Objects.Names["PolyOutline"], { index = index, vertices = vertices }, self.player )
	if (bool) then EGP:DoAction( this, self, "SendObject", obj ) Update(self,this) end
end

--- Draws lines connecting all vectors in order.
--- Like egpPolyOutline without the last connecting line
e2function void wirelink:egpLineStrip( number index, ... )
	if (!EGP:IsAllowed( self, this )) then return end
	if (!EGP:ValidEGP( this )) then return end
	local args = {...}
	if (#args<3) then return end -- No less than 3

	local max = maxvertices()

	-- Each arg must be a vec2 or vec4
	local vertices = {}
	for k,v in ipairs( args ) do
		if (typeids[k] == "xv2" or typeids[k] == "xv4") then
			n = #vertices
			if (n > max) then break end
			vertices[n+1] = { x = v[1], y = v[2] }
			if (typeids[k] == "xv4") then
				vertices[n+1].u = v[3]
				vertices[n+1].v = v[4]
			end
		end
	end

	local bool, obj = EGP:CreateObject( this, EGP.Objects.Names["LineStrip"], { index = index, vertices = vertices }, self.player )
	if (bool) then EGP:DoAction( this, self, "SendObject", obj ) Update(self,this) end
end

--- Like egpLineStrip(index, ...) but with the vectors inside an array
e2function void wirelink:egpLineStrip( number index, array args )
	if (!EGP:IsAllowed( self, this )) then return end
	if (!EGP:ValidEGP( this )) then return end
	if (#args<3) then return end -- No less than 3

	local max = maxvertices()

	-- Each arg must be a vec2 or vec4
	local vertices = {}
	for k,v in ipairs( args ) do
		if istable(v) and (#v == 2 or #v == 4) then
			n = #vertices
			if (n > max) then break end
			vertices[n+1] = { x = v[1], y = v[2] }
			if (#v == 4) then
				vertices[n+1].u = v[3]
				vertices[n+1].v = v[4]
			end
		end
	end

	local bool, obj = EGP:CreateObject( this, EGP.Objects.Names["LineStrip"], { index = index, vertices = vertices }, self.player )
	if (bool) then EGP:DoAction( this, self, "SendObject", obj ) Update(self,this) end
end

--- Add vertices to an existing polygon object
e2function void wirelink:egpAddVertices( number index, array args )
	if (!EGP:IsAllowed( self, this )) then return end
	if (!EGP:ValidEGP( this )) then return end
	if (#args<3) then return end -- No less than 3

	local bool, k, v = EGP:HasObject( this, index )
	if (bool) then

		local max = maxvertices()

		-- Each arg must be a vec2 or vec4
		local vertices = {}
		for k,v in ipairs( args ) do
			if istable(v) and (#v == 2 or #v == 4) then
				n = #vertices
				if (n > max) then break end
				vertices[n+1] = { x = v[1], y = v[2] }
				if (#v == 4) then
					vertices[n+1].u = v[3]
					vertices[n+1].v = v[4]
				end
			end
		end

		if (EGP:EditObject( v, { vertices = vertices } )) then
			EGP:InsertQueue( this, self.player, EGP._SetVertex, "SetVertex", index, vertices, true )
			Update(self,this)
		end
	end
end

__e2setcost(15)

--- Creates a filled Wedge (slice of cake). Create like egpCircle and set the size of the slice with egpSize(degrees)
e2function void wirelink:egpWedge( number index, vector2 pos, vector2 size )
	if (!EGP:IsAllowed( self, this )) then return end
	local bool, obj = EGP:CreateObject( this, EGP.Objects.Names["Wedge"], { index = index, x = pos[1], y = pos[2], w = size[1], h = size[2] }, self.player )
	if (bool) then EGP:DoAction( this, self, "SendObject", obj ) Update(self,this) end
end

--- Creates a Wedge Outline (slice of cake). Create like egpCircle and set the size of the slice with egpSize(degrees)
--- Cannot control width of the outline
e2function void wirelink:egpWedgeOutline( number index, vector2 pos, vector2 size )
	if (!EGP:IsAllowed( self, this )) then return end
	local bool, obj = EGP:CreateObject( this, EGP.Objects.Names["WedgeOutline"], { index = index, x = pos[1], y = pos[2], w = size[1], h = size[2] }, self.player )
	if (bool) then EGP:DoAction( this, self, "SendObject", obj ) Update(self,this) end
end

--[[--Text--]]--

--- Creates a simple <text> at <pos>
e2function void wirelink:egpText( number index, string text, vector2 pos )
	if (!EGP:IsAllowed( self, this )) then return end
	local bool, obj = EGP:CreateObject( this, EGP.Objects.Names["Text"], { index = index, text = text, x = pos[1], y = pos[2] }, self.player )
	if (bool) then EGP:DoAction( this, self, "SendObject", obj ) Update(self,this) end
end

--- Creates a box with <pos> and <size> in which <text> will be displayed
--- Unlike egpText, this object supports automatic (between words) and manual (`\n`) linebreaks
--- Does not display text that doesn't fit
e2function void wirelink:egpTextLayout( number index, string text, vector2 pos, vector2 size )
	if (!EGP:IsAllowed( self, this )) then return end
	local bool, obj = EGP:CreateObject( this, EGP.Objects.Names["TextLayout"], { index = index, text = text, x = pos[1], y = pos[2], w = size[1], h = size[2] }, self.player )
	if (bool) then EGP:DoAction( this, self, "SendObject", obj ) Update(self,this) end
end

__e2setcost(10)

--- Changes the <text> of an existing object
e2function void wirelink:egpSetText( number index, string text )
	if (!EGP:IsAllowed( self, this )) then return end
	local bool, k, v = EGP:HasObject( this, index )
	if (bool) then
		if (EGP:EditObject( v, { text = text } )) then EGP:DoAction( this, self, "SendObject", v ) Update(self,this) end
	end
end

--- Changes horizontal alignment: 0=left, 1=center, 2=right
e2function void wirelink:egpAlign( number index, number halign )
	if (!EGP:IsAllowed( self, this )) then return end
	local bool, k, v = EGP:HasObject( this, index )
	if (bool) then
		if (EGP:EditObject( v, { halign = math.Clamp(halign,0,2) } )) then EGP:DoAction( this, self, "SendObject", v ) Update(self,this) end
	end
end

--- Changes horizontal and vertical alignment: 0=left/top, 1=center, 2=right/bottom
e2function void wirelink:egpAlign( number index, number halign, number valign )
	if (!EGP:IsAllowed( self, this )) then return end
	local bool, k, v = EGP:HasObject( this, index )
	if (bool) then
		if (EGP:EditObject( v, { valign = math.Clamp(valign,0,2), halign = math.Clamp(halign,0,2) } )) then EGP:DoAction( this, self, "SendObject", v ) Update(self,this) end
	end
end

--- Changes the <font> of the text element. The following fonts are allowed:
--- WireGPU_ConsoleFont, Coolvetica, Arial, Lucida Console, Trebuchet,
--- Courier New, Times New Roman, ChatFont, Marlett, Roboto
e2function void wirelink:egpFont( number index, string font )
	if (!EGP:IsAllowed( self, this )) then return end
	local bool, k, v = EGP:HasObject( this, index )
	if (bool) then
		local fontid = 0
		for k,v in ipairs( EGP.ValidFonts ) do
			if (v:lower() == font:lower()) then
				fontid = k
				break
			end
		end
		if (EGP:EditObject( v, { fontid = fontid } )) then EGP:DoAction( this, self, "SendObject", v ) Update(self,this) end
	end
end

--- Changes the <font> and font <size> of the text element. See egpFont(index, font) for a list of fonts
e2function void wirelink:egpFont( number index, string font, number size )
	if (!EGP:IsAllowed( self, this )) then return end
	local bool, k, v = EGP:HasObject( this, index )
	if (bool) then
		local fontid = 0
		for k,v in ipairs( EGP.ValidFonts ) do
			if (v:lower() == font:lower()) then
				fontid = k
				break
			end
		end
		if (EGP:EditObject( v, { fontid = fontid, size = size } )) then EGP:DoAction( this, self, "SendObject", v ) Update(self,this) end
	end
end

--[[--Texture Filtering--]]--

--- Changes the texture filter used to draw the object. Works on objects that draw a material.
--- See _TEXFILTER constants (POINT=sharp, ANISOTROPIC=blurry/default)
e2function void wirelink:egpFiltering( number index, number filtering )
	if (!EGP:IsAllowed( self, this )) then return end
	local bool, k, v = EGP:HasObject( this, index )
	if (bool) then
		if (EGP:EditObject( v, { filtering = math.Clamp(filtering,0,3) } )) then EGP:DoAction( this, self, "SendObject", v ) Update(self,this) end
	end
end
--- Changes the texture filter used to draw all EGP Objects. Works only on EGP Screens.
--- See _TEXFILTER constants (POINT=sharp, ANISOTROPIC=blurry/default)
e2function void wirelink:egpGlobalFiltering( number filtering )
	if (!EGP:IsAllowed( self, this )) then return end
	if this:GetClass() == "gmod_wire_egp" then -- Only Screens use GPULib and can use global filtering
		EGP:DoAction( this, self, "EditFiltering", math.Clamp(filtering, 0, 3) )
	end
end

for _,cname in ipairs({ "NONE", "POINT", "LINEAR", "ANISOTROPIC" }) do
	local value = TEXFILTER[cname]
	if value < 0 or value > 3 then
		print("WARNING: TEXFILTER."..cname.."="..value.." out of expected range (0-3). Please adjust code to udpdated values. Skipping...")
		-- Update clamp for both filtering functions above as well as write/readUInt(filtering,2) in egp baseclass+poly netcode.
	else
		E2Lib.registerConstant("TEXFILTER_"..cname, value)
	end
end

--[[--3D Tracker--]]--

--- Creates an invisible object that stays "infront" of the world <pos>.
--- Parent other objects to this to make them follow. Works best with HUD
e2function void wirelink:egp3DTracker( number index, vector pos )
	if (!EGP:IsAllowed( self, this )) then return end
	local bool, obj = EGP:CreateObject( this, EGP.Objects.Names["3DTracker"], { index = index, target_x = pos[1], target_y = pos[2], target_z = pos[3] }, self.player )
	if (bool) then EGP:DoAction( this, self, "SendObject", obj ) Update(self,this) end
end

__e2setcost(10)

--- Changes the <pos> the 3D Tracker uses
e2function void wirelink:egpPos( number index, vector pos )
	if (!EGP:IsAllowed( self, this )) then return end
	local bool, k, v = EGP:HasObject( this, index )
	if (bool) then
		if (EGP:EditObject( v, { target_x = pos[1], target_y = pos[2], target_z = pos[3] } )) then EGP:DoAction( this, self, "SendObject", v ) Update(self,this) end
	end
end

--- Parents the 3D Tracker to an <entity> instead of a world position
--- Use egpUnParent to remove parent
e2function void wirelink:egpParent( number index, entity parent )
	if not parent or not parent:IsValid() then return end
	if (!EGP:IsAllowed( self, this )) then return end

	local bool, k, v = EGP:HasObject( this, index )
	if bool and v.Is3DTracker then
		if v.parententity == parent then return end -- Already parented to that
		v.parententity = parent

		EGP:DoAction( this, self, "SendObject", v )
		Update(self,this)
	end
end

--- Returns the entity a 3D Tracker is parented to
e2function entity wirelink:egpTrackerParent( number index )
	local bool, k, v = EGP:HasObject( this, index )
	if bool and v.Is3DTracker then
		return (v.parententity and v.parententity:IsValid()) and v.parententity or nil
	end
end

--[[--Changing General Settings--]]--

__e2setcost(10)

--- Moves the object to <pos>
e2function void wirelink:egpPos( number index, vector2 pos )
	if (!EGP:IsAllowed( self, this )) then return end
	local bool, k, v = EGP:HasObject( this, index )
	if (bool) then
		if (EGP:EditObject( v, { x = pos[1], y = pos[2] } )) then EGP:DoAction( this, self, "SendObject", v ) Update(self,this) end
	end
end

--- Changes the <size> of objects
e2function void wirelink:egpSize( number index, vector2 size )
	if (!EGP:IsAllowed( self, this )) then return end
	local bool, k, v = EGP:HasObject( this, index )
	if (bool) then
		if (EGP:EditObject( v, { w = size[1], h = size[2] } )) then EGP:DoAction( this, self, "SendObject", v ) Update(self,this) end
	end
end

--- Changes the numeric <size> of objects, such as (out)line width and text/wedge size
e2function void wirelink:egpSize( number index, number size )
	if (!EGP:IsAllowed( self, this )) then return end
	local bool, k, v = EGP:HasObject( this, index )
	if (bool) then
		if (EGP:EditObject( v, { size = size } )) then EGP:DoAction( this, self, "SendObject", v ) Update(self,this) end
	end
end

--- Rotates the object to a certain <angle>
e2function void wirelink:egpAngle( number index, number angle )
	if (!EGP:IsAllowed( self, this )) then return end
	local bool, k, v = EGP:HasObject( this, index )
	if (bool) then
		if (EGP:EditObject( v, { angle = angle } )) then EGP:DoAction( this, self, "SendObject", v ) Update(self,this) end
	end
end

--- Rotates the object around <worldpos> with <axispos> as offset at <angle> degrees
e2function void wirelink:egpAngle( number index, vector2 worldpos, vector2 axispos, number angle )
	if (!EGP:IsAllowed( self, this )) then return end
	local bool, k, v = EGP:HasObject( this, index )
	if (bool) then
		if (v.x and v.y) then

			local vec, ang = LocalToWorld(Vector(axispos[1],axispos[2],0), Angle(0,0,0), Vector(worldpos[1],worldpos[2],0), Angle(0,-angle,0))

			local x = vec.x
			local y = vec.y

			angle = -ang.yaw

			local t = { x = x, y = y }
			if (v.angle) then t.angle = angle end

			if (EGP:EditObject( v, t )) then EGP:DoAction( this, self, "SendObject", v ) Update(self,this) end
		end
	end
end

--- Changes color and alpha of an object
e2function void wirelink:egpColor( number index, vector4 color )
	if (!EGP:IsAllowed( self, this )) then return end
	local bool, k, v = EGP:HasObject( this, index )
	if (bool) then
		if (EGP:EditObject( v, { r = color[1], g = color[2], b = color[3], a = color[4] } )) then EGP:DoAction( this, self, "SendObject", v ) Update(self,this) end
	end
end

--- Changes the <color> of an object
e2function void wirelink:egpColor( number index, vector color )
	if (!EGP:IsAllowed( self, this )) then return end
	local bool, k, v = EGP:HasObject( this, index )
	if (bool) then
		if (EGP:EditObject( v, { r = color[1], g = color[2], b = color[3] } )) then EGP:DoAction( this, self, "SendObject", v ) Update(self,this) end
	end
end

--- Changes the color of an object
e2function void wirelink:egpColor( number index, r,g,b,a )
	if (!EGP:IsAllowed( self, this )) then return end
	local bool, k, v = EGP:HasObject( this, index )
	if (bool) then
		if (EGP:EditObject( v, { r = r, g = g, b = b, a = a } )) then EGP:DoAction( this, self, "SendObject", v ) Update(self,this) end
	end
end

--- Changes the <alpha> of an object
e2function void wirelink:egpAlpha( number index, number alpha )
	if (!EGP:IsAllowed( self, this )) then return end
	local bool, k, v = EGP:HasObject( this, index )
	if (bool) then
		if (EGP:EditObject( v, { a = alpha } )) then EGP:DoAction( this, self, "SendObject", v ) Update(self,this) end
	end
end


--- Changes the <material> of an object. Only works on filled objects
e2function void wirelink:egpMaterial( number index, string material )
	if (!EGP:IsAllowed( self, this )) then return end
	local bool, k, v = EGP:HasObject( this, index )
	if (bool) then
		if (EGP:EditObject( v, { material = material } )) then EGP:DoAction( this, self, "SendObject", v ) Update(self,this) end
	end
end

--- Changes the material of an object to the rendertargeted used by <gpu>s GPULib screen.
--- This allows embedding the output of Wire GPU-, Digital-, Console- and EGP Screens
e2function void wirelink:egpMaterialFromScreen( number index, entity gpu )
	if (!EGP:IsAllowed( self, this )) then return end
	local bool, k, v = EGP:HasObject( this, index )
	if (bool and gpu and gpu:IsValid()) then
		if (EGP:EditObject( v, { material = gpu } )) then EGP:DoAction( this, self, "SendObject", v ) Update(self,this) end
	end
end

--- Changes the <fidelity> of objects. This effects the number of "corners" a full circle has when drawn.
--- Affects Circles, Corners of RoundedBox, Wedges and their respective outlines
e2function void wirelink:egpFidelity( number index, number fidelity )
	if (!EGP:IsAllowed( self, this )) then return end
	local bool, k, v = EGP:HasObject( this, index )
	if (bool) then
		if (EGP:EditObject( v, { fidelity = math.Clamp(fidelity,3,180) } )) then EGP:DoAction( this, self, "SendObject", v ) Update(self,this) end
	end
end

--[[--Parenting--]]--

--- Parents the object to <parentindex>. Childs use relative positions to their parent
e2function void wirelink:egpParent( number index, number parentindex )
	if (!EGP:IsAllowed( self, this )) then return end
	local bool, v = EGP:SetParent( this, index, parentindex )
	if (bool) then EGP:DoAction( this, self, "SendObject", v ) Update(self,this) end
end

--- Parents the object to the cursor. All players will see it relative to their cursor
--- Not recommended to use on EGP Emitter.
e2function void wirelink:egpParentToCursor( number index )
	if (!EGP:IsAllowed( self, this )) then return end
	local bool, v = EGP:SetParent( this, index, -1 )
	if (bool) then EGP:DoAction( this, self, "SendObject", v ) Update(self,this) end
end

--- Removes the parent from the object
e2function void wirelink:egpUnParent( number index )
	if (!EGP:IsAllowed( self, this )) then return end
	local bool, v = EGP:UnParent( this, index )
	if (bool) then EGP:DoAction( this, self, "SendObject", v ) Update(self,this) end
end

--- Returns the parent from the object
e2function number wirelink:egpParent( number index )
	local bool, k, v = EGP:HasObject( this, index )
	if (bool) then
		if (v.parent) then
			return v.parent
		end
	end
	return -1
end

--[[--Object Management--]]--

--- Clears the sceen
e2function void wirelink:egpClear()
	if (!EGP:IsAllowed( self, this )) then return end
	if (EGP:ValidEGP( this )) then
		EGP:DoAction( this, self, "ClearScreen" )
		Update(self,this)
	end
end

--- Deletes the object
e2function void wirelink:egpRemove( number index )
	if (!EGP:IsAllowed( self, this )) then return end
	local bool, k, v = EGP:HasObject( this, index )
	if (bool) then
		EGP:DoAction( this, self, "RemoveObject", index )
		Update(self,this)
	end
end

__e2setcost(15)
--- Creates a copy of the object at <fromindex>
e2function void wirelink:egpCopy( index, fromindex )
	if (!EGP:IsAllowed( self, this )) then return end
	local bool, k, v = EGP:HasObject( this, fromindex )
	if (bool) then
		local copy = table.Copy( v )
		copy.index = index
		local bool2, obj = EGP:CreateObject( this, v.ID, copy, self.player )
		if (bool2) then EGP:DoAction( this, self, "SendObject", obj ) Update(self,this) end
	end
end

--- Checks if an object with that <index> exists
e2function number wirelink:egpHasObject( index )
	local bool, _, _ = EGP:HasObject( this, index )
	return bool and 1 or 0
end

--[[--Frames--]]--

__e2setcost(15)

--- Saves the current state of the EGP as <index>
e2function void wirelink:egpSaveFrame( string index )
	if (!EGP:ValidEGP( this )) then return end
	if (!index or index == "") then return end
	local bool, frame = EGP:LoadFrame( self.player, nil, index )
	if (bool) then
		if (!EGP:IsDifferent( this.RenderTable, frame )) then return end
	end
	EGP:DoAction( this, self, "SaveFrame", index )
	Update(self,this)
end

--- Saves the current state of the EGP as <index>
e2function void wirelink:egpSaveFrame( index )
	if (!EGP:ValidEGP( this )) then return end
	if (!index) then return end
	local bool, frame = EGP:LoadFrame( self.player, nil, tostring(index) )
	if (bool) then
		if (!EGP:IsDifferent( this.RenderTable, frame )) then return end
	end
	EGP:DoAction( this, self, "SaveFrame", tostring(index) )
	Update(self,this)
end

__e2setcost(15)

--- Restores the saved state from <index>
e2function void wirelink:egpLoadFrame( string index )
	if (!EGP:IsAllowed( self, this )) then return end
	if (!index or index == "") then return end
	local bool, frame = EGP:LoadFrame( self.player, nil, index )
	if (bool) then
		if (EGP:IsDifferent( this.RenderTable, frame )) then
			EGP:DoAction( this, self, "LoadFrame", index )
			Update(self,this)
		end
	end
end

--- Restores the saved state from <index>
e2function void wirelink:egpLoadFrame( number index )
	if (!EGP:IsAllowed( self, this )) then return end
	if (!index) then return end
	local bool, frame = EGP:LoadFrame( self.player, nil, tostring(index) )
	if (bool) then
		if (EGP:IsDifferent( this.RenderTable, frame )) then
			EGP:DoAction( this, self, "LoadFrame", tostring(index) )
			Update(self,this)
		end
	end
end

--[[--Order--]]--

e2function void wirelink:egpOrder( number index, number order )
	if (!EGP:IsAllowed( self, this )) then return end
	if (index == order) then return end
	local bool, k, v = EGP:HasObject( this, index )
	if (bool) then
		local bool2 = EGP:SetOrder( this, k, order )
		if (bool2) then
			EGP:DoAction( this, self, "SendObject", v )
			Update(self,this)
		end
	end
end

e2function number wirelink:egpOrder( number index )
	if (!EGP:IsAllowed( self, this )) then return end
	local bool, k, v = EGP:HasObject( this, index )
	if (bool) then
		return k
	end
	return -1
end

--- Places the object <index> directly above <abovethis> in the render order
e2function void wirelink:egpOrderAbove( number index, number abovethis )
	if not EGP:IsAllowed( self, this ) then return end
	local bool, k, v = EGP:HasObject( this, index )
	if bool then
		local bool2, k2, v2 = EGP:HasObject( this, abovethis )
		if bool2 then
			local bool3 = EGP:SetOrder( this, k, abovethis, 1 )
			if bool3 then
				EGP:DoAction( this, self, "SendObject", v )
				Update(self,this)
			end
		end
	end
end

--- Places the object <index> directly below <belowthis> in the render order
e2function void wirelink:egpOrderBelow( number index, number belowthis )
	if not EGP:IsAllowed( self, this ) then return end
	local bool, k, v = EGP:HasObject( this, index )
	if bool then
		local bool2, k2, v2 = EGP:HasObject( this, belowthis )
		if bool2 then
			local bool3 = EGP:SetOrder( this, k, belowthis, -1 )
			if bool3 then
				EGP:DoAction( this, self, "SendObject", v )
				Update(self,this)
			end
		end
	end
end

--[[--Reading General Settings--]]--

__e2setcost(5)
--- Returns the position of the object
e2function vector2 wirelink:egpPos( number index )
	local bool, k, v = EGP:HasObject( this, index )
	if (bool) then
		if (v.x and v.y) then
			return {v.x, v.y}
		end
	end
	return {-1,-1}
end

__e2setcost(20)
--- Returns the global position of the object when parented
--- or the center of verticies for Poly objects
e2function vector wirelink:egpGlobalPos( number index )
	local hasvertices, posang = EGP:GetGlobalPos( this, index )
	if (!hasvertices) then
		return { posang.x, posang.y, posang.angle }
	end
	return { 0,0,0 }
end

--- Returns the global position of the verticies of a parented object
e2function array wirelink:egpGlobalVertices( number index )
	ErrorNoHalt = override
	local hasvertices, data = EGP:GetGlobalPos( this, index )
	ErrorNoHalt = olderror
	if (hasvertices) then
		if (data.vertices) then
			local ret = {}
			for i=1,#data.vertices do
				local v = data.vertices[i]
				ret[i] = {v.x,v.y}
				self.prf = self.prf + 0.1
			end
			return ret
		elseif (data.x and data.y and data.x2 and data.y2 and data.x3 and data.y3) then
			return {{data.x,data.y},{data.x2,data.y2},{data.x3,data.y3}}
		elseif (data.x and data.y and data.x2 and data.y2) then
			return {{data.x,data.y},{data.x2,data.y2}}
		end
	end
	return { 0,0,0 }
end

__e2setcost(5)
--- Returns the 2d size of an object
e2function vector2 wirelink:egpSize( number index )
	local bool, k, v = EGP:HasObject( this, index )
	if (bool) then
		if (v.w and v.h) then
			return {v.w, v.h}
		end
	end
	return {-1,-1}
end

--- Returns the numeric size (width, etc) of an object
e2function number wirelink:egpSizeNum( number index )
	local bool, k, v = EGP:HasObject( this, index )
	if (bool) then
		if (v.size) then
			return v.size
		end
	end
	return -1
end

--- Returns the color of the object as 4D vector (including alpha)
e2function vector4 wirelink:egpColor4( number index )
	local bool, k, v = EGP:HasObject( this, index )
	if (bool) then
		if (v.r and v.g and v.b and v.a) then
			return {v.r,v.g,v.b,v.a}
		end
	end
	return {-1,-1,-1,-1}
end
--- Returns the color of the object as 3D vector
e2function vector wirelink:egpColor( number index )
	local bool, k, v = EGP:HasObject( this, index )
	if (bool) then
		if (v.r and v.g and v.b) then
			return {v.r,v.g,v.b}
		end
	end
	return {-1,-1,-1}
end

--- Returns the alpha of the object
e2function number wirelink:egpAlpha( number index )
	local bool, k, v = EGP:HasObject( this, index )
	if (bool) then
		if (v.a) then
			return v.a
		end
	end
	return -1
end

--- Returns the angle of the object
e2function number wirelink:egpAngle( number index )
	local bool, k, v = EGP:HasObject( this, index )
	if (bool) then
		if (v.angle) then
			return v.angle
		end
	end
	return -1
end

--- Returns the material of the object
e2function string wirelink:egpMaterial( number index )
	local bool, k, v = EGP:HasObject( this, index )
	if (bool) then
		if (v.material) then
			return v.material
		end
	end
	return ""
end

--- Returns the fidelity of the object
e2function number wirelink:egpFidelity( number index )
	if (!EGP:IsAllowed( self, this )) then return end
	local bool, k, v = EGP:HasObject( this, index )
	if (bool) then
		if (v.fidelity) then
			return v.fidelity
		end
	end
	return -1
end

__e2setcost(10)

--- Returns an array of the vertices of the object
e2function array wirelink:egpVertices( number index )
	local bool, k, v = EGP:HasObject( this, index )
	if (bool) then
		if (v.vertices) then
			local ret = {}
			for k2,v2 in ipairs( v.vertices ) do
				ret[k2] = {v2.x,v2.y}
			end
			return ret
		elseif (v.x and v.y and v.x2 and v.y2 and v.x3 and v.y3) then
			return {{v.x,v.y},{v.x2,v.y2},{v.x3,v.y3}}
		elseif (v.x and v.y and v.x2 and v.y2) then
			return {{v.x,v.y},{v.x2,v.y2}}
		end
	end
	return {}
end

--------------------------------------------------------
-- Additional Functions
--------------------------------------------------------

__e2setcost(20)

--- Gets the position of <ply>s cursor on a screen or emitter. Useful for interative screens
e2function vector2 wirelink:egpCursor( entity ply )
	return EGP:EGPCursor( this, ply )
end

__e2setcost(10)

--- Gets the resolution of <ply>s screen/gmod window. Useful for scaling HUDs
e2function vector2 egpScrSize( entity ply )
	if (!ply or !ply:IsValid() or !ply:IsPlayer() or !EGP.ScrHW[ply]) then return {-1,-1} end
	return EGP.ScrHW[ply]
end

--- Gets the width of <ply>s screen/gmod window.
e2function number egpScrW( entity ply )
	if (!ply or !ply:IsValid() or !ply:IsPlayer() or !EGP.ScrHW[ply]) then return -1 end
	return EGP.ScrHW[ply][1]
end

--- Gets the height of <ply>s screen/gmod window.
e2function number egpScrH( entity ply )
	if (!ply or !ply:IsValid() or !ply:IsPlayer() or !EGP.ScrHW[ply]) then return -1 end
	return EGP.ScrHW[ply][2]
end

__e2setcost(10)

local function errorcheck( x, y )
	local xMul = x[2]-x[1]
	local yMul = y[2]-y[1]
	if (xMul == 0 or yMul == 0) then error("Invalid EGP scale") end
end

--- Sets the scale of the screen's X axis to the first vector and Y axis to the second vector
e2function void wirelink:egpScale( vector2 xScale, vector2 yScale )
	if (!EGP:IsAllowed( self, this )) then return end
	errorcheck(xScale,yScale)
	EGP:DoAction( this, self, "SetScale", xScale, yScale )
end

--- Sets the scale of the screen such that the top left corner is equal to the first vector and the bottom right corner is equal to the second vector
e2function void wirelink:egpResolution( vector2 topleft, vector2 bottomright )
	if (!EGP:IsAllowed( self, this )) then return end
	local xScale = { topleft[1], bottomright[1] }
	local yScale = { topleft[2], bottomright[2] }
	errorcheck(xScale,yScale)
	EGP:DoAction( this, self, "SetScale", xScale, yScale )
end

--- Returns the position of the top left corner of the screen
e2function vector2 wirelink:egpOrigin()
	if (!EGP:IsAllowed( self, this )) then return end
	local xOrigin = this.xScale[1] + (this.xScale[2] - this.xScale[1])/2
	local yOrigin = this.yScale[1] + (this.yScale[2] - this.yScale[1])/2
	return { xOrigin, yOrigin }
	--return EGP:DoAction( this, self, "GetOrigin" )
end

--- Returns the size of the screen in pixels
e2function vector2 wirelink:egpSize()
	if (!EGP:IsAllowed( self, this )) then return end
	local width = math.abs(this.xScale[1] - this.xScale[2])
	local height = math.abs(this.yScale[1] - this.yScale[2])
	return { width, height }
	--return EGP:DoAction( this, self, "GetScreenSize" )
end

--- When set to 1, changes most objects to take position as top left corner instead of center
e2function void wirelink:egpDrawTopLeft( number onoff )
	if (!EGP:IsAllowed( self, this )) then return end
	local bool = true
	if (onoff == 0) then bool = false end
	EGP:DoAction( this, self, "MoveTopLeft", bool )
end

-- this code has some wtf strange things
local function ScalePoint( this, x, y )
	local xMin = this.xScale[1]
	local xMax = this.xScale[2]
	local yMin = this.yScale[1]
	local yMax = this.yScale[2]

	x = ((x - xMin) * 512) / (xMax - xMin) - xMax
	y = ((y - yMin) * 512) / (yMax - yMin) - yMax

	return x,y
end


__e2setcost(20)
--- Returns the world position of a pixel on the screen/emitter
e2function vector wirelink:egpToWorld( vector2 pos )
	if not EGP:ValidEGP( this ) then return Vector(0,0,0) end

	local class = this:GetClass()
	if class == "gmod_wire_egp_emitter" then
		local x,y = pos[1]*0.25,pos[2]*0.25 -- 0.25 because the scale of the 3D2D is 0.25.
		if this.Scaling then
			x,y = ScalePoint(this,x,y)
		end
		return this:LocalToWorld( Vector(-64,0,135) + Vector(x,0,-y) )
	elseif class == "gmod_wire_egp" then
		local monitor = WireGPU_Monitors[this:GetModel()]
		if not monitor then return Vector(0,0,0) end

		local x,y = pos[1],pos[2]

		if this.Scaling then
			x,y = ScalePoint( this, x, y )
		else
			x,y = x-256,y-256
		end

		x = x * monitor.RS / monitor.RatioX
		y = y * monitor.RS

		local vec = Vector(x,-y,0)
		vec:Rotate(monitor.rot)
		return this:LocalToWorld(vec+monitor.offset)
	end

	return Vector(0,0,0)
end

local antispam = {}
__e2setcost(25)
--- Toggles the EGP HUD on or off for the E2 owner
e2function void wirelink:egpHudToggle()
	if not EGP:ValidEGP( this ) then return end
	if antispam[self.player] and antispam[self.player] > CurTime() then return end
	antispam[self.player] = CurTime() + 0.1
	umsg.Start( "EGP_HUD_Use", self.player ) umsg.Entity( this ) umsg.End()
end

--[--Useful functions--]--
__e2setcost(10)

--- Returns number of object on the EGP
e2function number wirelink:egpNumObjects()
	if (!EGP:ValidEGP( this )) then return -1 end
	return #this.RenderTable
end

--- Returns maximum number of object on an EGP
e2function number egpMaxObjects()
	return EGP.ConVars.MaxObjects:GetInt()
end

--- Returns the maximum number of usermessages you can send per second
e2function number egpMaxUmsgPerSecond()
	return EGP.ConVars.MaxPerSec:GetInt()
end

--- Returns the number of bytes left you can send
e2function number egpBytesLeft()
	local maxcount = EGP.ConVars.MaxPerSec:GetInt()
	local tbl = EGP.IntervalCheck[self.player]
	tbl.bytes = math.max(0, tbl.bytes - (CurTime() - tbl.time) * maxcount)
	tbl.time = CurTime()
	return maxcount - tbl.bytes
end

__e2setcost(5)

--- Checks if you can currently send usermessages
e2function number egpCanSendUmsg()
	return (EGP:CheckInterval( self.player ) and 1 or 0)
end

--[[--Queue system--]]--

--- Clears your entire queue
e2function number egpClearQueue()
	if (EGP.Queue[self.player]) then
		EGP.Queue[self.player] = {}
		return 1
	end
	return 0
end

--[[ currently does not work
e2 function number wirelink:egpClearQueue()
	if (!EGP:ValidEGP( this )) then return end
	if (EGP.Queue[self.player]) then
		EGP:StopQueueTimer( self.player )
		EGP.Queue[self.player].DONTADDMORE = true
		local removetable = {}
		for k,v in ipairs( EGP.Queue[self.player] ) do
			if (v.Ent == this) then
				table.insert( removetable, k )
				return 1
			end
		end
		for k,v in ipairs( removetable ) do
			table.remove( EGP.Queue[self.player], v )
		end
		EGP:SendQueueItem( self.player )
		EGP:StartQueueTimer( self.player )
		timer.Simple(1,function() EGP.Queue[self.player].DONTADDMORE = nil end)
	end
	return 0
end
]]

__e2setcost(10)

--- Returns the amount of items in your queue
e2function number egpQueue()
	if (EGP.Queue[self.player]) then
		return #EGP.Queue[self.player]
	end
	return 0
end

--- Choose whether or not to make this E2 run when the queue has finished sending all items for <this>
e2function void wirelink:egpRunOnQueue( yesno )
	if (!EGP:ValidEGP( this )) then return end
	local bool = false
	if (yesno != 0) then bool = true end
	self.data.EGP.RunOnEGP[this] = bool
end

--- Returns 1 if the current execution was caused by the EGP queue system OR if the EGP queue system finished in the current execution
e2function number egpQueueClk()
	if (EGP.RunByEGPQueue) then
		return 1
	end
	return 0
end

--- Returns 1 if the current execution was caused by the EGP queue system regarding the entity <screen> OR if the EGP queue system finished in the current execution
e2function number egpQueueClk( wirelink screen )
	if (EGP.RunByEGPQueue and EGP.RunByEGPQueue_Ent == screen) then
		return 1
	end
	return 0
end

--- Returns 1 if the current execution was caused by the EGP queue system regarding the entity <screen> OR if the EGP queue system finished in the current execution
e2function number egpQueueClk( entity screen )
	if (EGP.RunByEGPQueue and EGP.RunByEGPQueue_Ent == screen) then
		return 1
	end
	return 0
end

--- Returns the screen which the queue finished sending items for
e2function entity egpQueueScreen()
	if (EGP.RunByEGPQueue) then
		return EGP.RunByEGPQueue_Ent
	end
end

--- Same as above, except returns wirelink
e2function wirelink egpQueueScreenWirelink()
	if (EGP.RunByEGPQueue) then
		return EGP.RunByEGPQueue_Ent
	end
end

--- Returns the player which ordered the current items to be sent (This is usually yourself, but if you're sharing pp with someone it might be them. Good way to check if someone is fucking with your screens)
e2function entity egpQueuePlayer()
	if (EGP.RunByEGPQueue) then
		return EGP.RunByEGPQueue_ply
	end
end

--- Returns 1 if the current execution was caused by the EGP queue system and the player <ply> was the player whom ordered the item to be sent (This is usually yourself, but if you're sharing pp with someone it might be them.)
e2function number egpQueueClkPly( entity ply )
	if (EGP.RunByEGPQueue and EGP.RunByEGPQueue_ply == ply) then
		return 1
	end
	return 0
end

--------------------------------------------------------
-- Callbacks
--------------------------------------------------------

registerCallback("postexecute",function(self)
	for k,v in pairs( self.data.EGP.UpdatesNeeded ) do
		if IsValid(k) then
			EGP:SendQueueItem( self.player )
		end
		self.data.EGP.UpdatesNeeded[k] = nil
	end
end)

registerCallback("construct",function(self)
	self.data.EGP = {}
	self.data.EGP.RunOnEGP = {}
	self.data.EGP.UpdatesNeeded = {}
end)
