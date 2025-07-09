local module = {}

function module:CreateSignal()
	local self = {}
	local Connections = {}
	local WaitingThreads = {}

	function self:Connect(Callback: (...any) -> ())
		assert(typeof(Callback) == "function", "Callback must be a function")

		local Connection = {}
		Connection.Callback = Callback
		Connection.IsConnected = true

		function Connection:Disconnect()
			Connection.IsConnected = false
		end

		table.insert(Connections, Connection)

		return Connection
	end

	function self:Wait(timeout: number?)
		local thread = coroutine.running()
		local fired = false
		local result = nil
		local timeoutTask = nil

		local function continue(...)
			if fired then return end
			fired = true
			result = table.pack(...)
			if timeoutTask then
				task.cancel(timeoutTask)
			end
			coroutine.resume(thread)
		end

		table.insert(WaitingThreads, continue)

		if timeout and timeout > 0 then
			timeoutTask = task.delay(timeout, function()
				if fired then return end
				fired = true
				for i, waiter in ipairs(WaitingThreads) do
					if waiter == continue then
						table.remove(WaitingThreads, i)
						break
					end
				end
				coroutine.resume(thread)
			end)
		end

		coroutine.yield()

		if result then
			return table.unpack(result, 1, result.n)
		end

		return nil
	end

	function self:Fire(...)
		local args = table.pack(...)

		for _, connection in ipairs(Connections) do
			if connection.IsConnected then
				connection.Callback(...)
			end
		end

		if #WaitingThreads > 0 then
			local toResume = table.clone(WaitingThreads)
			table.clear(WaitingThreads)
			for _, resumeFn in ipairs(toResume) do
				resumeFn(table.unpack(args, 1, args.n))
			end
		end
	end

	return self
end

function module:CreateReadOnlySignal(realSignal)
	assert(realSignal and typeof(realSignal.Connect) == "function", "Expected a signal object")

	local public = {}

	function public:Connect(...)
		return realSignal:Connect(...)
	end

	function public:Wait(timeout)
		return realSignal:Wait(timeout)
	end

	return public
end

return module
