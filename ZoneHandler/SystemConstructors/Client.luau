local module = {}

local Shared = script.Parent.Parent:WaitForChild("Shared")

local TimeObject = require(Shared:WaitForChild("TimeHandler"))

local Enumerator = require(script.Parent.Parent:WaitForChild("Enumerator"))

local Events = require(Shared:WaitForChild("Events"))

local WeatherUpdate = Events:GetGlobal("WeatherUpdate")

local SubZone = require(script:WaitForChild("SubzoneHandler"))

local WeatherUpdate = Events:GetGlobal("WeatherUpdate")

module.CurrentWeather = "None"

function module:Calc_Time_Value(minValue, maxValue, hour, specialValues)
	hour = hour % 24

	if specialValues and typeof(specialValues) == "table" then
		local times = {}
		for t in pairs(specialValues) do
			table.insert(times, t)
		end
		table.sort(times)

		local prevTime = nil
		local nextTime = nil

		for i = 1, #times do
			if times[i] <= hour then
				prevTime = times[i]
			end
			if times[i] > hour then
				nextTime = times[i]
				break
			end
		end

		if not prevTime then
			prevTime = times[#times]
		end
		if not nextTime then
			nextTime = times[1] + 24
		end

		local prevValue = specialValues[prevTime % 24]
		local nextValue = specialValues[nextTime % 24]

		local span = nextTime - prevTime
		local factor = (hour - prevTime) / span

		if typeof(prevValue) == "Color3" and typeof(nextValue) == "Color3" then
			return Color3.new(
				prevValue.R + (nextValue.R - prevValue.R) * factor,
				prevValue.G + (nextValue.G - prevValue.G) * factor,
				prevValue.B + (nextValue.B - prevValue.B) * factor
			)
		elseif typeof(prevValue) == "number" and typeof(nextValue) == "number" then
			return prevValue + (nextValue - prevValue) * factor
		else
			error("Special values must be all numbers or all Color3")
		end
	else
		local distanceFromNoon = math.abs(hour - 12)
		local factor = 1 - (distanceFromNoon / 12)

		if typeof(minValue) == "Color3" and typeof(maxValue) == "Color3" then
			return Color3.new(
				minValue.R + (maxValue.R - minValue.R) * factor,
				minValue.G + (maxValue.G - minValue.G) * factor,
				minValue.B + (maxValue.B - minValue.B) * factor
			)
		elseif typeof(minValue) == "number" and typeof(maxValue) == "number" then
			return minValue + (maxValue - minValue) * factor
		else
			error("minValue and maxValue must both be numbers or both be Color3")
		end
	end
end



module.OnHour = TimeObject.OnHour

module.OnTick = TimeObject.OnTick

module.OnWeather = WeatherUpdate.OnClientEvent

module.OnZoneEnter = SubZone.OnEnter

module.OnZoneExit = SubZone.OnExit

function module:ResumeTime()
	TimeObject:Resume()
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

function module:SetTime(Time:number)
	TimeObject:SetTime(Time)
end

function module:CreateZone(ZoneID:string, Parts:{BasePart})
	SubZone:CreateZone(ZoneID, Parts)
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

function module:GetTime()
	return Events:GetEvent("GetTime"):InvokeServer()
end

WeatherUpdate.OnClientEvent:Connect(function(Weather)
	module.CurrentWeather = Weather
end)


return module
