--   By asiekierka,  2009   --
--Non-luabit XOR by TomyLobo--

__e2setcost(2)

--- Performs binary AND
e2function number bAnd(a, b)
	return bit.band(a, b)
end
--- Performs binary OR
e2function number bOr(a, b)
	return bit.bor(a, b)
end
--- Performs binary XOR
e2function number bXor(a, b)
	return bit.bxor(a, b)
end
--- Shifts bits to the right
e2function number bShr(a, b)
	return bit.rshift(a, b)
end
--- Shifts bits to the left
e2function number bShl(a, b)
	return bit.lshift(a, b)
end
--- Performs binary NOT
e2function number bNot(n)
	return bit.bnot(n)
end
--- Performs binary NOT with a given mininum number of bots
e2function number bNot(n,bits)
	if bits >= 32 || bits < 1 then
		return (-1)-n
	else
		return (math.pow(2,bits)-1)-n
	end
end


e2function number operator_band( a, b )
	return bit.band(a, b)
end
e2function number operator_bor( a, b )
	return bit.bor(a, b)
end
e2function number operator_bxor( a, b )
	return bit.bxor(a, b)
end
e2function number operator_bshr( a, b )
	return bit.rshift(a, b)
end
e2function number operator_bshl( a, b )
	return bit.lshift(a, b)
end
