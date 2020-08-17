# fivem_framework
An old framework for a FiveM server I will not actively provide support for.

You are allowed to modify and use the code as you desire, just don't re-release it unmodified.

Functions;

Global

- `table.Contains(table TableToInspect, object ItemToFind)` --Returns a boolean of if ItemToFind is somewhere in TableToInspect.

- `tobool(object item)` --Will take any form of input and attempt to convert it into a boolean.

- `DevelopmentBuild()` -- Returns a boolean on whether the framework is configured for a non-release development environemnt.

- `Log(string resourceName, string mesageToLog, bool isMessageVerbose)` --If `config.VerboseLogging` matches `isMessageVerbose`, the message will log. The message will print in the console basic white If `DevelopmentBuild()` is true, otherwise, the message will be sent to and printed on the server and ommited on the client.

- `Warn(string resourceName, string mesageToLog, bool isMessageVerbose)` --If `config.VerboseLogging` matches `isMessageVerbose`, the message will log. The message will print in the console warning yellow If `DevelopmentBuild()` is true, otherwise, the message will be sent to and printed on the server and ommited on the client.

- `Error(string resourceName, string mesageToLog, bool isMessageVerbose)` --If `config.VerboseLogging` matches `isMessageVerbose`, the message will log. The message will print in the console vibrant red If `DevelopmentBuild()` is true, otherwise, the message will be sent to and printed on the server and ommited on the client.

- `Success(string resourceName, string mesageToLog, bool isMessageVerbose)` --If `config.VerboseLogging` matches `isMessageVerbose`, the message will log. The message will print in the console neon green If `DevelopmentBuild()` is true, otherwise, the message will be sent to and printed on the server and ommited on the client.

- `Info(string resourceName, string mesageToLog, bool isMessageVerbose)` --If `config.VerboseLogging` matches `isMessageVerbose`, the message will log. The message will print in the console faded blue If `DevelopmentBuild()` is true, otherwise, the message will be sent to and printed on the server and ommited on the client.

Server

- `TriggerClientCallback(string CallbackName, int PlayerIdTarget, function onResultExtracted, ...)` Triggers a client callback on one or all clients based on `PlayerIdTarget`. Blocks until a result is acquired or a timeout occurs.

- `RegisterServerCallback(string CallbackName, function CallbackMethod)` -- Registers an event-based synchronous callback on the server-side. Clients will call this with `local result = exports.dfs:TriggerServerCallback("callbackName", function(...), ...)`

- `GetTheirIdentifiers(int playerSourceID)` --Returns a table `{int ServerID, string DiscordID, string LicenseID, string SteamID, string XboxLiveID, string IPAddress, string LiveID, string UserID}`. License ID is rockstar license, LiveID is unknown, UserID is the unique ID assigned to the logged in character in the databases 'users' table.

- `GetTheirIdentity(in playerSourceID)` --Returns a table containing information relevant to a character from the 'users' table of the database. Note: This information will be out of date by your configured save timer in ESX if you use it. Table Contents; `{string JobName, int JobGrade, int PermissionLevel, string BadgeNumber, string FirstName, string LastName, string DateOfBirth, bool IsMale, int Height, string PhoneNumber}`

Client

- `TriggerServerCallback(string CallbackName, function onResultReturned, ...)` Triggers a server callback. Blocks until a result is acquired or a timeout occurs.

- `RegisterClientCallback(string CallbackName, function CallbackMethod)` -- Registers an event-based synchronous callback on the client-side. The server will call this with `local result = exports.dfs:TriggerClientCallback("callbackName", function(...), ...)`

- `SpawnVehicle(int modelHash, vector3 Position, float Heading, bool SetLocalPlayerInDriversSeat, bool GetKeysFor, bool BasicPersistent, bool ServerRestartPersistent, table VehicleProps, string PlateNumberText, bool EngineOn, table EnableExtrasList, int LiveryNumber, int FuelLevel)`. BasicPersistent uses GTA V persistence. ServerRestartPersistent uses enc0ded-vehicle-persistence. VehicleProps can either use a legacy version of ESX's vehicleprops, or DFS's built in vehicle props. If you do not have these functionalities, you can safely pass in nil to thesse arguments.

- `GetMyIdentity()` returns Server>GetTheirIdentity(MyServerID)

- `GetVehicleInFrontOfMe()` Returns a vehicle handle of a vehicle the player is looking at within sneezing range.

- `GetMyIdentifiers()` Returns Server>GetTheirIdentifiers(MyServerID)

- `GetAllPeds()` Returns a table of all ped handles spawned in the local world. This can be safely called every frame as actual ped gathering is done elsewhere.

- `DeleteVehicle(int vehicleHandle)` Deletes a netowrked or local vehicle in a classy, siple way with netowrk fading and returns a bool telling of its success.

- `DeleteVehicleAsync(int vehicleHandle, function callbackMethod)` The same thing as `DeleteVehicle`, but instead of returning a bool and locking the thread until completion, it will pass the success into `callbackMethod`.


- `GetAllObjects()` Returns a table of all object handles spawned in the local world. This can be safely called every frame as actual ped gathering is done elsewhere.


- `GetAllVehicles()` Returns a table of all vehicle handles spawned in the local world. This can be safely called every frame as actual ped gathering is done elsewhere.


- `GetAllPlayers()` Returns a table of all player server IDs spawned in the local world. This can be safely called every frame as actual ped gathering is done elsewhere.

- `GetVehicleProps(int vehicleHanlde)` Returns a table of vehicle properties similar to ESX 0.X.

- `SetVehicleProps(int vehicle, table Properties)`

-
