--The following global values are set via the simulation core:
-- ------------------------------------
-- IMMUTABLES.
-- ------------------------------------
-- ID -- id of the agent.
-- STEP_RESOLUTION 	-- resolution of steps, in the simulation core.
-- EVENT_RESOLUTION	-- resolution of event distribution.
-- ENV_WIDTH -- Width of the environment in meters.
-- ENV_HEIGHT -- Height of the environment in meters.
-- ------------------------------------
-- VARIABLES.
-- ------------------------------------
-- PositionX	 	-- Agents position in the X plane.
-- PositionY	 	-- Agents position in the Y plane.
-- DestinationX 	-- Agents destination in the X plane. 
-- DestinationY 	-- Agents destination in the Y plane.
-- StepMultiple 	-- Amount of steps to skip.
-- Speed 		-- Movement speed of the agent in meters pr. second.
-- Moving 		-- Denotes wether this agent is moving (default = false).
-- GridMove 		-- Is collision detection active (default = false).
-- ------------------------------------

-- Import Rana lua modules.
Event = require "ranalib_event"
Stat = require "ranalib_statistic"
Collision = require "ranalib_collision"
Map = require "ranalib_map"
Stat = require "ranalib_statistic"
Agent = require "ranalib_agent"
Shared = require "ranalib_shared"
Torus = require "torus"
Core = require "ranalib_core"

--FIFO 
local FIFO = require "fifo"
local memory = FIFO():setempty(function() return nil end)

local respondAck = false
local explorerID = nil

function initializeAgent()

	GridMovement = true	-- Visible is the collision grid
	--say("Agent #: " .. ID .. " has been initialized")
	Agent.changeColor{g=255}	
	color = {0, 255, 0}	

	groupID = tostring(PositionX) .. tostring(PositionY)

	-- parameters
	energy = Shared.getNumber(1) -- current energy
	FULL_ENERGY = Shared.getNumber(1)
	LOW_ENERGY = Shared.getNumber(2)
	G = Shared.getNumber(3)
	P = Shared.getNumber(4)
	Q = Shared.getNumber(5)
	S = Shared.getNumber(6)
	W = Shared.getNumber(7)
	I = Shared.getNumber(8)
	M = Shared.getNumber(9)

	oreStored = 0
	oreLocated = false
	doScan = false
	base = false -- not at base (for now)
	unloadingOreSend = false
	gotoX = PositionX -- Starts in reachedDestination and gets a new one
	gotoY = PositionY -- Starts in reachedDestination and gets a new one

	baseX = PositionX
	baseY = PositionY
	scanForBase = false
	timeIsUp = false

end



function handleEvent(sourceX, sourceY, sourceID, eventDescription, eventTable)

	if eventDescription == "oreDepletedACK" then
		--say("Agent #: " .. ID .. "recieved ACK with ID#:" .. eventTable["transporterID"])
		if eventTable["transporterID"] == ID then
			oreStored = oreStored + 1
		end
	end

	if eventDescription == "timesUp" then
		timeIsUp = true
	end
	if Torus.distance(sourceX, sourceY, PositionX, PositionY, ENV_WIDTH, ENV_HEIGHT) < I/2 then
		--say("des: " .. eventDescription)
		senderID = nil
		if eventDescription == "availabilityRequest" then
			senderID = eventTable["targetGroup"]
			--say("T: tg" .. senderID .. " my ID " .. groupID)
		end
		if eventDescription == "explorerAck" then
			senderID = eventTable[#eventTable]["targetGroup"]
			--say("T: tg" .. senderID .. " my ID " .. groupID)	
		end
		--say("M: " .. M)
		if M == 0 or senderID == groupID then -- only do this if same targetID or M == 0 (working together)
			--say("T: agree")
			if eventDescription == "availabilityRequest" then
				if memory:peek(1) == nil then 
					respondAck = true
					explorerID = sourceID
				end
			end

			if eventDescription == "explorerAck"  and eventTable[#eventTable-1]["ackID"] == ID then -- -1 because the last element is targetID
				--say("T: Agent #: " .. ID .. " Recieved ACK from Agent: " .. sourceID)
				for k = 1, #eventTable-2 do -- -2 because there is ackID and targetID
					if memory:length() < S then 
						memory:push({eventTable[k]["oreX"],eventTable[k]["oreY"]})
					else
						memory:pop()
						memory:push({eventTable[k]["oreX"],eventTable[k]["oreY"]})
					end
				end
				oreLocated = true	
			end
		else
			--say("T: denied")
		end
		if eventDescription == "oreStored" then
			if eventTable["destinationID"] == ID then
				unloadingOreSend = false
				oreStored = eventTable["oresReturned"]	
				if oreStored ~= 0 and M == 0 then
					--FIND NEW BASE	
					baseX = nil
					baseY = nil
				end
			end
		end
	end
end

function findBase()
	if scanForBase == true then
		base = Torus.squareSpiralTorusScanColor(P,{0,0,255}, G)
		scanForBase = false
		energy = energy - P
		if base ~= nil then
			baseX = base[1]["posX"]
			baseY = base[1]["posY"]
		end
	else
		if Torus.reachedDestination(gotoX, gotoY) == true then
			gotoX = Stat.randomInteger(0, ENV_HEIGHT)
			gotoY = Stat.randomInteger(0, ENV_WIDTH)
			scanForBase = true
		else
			Moving = true
			Torus.move(gotoX, gotoY, G, color)
			energy = energy - Q
		end
	end
end

function takeStep()
	--say(Core.time())
	local LOW_ENERGY = ENV_HEIGHT * 0.7
	if memory:length() == 0 then oreLocated = false end
	if Moving == false then
		if energy < 0 then
			say("AGENT DIED!")
			Event.emit{speed=1000000, description="deadAgent"}
			Map.modifyColor(PositionX,PositionY,{0,0,0})
			Agent.removeAgent(ID)
		elseif timeIsUp == true then						--TIMEOUT, return to base
			--say("time is up")
			if baseX == nil and baseY == nil then -- Find base
				findBase()
			elseif Torus.reachedDestination(baseX, baseY) == false then
				Moving = true
				Torus.move(baseX, baseY, G, color)
				energy = energy - Q 
			else -- Unload ores before deleting the agent
				Event.emit{sourceX = PostionX, sourceY = PositionY, sourceID = ID, speed=1000000, description="unloadingOre", table={ores=oreStored}}
				Collision.updatePosition(-1,-1)
				Map.modifyColor(DestinationX,DestinationY,{0,0,0})
				Agent.removeAgent(ID) -- remove to make space for others
			end
		elseif baseX == nil and baseY == nil then 			--Find base if a base is full
			if M == 0 then
				findBase()
			end
		elseif Torus.distance(PositionX, PositionY, baseX, baseY, ENV_WIDTH, ENV_HEIGHT) < 2 and energy ~= FULL_ENERGY then -- if in base and not full energy
			energy = FULL_ENERGY
			if unloadingOreSend == false and oreStored ~= 0 then --If in base to charge, unload ores if carrying any
				Event.emit{sourceX = PostionX, sourceY = PositionY, sourceID = ID, speed=1000000, description="unloadingOre", table={ores=oreStored}}
				--say("Agent #: ".. ID .. " Unloading ores " .. oreStored )
				unloadingOreSend = true
			end
		elseif energy < LOW_ENERGY then 					-- If low energy return to base
			Moving = true
			Torus.move(baseX, baseY, G, color)
			energy = energy - Q 
		elseif oreStored == W then 							-- If capacity reached, return to base
			Moving = true
			Torus.move(baseX, baseY, G, color)
			energy = energy - Q

		elseif respondAck == true then 
			--say("T: Agent #: " .. ID .. " Respond to ACK form Agent #: " .. explorerID)
			Event.emit{sourceX = PostionX, sourceY = PositionY, speed=1000000, description="transporterAcknowledge", table={transporterID = ID, targetGroup = groupID}}
			respondAck = false
		elseif oreLocated == true then 						-- If Ore located 
			if memory:length() == 0 then say("RIP") end
			if Torus.distance(PositionX,PositionY,memory:peek()[1], memory:peek()[2], ENV_WIDTH,ENV_HEIGHT) < 2 then
				--if Torus.compareTables(Map.checkColor(memory:peek()[1],memory:peek()[2]), {255,255,255}) then 
				Event.emit{sourceX = PostionX, sourceY = PositionY, speed=1000000, description="oreDepleted", table={oreX = memory:peek()[1], oreY = memory:peek()[2]}}
				memory:pop() --Remove ore from memory
				energy = energy - 1
			else
				Moving = true
				Torus.move(memory:peek()[1], memory:peek()[2], G, color)
				energy = energy - Q
			end
		else -- random Movement
			if Torus.reachedDestination(gotoX, gotoY) == true then
				gotoX = Stat.randomInteger(0, ENV_HEIGHT)
				gotoY = Stat.randomInteger(0, ENV_WIDTH)
				local randSteps = Stat.randomInteger(0, I)
				while Torus.distance(PositionX,PositionY,gotoX,gotoY,ENV_WIDTH,ENV_HEIGHT) > randSteps do
					gotoX = Stat.randomInteger(0, ENV_HEIGHT)
					gotoY = Stat.randomInteger(0, ENV_WIDTH)
				end
			else
				Moving = true
				Torus.move(gotoX, gotoY, G, color)
				energy = energy - Q
			end

		end
	end
end



function cleanUp()
	--say("Agent #: " .. ID .. " is done\n")
	Map.modifyColor(PositionX,PositionY,{0,0,0})	
end
