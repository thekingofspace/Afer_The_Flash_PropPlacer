local self = setmetatable({}, {})

local Signal = require(script.Parent:WaitForChild("Signal"))

local OnResume = Signal:CreateSignal()

local OnPause = Signal:CreateSignal()

local OnHour = Signal:CreateSignal()

local OnTick = Signal:CreateSignal()

self.OnResume = Signal:CreateReadOnlySignal(OnResume)
self.OnPause = Signal:CreateReadOnlySignal(OnPause)
self.OnHour = Signal:CreateReadOnlySignal(OnHour)
self.OnTick = Signal:CreateReadOnlySignal(OnTick)

self.DayLength = 0 :: number
self.CurrentTime = 12 :: number

self.Active = false :: boolean

local Busy = false
local LastHour = math.floor(self.CurrentTime)

function self:SetTimeLength(Time:number)
	self.DayLength = Time
end

function self:Resume()
	self.Active = true
	OnResume:Fire()
end

function self:Pause()
	self.Active = false
	OnPause:Fire()
end

function self:SetTime(Time:number)
	self.CurrentTime = Time
	LastHour = math.floor(Time)
end

game:GetService("RunService").Heartbeat:Connect(function(dt)
	if Busy == true or self.Active == false then
		return
	end
	
	Busy = true

	local deltaTimeInHours = (dt / self.DayLength) * 24
	self.CurrentTime = self.CurrentTime + deltaTimeInHours

	if self.CurrentTime >= 24 then
		self.CurrentTime = self.CurrentTime - 24
	end

	local currentHour = math.floor(self.CurrentTime)
	if currentHour ~= LastHour then
		OnHour:Fire(currentHour)
		LastHour = currentHour
	end
	
	OnTick:Fire(self.CurrentTime)

	Busy = false
end)

self.__index = self

return self
