return {
	[1] = {
		Name = "Example";
		
		MaxCount = 0;
		
		Pack = "Free Item"; -- Free Item is given by default
		
		Model = game.ServerStorage.Props:WaitForChild("MODEL"); -- model goes here
		
		SpecialData = {
			Tags = {"Storage", "Rust"} -- Example special data you could use
		}
	};

	[2] = {
		Name = "Example Special";
		
		MaxCount = 3; -- 3 of them can be used at a time per player
		
		Pack = "test"; -- only if they have the test pack
		
		Model = game.ServerStorage.Props:WaitForChild("MODEL"); -- model goes here
		InteractPart = game.ServerStorage.Props:WaitForChild("MODEL").Interact; -- MUST BE A BASEPART WITH CAN QUERY must be a direct child of the original mode.
		
		SpecialData = {
			Tags = {"Storage", "Rust"} -- Example special data you could use
		};

		OnPlace = function(Prop:Model)
			print("Placed")
		end;

		OnDelete = function(Prop:Model)
			print("DESTROYED")
		end;

		OnInteract = function(Prop:Model, Player:player)
			print("PRESSED")
		end;

		OnSave = function(Prop:Model)
			return  {IsCool = true}
		end;

		OnLoad = function(Prop:Model, CachedData:{})
			print(CachedData.IsCool)
		end;
	};
}