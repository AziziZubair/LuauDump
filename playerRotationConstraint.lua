--[[

Purpose:
Adds players to a table and places their constraint instances underneath them; Then has a function that combines the constraint instances.
Current version of the code has latency issues since everything is server sided. A client sided version is recommended.

Last modified: 2023/12/08

]]--


-- Services
local RUN_SERVICE = game:GetService("RunService")


-- Main
_G.matchPlayers = {
	
	-- Player Variables
	plrCount = 0;			-- Tracks #of players in the match
	PLAYER_LIST = {};		-- Contains players and their essentials
	
	
	-- Runs setup on the player
	addConstraints = function(self, ...) -- must pass table
		
		
		for i,v in ipairs(...) do
			
			if self.PLAYER_LIST[v] == nil then
				
				print("Setting up constraints for",v.Name)
			
				-- Player data table
				self.PLAYER_LIST[v] = {
					["ConstraintUpdating"] = false;
					["Character"] = workspace:WaitForChild(v.Name); -- Character instance
				}
				
				
				-- Setup Humanoid
				self.PLAYER_LIST[v].Character:WaitForChild("Humanoid").JumpHeight = 0 -- Prevents upwards tilt
				self.PLAYER_LIST[v].Character:WaitForChild("Humanoid").JumpPower = 0 -- Also prevents tilting upwards
				self.PLAYER_LIST[v].Character:WaitForChild("Humanoid").AutoRotate = false
				
				
				-- Creates attachment for alignOrientation
				self.PLAYER_LIST[v]["Attachment"] = Instance.new("Attachment")
				self.PLAYER_LIST[v].Attachment.Name = "AlignOrientationAttachment"
				self.PLAYER_LIST[v].Attachment.Parent = self.PLAYER_LIST[v].Character:WaitForChild('HumanoidRootPart')
				self.PLAYER_LIST[v].Attachment.Position = Vector3.new(0,0,0) -- Centered with HumanoidRootPart
				
				
				-- Creates AlignOrientation 
				self.PLAYER_LIST[v]["AlignOrientation"] = Instance.new("AlignOrientation")
				self.PLAYER_LIST[v].AlignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
				self.PLAYER_LIST[v].AlignOrientation.Attachment0 = self.PLAYER_LIST[v].Attachment
				self.PLAYER_LIST[v].AlignOrientation.MaxTorque = 1000000
				self.PLAYER_LIST[v].AlignOrientation.Responsiveness = 200
				self.PLAYER_LIST[v].AlignOrientation.Parent = self.PLAYER_LIST[v].Character:WaitForChild("HumanoidRootPart")
				
				print("Finished setting up constraints for",v.Name)
				
			end
			
		end

	end;
	
	
	-- Links constraints of two players
	connectConstraints = function(self, plrIns1, plrIns2)
		if self.PLAYER_LIST[plrIns1] ~= nil and self.PLAYER_LIST[plrIns2] ~= nil then -- Checks if players are in the list
			if self.PLAYER_LIST[plrIns1].ConstraintUpdating ~= true and self.PLAYER_LIST[plrIns2].ConstraintUpdating ~= true then -- Makes sure that they're not undergoing constraint updates
				
				
				print('its working')
				self.PLAYER_LIST[plrIns1].ConstraintUpdating = true
				self.PLAYER_LIST[plrIns2].ConstraintUpdating = true
				
				local connection
				
				local function autoUpdate(plrIns1, plrIns2)
					local plr1LookAtCFrame = CFrame.lookAt(self.PLAYER_LIST[plrIns1].Character:FindFirstChild("HumanoidRootPart").Position, self.PLAYER_LIST[plrIns2].Character:FindFirstChild("HumanoidRootPart").Position)
					local plr2LookAtCFrame = CFrame.lookAt(self.PLAYER_LIST[plrIns2].Character:FindFirstChild("HumanoidRootPart").Position, self.PLAYER_LIST[plrIns1].Character:FindFirstChild("HumanoidRootPart").Position)

					self.PLAYER_LIST[plrIns1].AlignOrientation.CFrame = plr1LookAtCFrame
					self.PLAYER_LIST[plrIns2].AlignOrientation.CFrame = plr2LookAtCFrame

					if self.PLAYER_LIST[plrIns1].ConstraintUpdating ~= true or self.PLAYER_LIST[plrIns2].ConstraintUpdating ~= true then
						connection:disconnect()
					end
				end
				
				connection = RUN_SERVICE.Heartbeat:Connect(function()
					autoUpdate(plrIns1, plrIns2)
				end)
				
			else -- If players are undergoing constraint updates
				warn("Error Code 1: Players have active constraints")
				return {1, plrIns1, plrIns2}
			end
			
		
		else -- If the players are not found in the list
			warn("Error Code 0: Players not found")
			return {0, plrIns1, plrIns2}
		end 
	end;
	
	-- Unlinks constraints, keeping the player locked in their previous rotation
	disconnectConstraints = function(self, ...)
		for i, v in ipairs(...) do
			if self.PLAYER_LIST[v] ~= nil then
				self.PLAYER_LIST[v].ConstraintUpdating = false
			end
		end
	end;
	
	-- Removes player constraints, re-enables rotation, and places player outside of arena
	removeConstraints = function(self, ...)
		for i,v in ipairs (...) do
			if self.PLAYER_LIST[v] ~= nil then
				self.PLAYER_LIST[v].Character:FindFirstChild("Humanoid").AutoRotate = true
				self.PLAYER_LIST[v].AlignOrientation:Destroy()
				self.PLAYER_LIST[v].Attachment:Destroy()
				self.PLAYER_LIST[v] = nil
			end
		end
	end;
	
	-- Returns all players with active constraints
	getPlayersWithConstraints = function(self)
		return self.PLAYER_LIST
	end;
}
