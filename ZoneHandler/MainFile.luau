local Enumer = require(script:WaitForChild("Enumerator"))

return {
	GetClient = function()
		local Client = require(script:WaitForChild("SystemConstructors"):WaitForChild("Client"))

		return Client
	end,
	
	GetServer  = function()
		local Server = require(script.SystemConstructors.Server)
		
		return Server
	end,
	
	Enumerator = Enumer
	
	
}