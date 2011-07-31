module (..., package.seeall)


local function test()
	print("jxl::test, self: ", self)
end

jxl.test = test

print("jxl: ", jxl, ", test: ", test, ", jxl.test: ", jxl.test)


local P = {}   -- package
if _REQUIREDNAME == nil then
	jxl = P
else
	_G[_REQUIREDNAME] = P
end

return P