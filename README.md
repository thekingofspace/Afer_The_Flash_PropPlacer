# RAIKINS PROP PLACER SYSTEM

### WARNING THE GIT ROOT WILL NOT BE USABLE INSIDE THE GAME PLEASE REFER TO THE PUBLIC RELEASES!

Hello, fellow LOTA and ATF players! I’ve put together a wacky prop placement system inspired by ATF-8 and LOTA3. This document will walk you through how it works! I will include examples on how to use it but other then that you are on your own! This is not documenation for the included `Helper Modules` Do not mess with those if you do not know what you are doing.

To start you will need to require your module once on server once on client.

## Server
```lua
local PropPlacer = require(game.ReplicatedStorage.Prop_Placer__V7 -- Since this is server you do not need to wait for the module.

local Server = PropPlacer.GetServer()

Server:EasyInit()
```


## Client
```lua
local PropPlacer = require(game.ReplicatedStorage:WaitForChild("P_Placer"):WaitForChild("Prop_Placer__V7"))

local Client = PropPlacer.GetClient()

Client:BindStandardControls() -- This can be ignored if you are gonna custom bind it. just mind you this is not recommended
```
---
# LITE CODE GUIDE
## CLIENT

Gotten via `PropPlacer.GetClient()`

### `Client:BindStandardControls()`
```
This function will extend the standard control format to the prop placer for easy setup.

STANDARD CONTROL FORMATS:

F:
    - Place a prop or confirm editing a prop.

X:
    - Delete the selected prop.
    - Delete props you click while holding X.
    - Delete all selected props.
    - Cancel editing props.

E:
    - In selection mode: press E to enter group editing.
    - While holding E: click a prop to edit it individually.

LEFT ALT:
    - Toggle selection mode on or off.

Q:
    - In selection mode: select all props or unselect all props.

LEFT SHIFT:
    - In selection mode: hold to drag-select multiple props.

V:
    - Switch between manual dragging and follow-mouse placement.

R:
    - Switch to rotation mode for the selected prop.

T:
    - Switch to movement mode for the selected prop.
```

### `Client:GetInfo()`
```
Returns info from the server to the client `{MaxProps = NUMBER, Props = SaveData(Refer to TypeDefinitions.PropSave for assembly.), OwnerPacks = Table of packs owned.}`
```
---
### `Client:GetInfoLight()`
```
Returns info from the server to the client `{MaxProps = NUMBER, OwnerPacks = Table of packs owned.}` This was made as a lite version of GetInfo so it doesnt pass back a massive table of prop save info.
```
---
### `Client:GetProps()`
```
Returns props from the server refer to TypeDefinitions.PropFolder for assembly.
```
---
### `Client:GetPropModel(ID:number, Key:string)`
```
Returns a model clone of the prop BE SURE YOUR KEY IS SPECIAL TO WHAT YOU ARE GETTING.
```
---
### `Client:GetFolder()`
```
Returns the player prop folder.
```
---
### `Client:SwitchBlock(Value:boolean)`
```
Blocks any standard input keybinds. Such as if the prop placer is hidden. Also simulates the X input to clear and props being edited.
```
---
### `Client:SetAngle(Type:string)`
```
Switches between Global and Local editing.. Type should either be "Global" or "Local"
```

---
### `Client:GetAngle()`
```
Returns either "Global" or "Local" depending on what is being edited.
```
---
### `Client:SetMoveSnap(Level:number)`
```
Sets the snap level for translation editing.
```

---
### `Client:SetRotSnap(Level:number)`
```
Sets the snap level for rotation editing.
```

---
### `Client:GetPropCount()`
```
Returns number of props
```

---
### `Client:RemoveAllProps()`
```
Removes all props. I would recommend adding some kinda check before using this function.
```

---
### `Client:SwitchEdit()`
```
Enters edit mode for the prop placer.
```

---
### `Client:LoadSave(Save:number, Near:boolean)`
```
Load a save using the save number, if near is true then it will replicate near the player.
```

---
### `Client:Save(Save:number, SaveName:string)`
```
Saves all the players props. save name will change the props save name.
```

---
### `Client:PlaceProp(ID:number)`
```
Enters place mode for the selected prop.
```
---
### `Client.Changed`
```
A callback that will run any time a angle is changed betwen "Global" or "Local"
```

---
### `Client.OnPlace`
```
MUST ASSING A FUNCTION TO THIS

Runs on prop placed.
```

---
### `Client.OnDelete`
```
MUST ASSING A FUNCTION TO THIS

Runs on prop deleted
```

---
### `Client.OnInteract`
```
MUST ASSING A FUNCTION TO THIS

Runs on prop interacted with. This only means local edits not interaction part.
```

---
### `Client.OnSelect`
```
MUST ASSING A FUNCTION TO THIS

Runs when the props selection box is clicked.
```

## SERVER

Gotten via `PropPlacer.GetServer()`

---
### `Server:EasyInit()`
```
Adds all the stuff the server needs to run.
```

---
# TECHNICAL CODE GUIDE
## Client

### `Client:MakePropContainer(Props:{Model})`
```
Creates and returns a "Prop Container" Prop containers are just a formatted model that contains several props.
```

---
### `Client:UnMakeContainer(Container:Model)`
```
Takes a prop container and  unmakes it (BURN IT ALL!!!!!) This will not return anything this just destroy it in a proper format.
```

---
### `Client:GetContainerContents(Container:Model)`
```
Gets a aray of all models within said container.
```

---
### `Client:EditContainer(Container:Model)`
```
Edits a prop container.
```

## Server
This segment will be for aspects of the `PlayerControllers` a child of the server module. this will just contain basic info not nitty griddy of the entire thing.
### `PlayerController:GetMaxProps(PL:Player)`
```
Returns that players max propcount
```
---
### `PlayerController:SetMaxProps(PL:Player, Count:number)`
```
Sets the max prop count for a player THIS WILL SAVE HOWEVER SO BE SURE YOU KNOW WHAT YOUR DOING.
```

---
### `PlayerController:SetMaxPropsTemp(PL:Player, Count:number)`
```
Sets a temp prop count for the player increasing for just that server until they leave.
```
---
### `PlayerController:GrantPack(PL:Player, Pack:string)`
```
Grants a prop pack to a player.
```
---
### `PlayerController:GetSave(PL:Player, Save:number)`
```
Returns either a specific save is Save is piped in or all saves.
```
---
### `PlayerController:WriteSave(PL:Player, Save:number, Data)`
```
Writes a save using data, BE SURE DATA IS FORMATTED CORRECT.
```
---
### `PlayerController:OwnsPack(PL:Player, Pack:string)`
```
Returns a boolean of if the player owns the pack or not.
```
---
### `PlayerController:GetPacks(PL:Player)`
```
Returns all packs the player owns.
```