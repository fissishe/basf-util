local Git = "https://raw.githubusercontent.com/fissishe/basf-util/refs/heads/main/"

local function Main(): { [any]: any }?
	local Code = game:HttpGet(Git .. "/src/util/util-lib.luau")

	if Code then
		return loadstring(Code)()
	end

	return {}
end

return Main()
