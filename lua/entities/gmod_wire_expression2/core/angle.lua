/******************************************************************************\
Angle support
\******************************************************************************/

// wow... this is basically just vector-support, but renamed angle-support :P
// pitch, yaw, roll
registerType("angle", "a", { 0, 0, 0 },
	function(self, input) return { input.p, input.y, input.r } end,
	function(self, output) return Angle(output[1], output[2], output[3]) end,
	function(retval)
		if !istable(retval) then error("Return value is not a table, but a "..type(retval).."!",0) end
		if #retval ~= 3 then error("Return value does not have exactly 3 entries!",0) end
	end,
	function(v)
		return !istable(v) or #v ~= 3
	end
)

local pi = math.pi
local floor, ceil = math.floor, math.ceil

--[[--Constructors--]]--

__e2setcost(1) -- approximated

--- Creates an angle with pitch, roll and yaw = 0
e2function angle ang()
	return { 0, 0, 0 }
end

__e2setcost(2)

--- Creates an angle with pitch, yaw and roll = <value>
e2function angle ang(value)
	return { value, value, value }
end

--- Creates an angle with given <pitch>, <yaw> and <roll>
e2function angle ang(pitch, yaw, roll)
	return { pitch, yaw, roll }
end

--- Creates an angle from a vector with pitch=x, yaw=y and roll=z
e2function angle ang(vector rv1)
	return {rv1[1],rv1[2],rv1[3]}
end

--[[******************************************************************************]]--

registerOperator("ass", "a", "a", function(self, args)
	local op1, op2, scope = args[2], args[3], args[4]
	local      rv2 = op2[1](self, op2)
	self.Scopes[scope][op1] = rv2
	self.Scopes[scope].vclk[op1] = true
	return rv2
end)

--[[******************************************************************************]]--

e2function number operator_is(angle rv1)
	if rv1[1] != 0 || rv1[2] != 0 || rv1[3] != 0
	   then return 1 else return 0 end
end

__e2setcost(3)

e2function number operator==(angle rv1, angle rv2)
	if rv1[1] - rv2[1] <= delta && rv2[1] - rv1[1] <= delta &&
	   rv1[2] - rv2[2] <= delta && rv2[2] - rv1[2] <= delta &&
	   rv1[3] - rv2[3] <= delta && rv2[3] - rv1[3] <= delta
	   then return 1 else return 0 end
end

e2function number operator!=(angle rv1, angle rv2)
	if rv1[1] - rv2[1] > delta || rv2[1] - rv1[1] > delta ||
	   rv1[2] - rv2[2] > delta || rv2[2] - rv1[2] > delta ||
	   rv1[3] - rv2[3] > delta || rv2[3] - rv1[3] > delta
	   then return 1 else return 0 end
end

e2function number operator>=(angle rv1, angle rv2)
	if rv2[1] - rv1[1] <= delta &&
	   rv2[2] - rv1[2] <= delta &&
	   rv2[3] - rv1[3] <= delta
	   then return 1 else return 0 end
end

e2function number operator<=(angle rv1, angle rv2)
	if rv1[1] - rv2[1] <= delta &&
	   rv1[2] - rv2[2] <= delta &&
	   rv1[3] - rv2[3] <= delta
	   then return 1 else return 0 end
end

e2function number operator>(angle rv1, angle rv2)
	if rv1[1] - rv2[1] > delta &&
	   rv1[2] - rv2[2] > delta &&
	   rv1[3] - rv2[3] > delta
	   then return 1 else return 0 end
end

e2function number operator<(angle rv1, angle rv2)
	if rv2[1] - rv1[1] > delta &&
	   rv2[2] - rv1[2] > delta &&
	   rv2[3] - rv1[3] > delta
	   then return 1 else return 0 end
end

--[[******************************************************************************]]--

registerOperator("dlt", "a", "a", function(self, args)
	local op1, scope = args[2], args[3]
	local rv1, rv2 = self.Scopes[scope][op1], self.Scopes[scope]["$" .. op1]
	return { rv1[1] - rv2[1], rv1[2] - rv2[2], rv1[3] - rv2[3] }
end)

__e2setcost(2)

e2function angle operator_neg(angle rv1)
	return { -rv1[1], -rv1[2], -rv1[3] }
end

e2function angle operator+(rv1, angle rv2)
	return { rv1 + rv2[1], rv1 + rv2[2], rv1 + rv2[3] }
end

e2function angle operator+(angle rv1, rv2)
	return { rv1[1] + rv2, rv1[2] + rv2, rv1[3] + rv2 }
end

e2function angle operator+(angle rv1, angle rv2)
	return { rv1[1] + rv2[1], rv1[2] + rv2[2], rv1[3] + rv2[3] }
end

e2function angle operator-(rv1, angle rv2)
	return { rv1 - rv2[1], rv1 - rv2[2], rv1 - rv2[3] }
end

e2function angle operator-(angle rv1, rv2)
	return { rv1[1] - rv2, rv1[2] - rv2, rv1[3] - rv2 }
end

e2function angle operator-(angle rv1, angle rv2)
	return { rv1[1] - rv2[1], rv1[2] - rv2[2], rv1[3] - rv2[3] }
end

e2function angle operator*(angle rv1, angle rv2)
	return { rv1[1] * rv2[1], rv1[2] * rv2[2], rv1[3] * rv2[3] }
end

e2function angle operator*(rv1, angle rv2)
	return { rv1 * rv2[1], rv1 * rv2[2], rv1 * rv2[3] }
end

e2function angle operator*(angle rv1, rv2)
	return { rv1[1] * rv2, rv1[2] * rv2, rv1[3] * rv2 }
end

e2function angle operator/(rv1, angle rv2)
    return { rv1 / rv2[1], rv1 / rv2[2], rv1 / rv2[3] }
end

e2function angle operator/(angle rv1, rv2)
    return { rv1[1] / rv2, rv1[2] / rv2, rv1[3] / rv2 }
end

e2function angle operator/(angle rv1, angle rv2)
	return { rv1[1] / rv2[1], rv1[2] / rv2[2], rv1[3] / rv2[3] }
end

e2function number angle:operator[](index)
	return this[floor(math.Clamp(index, 1, 3) + 0.5)]
end

e2function number angle:operator[](index, value)
	this[floor(math.Clamp(index, 1, 3) + 0.5)] = value
	return value
end

--[[******************************************************************************]]--

__e2setcost(5)

--- Converts <input> into its normalized form with pitch, yaw and roll between -180 and 180
e2function angle angnorm(angle input)
	return {(input[1] + 180) % 360 - 180,(input[2] + 180) % 360 - 180,(input[3] + 180) % 360 - 180}
end

--- Converts an <input> into its normalized form with value between -180 and 180
e2function number angnorm(input)
	return (input + 180) % 360 - 180
end

__e2setcost(1)

--- Gets the pitch of the angle
e2function number angle:pitch()
	return this[1]
end

--- Gets the yaw of the angle
e2function number angle:yaw()
	return this[2]
end

--- Gets the roll of the angle
e2function number angle:roll()
	return this[3]
end

__e2setcost(2)

--- Returns a new angle with modified <pitch>
e2function angle angle:setPitch(pitch)
	return { pitch, this[2], this[3] }
end

--- Returns a new angle with modified <yaw>
e2function angle angle:setYaw(yaw)
	return { this[1], yaw, this[3] }
end

--- Returns a new angle with modified <roll>
e2function angle angle:setRoll(roll)
	return { this[1], this[2], roll }
end

--[[--Component rounding--]]--

__e2setcost(5)

--- Rounds <input>
e2function angle round(angle input)
	return {
		floor(input[1] + 0.5),
		floor(input[2] + 0.5),
		floor(input[3] + 0.5)
	}
end

--- Rounds <input> to the amount of <decimals>
e2function angle round(angle input, decimals)
	local shf = 10 ^ decimals
	return {
		floor(input[1] * shf + 0.5) / shf,
		floor(input[2] * shf + 0.5) / shf,
		floor(input[3] * shf + 0.5) / shf
	}
end

--- Ceils <input>
e2function angle ceil(angle input)
	return {
		ceil(input[1]),
		ceil(input[2]),
		ceil(input[3])
	}
end

--- Ceils <input> to the amount of <decimals>
e2function angle ceil(angle input, decimals)
	local shf = 10 ^ decimals
	return {
		ceil(input[1] * shf) / shf,
		ceil(input[2] * shf) / shf,
		ceil(input[3] * shf) / shf
	}
end

--- Floors <input>
e2function angle floor(angle input)
	return {
		floor(input[1]),
		floor(input[2]),
		floor(input[3])
	}
end

--- Floors <input> to the amount of <decimals>
e2function angle floor(angle input, decimals)
	local shf = 10 ^ decimals
	return {
		floor(input[1] * shf) / shf,
		floor(input[2] * shf) / shf,
		floor(input[3] * shf) / shf
	}
end

--[[--Component math--]]--

--- Performs seperate modulo on <input> with the given <modulo>
e2function angle mod(angle input, modulo)
	local p,y,r
	if input[1] >= 0 then
		p = input[1] % modulo
	else p = input[1] % -modulo end
	if input[2] >= 0 then
		y = input[2] % modulo
	else y = input[2] % -modulo end
	if input[3] >= 0 then
		r = input[3] % modulo
	else r = input[3] % -modulo end
	return {p, y, r}
end

--- Performs modulo on <input> with the given <modulo>
e2function angle mod(angle input, angle modulo)
	local p,y,r
	if input[1] >= 0 then
		p = input[1] % modulo[1]
	else p = input[1] % -modulo[1] end
	if input[2] >= 0 then
		y = input[2] % modulo[2]
	else y = input[2] % -modulo[2] end
	if input[3] >= 0 then
		y = input[3] % modulo[3]
	else y = input[3] % -modulo[3] end
	return {p, y, r}
end

--- Clamp <input> between given <minimum> and <maximum>
e2function angle clamp(angle input, minimum, maximum)
	local p,y,r

	if input[1] < minimum then p = minimum
	elseif input[1] > maximum then p = maximum
	else p = input[1] end

	if input[2] < minimum then y = minimum
	elseif input[2] > maximum then y = maximum
	else y = input[2] end

	if input[3] < minimum then r = minimum
	elseif input[3] > maximum then r = maximum
	else r = input[3] end

	return {p, y, r}
end

--- Clamp <input> between given <minimum> and <maximum>
e2function angle clamp(angle input, angle minimum, angle maximum)
	local p,y,r

	if input[1] < minimum[1] then p = minimum[1]
	elseif input[1] > maximum[1] then p = maximum[1]
	else p = input[1] end

	if input[2] < minimum[2] then y = minimum[2]
	elseif input[2] > maximum[2] then y = maximum[2]
	else y = input[2] end

	if input[3] < minimum[3] then r = minimum[3]
	elseif input[3] > maximum[3] then r = maximum[3]
	else r = input[3] end

	return {p, y, r}
end

--- Mix <a> and <b> by a given ratio (between 0=b and 1=a)
e2function angle mix(angle a, angle b, ratio)
	local p = a[1] * ratio + b[1] * (1-ratio)
	local y = a[2] * ratio + b[2] * (1-ratio)
	local r = a[3] * ratio + b[3] * (1-ratio)
	return {p, y, r}
end

__e2setcost(2)

--- Circular shift function: shiftr(  p,y,r ) = ( r,p,y )
e2function angle shiftR(angle input)
	return {input[3], input[1], input[2]}
end

--- Circular shift function: shiftl(  p,y,r ) = ( y,r,p )
e2function angle shiftL(angle input)
	return {input[2], input[3], input[1]}
end

__e2setcost(5)

--- Returns 1 if <input> is between given <minimum> and <maximum>
e2function normal inrange(angle input, angle minimum, angle maximum)
	if input[1] < minimum[1] then return 0 end
	if input[2] < minimum[2] then return 0 end
	if input[3] < minimum[3] then return 0 end

	if input[1] > maximum[1] then return 0 end
	if input[2] > maximum[2] then return 0 end
	if input[3] > maximum[3] then return 0 end

	return 1
end

--- Convert the <input> from degrees to radians
e2function angle toRad(angle input)
	return {input[1] * pi / 180, input[2] * pi / 180, input[3] * pi / 180}
end

--- Convert the <input> from radians to degrees
e2function angle toDeg(angle input)
	return {input[1] * 180 / pi, input[2] * 180 / pi, input[3] * 180 / pi}
end

--[[--Angle functions--]]--

--- Rotate an angle around a <axis> by the given number of <degrees>
e2function angle angle:rotateAroundAxis(vector axis, degrees)
	local ang = Angle(this[1], this[2], this[3])
	local vec = Vector(axis[1], axis[2], axis[3]):GetNormal()

	ang:RotateAroundAxis(vec, degrees)
	return {ang.p, ang.y, ang.r}
end

--- Gets the forward direction of the angle
e2function vector angle:forward()
	return Angle(this[1], this[2], this[3]):Forward()
end

--- Gets the right direction of the angle
e2function vector angle:right()
	return Angle(this[1], this[2], this[3]):Right()
end

--- Gets the upwards direction of the angle
e2function vector angle:up()
	return Angle(this[1], this[2], this[3]):Up()
end

--- Converts <input> to a string: "[pitch,yaw,roll]"
e2function string toString(angle input)
	return ("[%s,%s,%s]"):format(input[1],input[2],input[3])
end

--- Converts the angle to a string: "[pitch,yaw,roll]"
e2function string angle:toString() = e2function string toString(angle a)
