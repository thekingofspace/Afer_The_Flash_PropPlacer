local StandardEnum = {
	__eq = function(Aray, Value)
		return Aray.ID == Value.ID and Aray.Category == Value.Category and Aray.Value == Value.Value
	end,

	__tostring = function(Aray)
		return string.lower(`Enum.{Aray.Category}.{Aray.Name}`)
	end,

	ToSerializable = function(self)
		return {
			Category = self.Category,
			Name = self.Name
		}
	end
}

export type Custom_Enum = {
	Value: any;

	ID: number;

	Category: string;

	Name: string;


	ToSerializable: (self: Custom_Enum) -> {
		Category: string,
		Name: string
	}
}


StandardEnum.__index = StandardEnum


local MainEnums = {
	Weather_Chance = {
		Mythic = {
			Value =  1;
		}::Custom_Enum;

		Legendary = {
			Value =  2;
		}::Custom_Enum;

		Epic = {
			Value =  3;
		}::Custom_Enum;

		Rare = {
			Value =  4;
		}::Custom_Enum;

		Uncommon = {
			Value =  5;
		}::Custom_Enum;
		
		Common = {
			Value =  6;
		}::Custom_Enum;
	};
	
	Time_Type = {
		Hour = {
			Value =  1;
		}::Custom_Enum;

		Minute = {
			Value =  2;
		}::Custom_Enum;
		
		Seconds = {
			Value =  2;
		}::Custom_Enum;
	};
	
	ActionType = {
		Leave = {
			Value =  "Leave";
		}::Custom_Enum;

		Enter = {
			Value =  "Enter";
		}::Custom_Enum;
	};
}



for I, item in pairs(MainEnums) do
	local Count = 0
	for E, Enumerator in pairs(item) do
		Count+=1

		if Enumerator.ID == nil then
			Enumerator.ID = Count
		end

		Enumerator.Category = I

		Enumerator.Name = E

		local NewEnum:Custom_Enum = setmetatable(Enumerator, StandardEnum)

		MainEnums[I][E] = NewEnum
	end
end

function MainEnums:FromSerializable(data):Custom_Enum
	assert(type(data) == "table", "Data must be a table")
	assert(data.Category and data.Name, "Serialized data must have Category and Name")

	local categoryTable = MainEnums[data.Category]
	assert(categoryTable, `No such enum category: {data.Category}`)

	local enum = categoryTable[data.Name]
	assert(enum, `No such enum name: {data.Name} in category {data.Category}`)

	return enum
end


return MainEnums