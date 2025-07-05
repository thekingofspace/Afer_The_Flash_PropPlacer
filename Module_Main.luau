return {
	GetServer = function()
		local Module = require(script:WaitForChild("SystemConstructors"):WaitForChild("Server"))
		
		return Module
	end,
	
	GetClient = function()
		local Module = require(script:WaitForChild("SystemConstructors"):WaitForChild("Client"))
		
		return Module
	end,
	
	Types = script:WaitForChild("Type_Definitions");
}