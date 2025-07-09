export type PropEntry = {
	Name:string;
	
	MaxCount:number;
	
	InteractPart:BasePart;
	
	Model:Model;
	
	ID:number;
	
	Pack:string;
	
	SpecialData:{[string]:any};
	
	OnPlace:(Prop_Model:Model) -> nil; -- Fires when placed and loaded;
	
	OnLoad:(Prop_Model:Model, CachedData:{}) -> nil; -- Passes the cached data from when you run the onload function. If no data is provided then it should be a empty table.
	
	OnDelete:(Prop_Model:Model) -> nil; -- Fired when deleted
	
	OnInteract:(Prop_Model:Model, Player:Player) -> nil; -- this is triggered then the `InteractPart` is touched
	
	OnSave:(Prop_Model:Model) -> {} -- The returned table will be saved to the prop and passed onload under the CachedData
}

export type PropFolder = {
	[number]:PropEntry
}

export type PropData = {
	ID:number;
	
	Position:{
		X:number;
		
		Y:number;
		
		Z:number;
		
		RX:number;
		
		RY:number;
		
		RZ:number
	};
	
	PropData:{}
}

export type PropSave = {
	Name:string;
	
	PropCount:number;
	
	PropData:{PropData}
}

export type PlayerInfo = {
	MaxProps:number;
	
	PropSaves:{PropSave}
}

return {}