-- SERVER
local Zone_Manger = require(game.ReplicatedStorage:WaitForChild("Subzone__V2"))
local Enumerator = Zone_Manger.Enumerator

local Server = Zone_Manger.GetServer(Enumerator.Time_Type.Minute)

Server:SetTimeRate(Enumerator.Time_Type.Minute, 1)
Server:SetTime(12)
Server:ResumeTime()
Server.ChanceOfWeather = 100
Server.WeatherCooldown = 1

Server:CreateWeather(Enumerator.Weather_Chance.Common, "Test")

Server:CreateWeather(Enumerator.Weather_Chance.Uncommon, "Test2")

Server:CreateWeather(Enumerator.Weather_Chance.Rare, "Test3")

Server.OnWeather:Connect(function(Weather:string)
	print(Weather)
end)


-- CLIENT

local Zone_Manger = require(game.ReplicatedStorage:WaitForChild("Subzone__V2"))

local Client = Zone_Manger.GetClient()
local Enumerator = Zone_Manger.Enumerator
local Clouds:Clouds = game.Workspace.Terrain:WaitForChild("Clouds")

Client.OnHour:Connect(function(Time: number)
end)

Client.OnTick:Connect(function(Time: number)
	game.Lighting.ClockTime = Time

	game.Lighting.Brightness = Client:Calc_Time_Value(0.4, 3, Time)

	game.Lighting.Atmosphere.Density = Client:Calc_Time_Value(1.2, 0.3, Time, {
		[0] = 1,
		[6] = 0.4,
		[7] = 0.2,
		[8] = 0.2,
		[12] = 0.2,
		[19] = 0.5,
		[21] = 1,
		[24] = 1,
	})

	game.Lighting.Atmosphere.Color = Client:Calc_Time_Value(Color3.new(0.0666667, 0.0666667, 0.0666667), Color3.new(1, 1, 1), Time, {
		[0] = Color3.fromRGB(0,0,0),
		[6] = Color3.fromRGB(255,200,150),
		[12] = Color3.fromRGB(255,255,255),
		[13.8] = Color3.fromRGB(255,255,255),
		[15] = Color3.fromRGB(175,71,104),
		[16] = Color3.fromRGB(172,86,43),
		[18] = Color3.fromRGB(89,45,22),
		[20] = Color3.fromRGB(0,0,0),
		[24] = Color3.fromRGB(0,0,0)
	})
	
	Clouds.Color = Client:Calc_Time_Value(Color3.new(0.0666667, 0.0666667, 0.0666667), Color3.new(1, 1, 1), Time, {
		[0] = Color3.fromRGB(0,0,0),
		[6] = Color3.fromRGB(255,200,150),
		[12] = Color3.fromRGB(255,255,255),
		[13.8] = Color3.fromRGB(255,255,255),
		[15] = Color3.fromRGB(175,71,104),
		[16] = Color3.fromRGB(172,86,43),
		[18] = Color3.fromRGB(89,45,22),
		[20] = Color3.fromRGB(0,0,0),
		[24] = Color3.fromRGB(0,0,0)
	})
end)

Client.OnZoneExit:Connect(function(Action:Enumerator.Custom_Enum, SubID:string)
	Client:SetTime(Client:GetTime())
	Client:ResumeTime()
end)

Client.OnZoneEnter:Connect(function(Action:Enumerator.Custom_Enum, SubID:string)
	Client:PauseTime()
	
	game.Lighting.ClockTime = 12
	
	game.Lighting.Atmosphere.Density = 0.1
	
	game.Lighting.Atmosphere.Color = Color3.new(1, 1, 1)
end)

Client:CreateZone("Test", {game.Workspace:WaitForChild("Part")})

Client.OnWeather:Connect(function(WeatherID:string)
	
end)

Client:SetTimeRate(Enumerator.Time_Type.Minute, 1)
Client:SetTime(Client:GetTime())
Client:ResumeTime()