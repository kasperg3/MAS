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

--FIFO 
FIFO = require "fifo"
memory = FIFO():setempty(function() return nil end)

function initializeAgent()

	GridMovement = true	-- Visible is the collision grid
	say("Agent #: " .. ID .. " has been initialized")
	Agent.changeColor{g=255}	
	color = {0, 255, 0}	

	-- parameters
	energy = Shared.getNumber(1) -- current energy
	FULL_ENERGY = Shared.getNumber(1)
	LOW_ENERGY = Shared.getNumber(2)
	G = Shared.getNumber(3)
	P = Shared.getNumber(4)
	Q = Shared.getNumber(5)
	W = Shared.getNumber(7)
	oreStored = 0
	oreLocated = false
	doScan = false
	base = false -- not at base (for now)

	gotoX = PositionX -- Starts in reachedDestination and gets a new one
	gotoY = PositionY -- Starts in reachedDestination and gets a new one

	baseX = PositionX
	baseY = PositionY

end



function handleEvent(sourceX, sourceY, sourceID, eventDescription, eventTable)
	--TODO: CHECK RANGE
	if eventDescription == "oreDetected" and oreLocated == false then 
		oreLocated = true
		
		for i = 1, memory:length() do 
			if memory:peek(i)["oreX"] == eventTable["oreX"] and memory:peek(i)["oreY"] == eventTable["oreY"] then
				memory:remove(i)
			end
		end
		memory:push({eventTable["oreX"],eventTable["oreY"]})

		say("TRANSPORTER: MEMORY SIZE: " .. memory:length())

	end
end



function takeStep()
	local LOW_ENERGY = ENV_HEIGHT * 0.7
	if Moving == false then
		if energy < 0 then
			say("AGENT DIED!")
			Map.modifyColor(PositionX,PositionY,{0,0,0})
			Agent.removeAgent(ID)
		elseif Torus.distance(PositionX, PositionY, baseX, baseY, ENV_WIDTH, ENV_HEIGHT) < 2 and energy ~= FULL_ENERGY then -- if base and not full energy
			--charge
			energy = FULL_ENERGY
		elseif energy < LOW_ENERGY then
			-- return base
			Moving = true
			Torus.move(baseX, baseY, G, color)
			--say("movement: "..Q * Torus.distance(baseX, baseY, PositionX, PositionY, ENV_WIDTH, ENV_HEIGHT)
			energy = energy - Q 
		elseif oreStored == W then
				--say("Stored ores" )
				if Torus.distance(PositionX, PositionY, baseX, baseY, ENV_WIDTH, ENV_HEIGHT) < 2 then
					energy = FULL_ENERGY
					oreStored = 0
				else
					Moving = true
					Torus.move(baseX, baseY, G, color)
					energy = energy - Q
					say("STORAGE FULL GOING TO BASE")
				end
		elseif oreLocated == true then
			if Torus.distance(PositionX,PositionY,memory:peek()[1], memory:peek()[2], ENV_WIDTH,ENV_HEIGHT) < 2 then
				oreLocated = false
				Event.emit{sourceX = PostionX, sourceY = PositionY, speed=1000000, description="oreDepleted", table={oreX = memory:peek()[1], oreY = memory:peek()[2]}}
				say("TRANSPORTER: " .. "ORE: " ..  memory:peek()[1] .. " " .. memory:peek()[2])
				memory:pop() --Remove ore from memory
				energy = energy - 1
				oreStored = oreStored + 1
			else
				Moving = true
				--say("MOVING TO ORE: " .. memory:peek()[1] .. " " .. memory:peek()[2])
				Torus.move(memory:peek()[1], memory:peek()[2], G, color)
				energy = energy - Q
			end

		else
			-- random Movement
			if Torus.reachedDestination(gotoX, gotoY) == true then
				gotoX = Stat.randomInteger(0, ENV_HEIGHT)
				gotoY = Stat.randomInteger(0, ENV_WIDTH)
			else
				Moving = true
				Torus.move(gotoX, gotoY, G, color)
				--say("movement: "..Q * Torus.distance(gotoX, gotoY, PositionX, PositionY, ENV_WIDTH, ENV_HEIGHT)
				energy = energy - Q
			end

		end
	end
end



function cleanUp()
	say("Agent #: " .. ID .. " is done\n")
	Map.modifyColor(PositionX,PositionY,{0,0,0})	
end
