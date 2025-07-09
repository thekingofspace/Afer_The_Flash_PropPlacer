local module = {}

local Shared = script.Parent.Parent.Shared

local TimeObject = require(Shared.TimeHandler)

local Enumerator = require(script.Parent.Parent:WaitForChild("Enumerator"))

local Events = require(Shared:WaitForChild("Events"))

local WeatherUpdate = Events:GetGlobal("WeatherUpdate")

local GetTime = Events:GetEvent("GetTime")

local GetWeather = Events:GetEvent("GetWeather")

local Signal = require(Shared:WaitForChild("Signal"))

local OnWeather = Signal:CreateSignal()

local Weather_Task = nil
local CurrentWeather = "None"

module.ShouldBlock = false

local WeatherPatterns = {
	[Enumerator.Weather_Chance.Common] = {};
	
	[Enumerator.Weather_Chance.Uncommon] = {};
	
	[Enumerator.Weather_Chance.Rare] = {};
	
	[Enumerator.Weather_Chance.Epic] = {};
	
	[Enumerator.Weather_Chance.Legendary] = {};
	
	[Enumerator.Weather_Chance.Mythic] = {};
}

local function pickWeightedKey(dict: {[any]: number}): any
	local totalWeight = 0
	local power = 3

	local adjustedWeights = {}
	for key, weight in pairs(dict) do
		local adjusted = weight ^ power
		adjustedWeights[key] = adjusted
		totalWeight += adjusted
	end

	local randomValue = math.random() * totalWeight
	local runningSum = 0

	for key, adjustedWeight in pairs(adjustedWeights) do
		runningSum += adjustedWeight
		if randomValue <= runningSum then
			return key
		end
	end
end


module.ChanceOfWeather = 0

module.WeatherCooldown = 10

module.OnWeather = Signal:CreateReadOnlySignal(OnWeather)

GetTime.OnServerInvoke = function()
	return TimeObject.CurrentTime
end

local WeatherDebounce = false

TimeObject.OnHour:Connect(function(Hour)
	if module.ShouldBlock == false then
		if module.ChanceOfWeather ~= 0 and Random.new():NextNumber(1, 100) <=  module.ChanceOfWeather and WeatherDebounce ~= true and Hour > 5 and Hour < 18 then
			WeatherDebounce = true
			local Item:Enumerator.Custom_Enum = pickWeightedKey((function()
				local Aray = {}

				for I, item in pairs(WeatherPatterns) do
					if #item > 0 then
						Aray[I] = I.Value
					end
				end

				return Aray
			end)())

			if Item == nil then
				WeatherDebounce = false
				return
			end

			local Weather = WeatherPatterns[Item][Random.new():NextInteger(1, #WeatherPatterns[Item])]

			WeatherUpdate:FireAllClients(Weather)
			
			OnWeather:Fire(Weather)
			CurrentWeather = Weather

			Weather_Task = task.delay(module.WeatherCooldown, function()
				WeatherUpdate:FireAllClients("None")
				
				OnWeather:Fire("None")
				
				WeatherDebounce = false
				
				Weather_Task = nil
				
				CurrentWeather = "None"
			end)
		end
	end
end)

function module:ResumeTime()
	TimeObject:Resume()
end

function module:SetWeather(Weather:string)
	WeatherUpdate:FireAllClients(Weather)
	OnWeather:Fire(Weather)
	CurrentWeather = Weather
end

function module:BlockWeather(Boolean:boolean)
	module.ShouldBlock = Boolean
end

function module:BreakCooldown(CancelWeather:boolean)
	if Weather_Task then
		task.cancel(Weather_Task)
	end
	
	WeatherDebounce = false
	
	Weather_Task = nil
	
	if CancelWeather == true then
		WeatherUpdate:FireAllClients("None")
		OnWeather:Fire("None")
		CurrentWeather = "None"
	end
end

function module:PauseTime()
	TimeObject:Pause()
end

function HoursToSeconds(hours)
	return hours * 3600
end

function MinutesToSeconds(minutes)
	return minutes * 60
end

GetWeather.OnServerInvoke = function()
	return CurrentWeather
end

function module:CreateWeather(Weather_Rarity:Enumerator.Custom_Enum, WeatherID:string)
	table.insert(WeatherPatterns[Weather_Rarity], WeatherID)
end

function module:SetTime(Time:number)
	TimeObject:SetTime(Time)
end

function module:SetTimeRate(Calc_Type:Enumerator.Custom_Enum, Time:number)
	if Calc_Type == Enumerator.Time_Type.Hour then
		TimeObject:SetTimeLength(HoursToSeconds(Time))
		
	elseif Calc_Type == Enumerator.Time_Type.Minute then
		TimeObject:SetTimeLength(MinutesToSeconds(Time))
		
	else
		TimeObject:SetTimeLength(Time)
	end
end


return module
