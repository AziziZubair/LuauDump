-- Sends players from one server to another
-- Takes player instances from a RemoteEvent
-------------------------------------
---------------Services--------------
-------------------------------------

ReplicatedStorage = game:GetService("ReplicatedStorage")
TeleportService = game:GetService("TeleportService")
ServerStorage = game:GetService("ServerStorage")
RunService = game:GetService("RunService")

-------------------------------------
--------------Instances--------------
-------------------------------------

local Folder = ReplicatedStorage:FindFirstChild("Teleporting")
local RemoteEvent = Folder:FindFirstChild("RemoteEvent")
local TeleportGui = ServerStorage:FindFirstChild("teleportGui")

-------------------------------------
----------------CODE-----------------
-------------------------------------

Queued_Players = {}
MIN_SIZE = 1
MAX_SIZE = 5

local function addToTable()
	RemoteEvent.OnServerEvent:Connect(function(plr)
		print("fired from server")
		table.insert(Queued_Players, plr)
		print(plr.Name)
	end)
end

thread = coroutine.create(addToTable)
coroutine.resume(thread)

local notUndergoing = true

RunService.Heartbeat:Connect(function()
	if #Queued_Players >= MIN_SIZE and notUndergoing then
		print("initial check success")
		notUndergoing = false
		local party = {}
		local minException
		
		
		-- Party Selection
		repeat 
			
			table.insert(party, Queued_Players[1])
			table.remove(Queued_Players, 1)
			
			if party == MIN_SIZE and #Queued_Players == 0 then
				minException = true
			else
				minException = false
			end
			
		until #party == MAX_SIZE or #Queued_Players == 0 or minException
		print("middle check success")
		print(party)
		print(Queued_Players)
		
		-- Server Reservation
		local access_code = nil
		repeat
			local success, failure = pcall(function()
				access_code = TeleportService:ReserveServer(15618090228)
			end)
		until access_code ~= nil
		
		
		-- Player Teleportation
		local teleported = nil
		repeat
			local success, failure = pcall(function()
				TeleportService:TeleportToPrivateServer(15618090228, access_code, party)
			end)
			
			if success then
				teleported = true
			end
		until teleported == true
		
		print("final check success")
		notUndergoing = true
	end
end)
