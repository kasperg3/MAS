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


function initializeAgent()

	GridMovement = true	-- Visible is the collision grid
	say("Agent #: " .. ID .. " has been initialized")
	Agent.changeColor{r=255}	
	color = {255, 0, 0}	

	-- parameters
	energy = Shared.getNumber(1) -- current energy
	FULL_ENERGY = Shared.getNumber(1)
	LOW_ENERGY = Shared.getNumber(2)
	G = Shared.getNumber(3)
	P = Shared.getNumber(4)
	Q = Shared.getNumber(5)

	doScan = false
	base = false -- not at base (for now)

	gotoX = PositionX -- Starts in reachedDestination and gets a new one
	gotoY = PositionY -- Starts in reachedDestination and gets a new one

	baseX = PositionX
	baseY = PositionY


end

function handleEvent(sourceX, sourceY, sourceID, eventDescription, eventTable)
	
end



function takeStep()
	LOW_ENERGY = ENV_HEIGHT * 0.7
	if Moving == false then
		say("energy left: "..energy)
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
		elseif ores then
			Event.emit{sourceX = ores[1]["posX"], sourceY = ores[1]["posY"], speed=1000, description="oreDetected"}
			energy = energy - 1	
			ores = nil

		elseif doScan == false then
			-- random Movement
			if Torus.reachedDestination(gotoX, gotoY) == true then
				gotoX = Stat.randomInteger(0, ENV_HEIGHT)
				gotoY = Stat.randomInteger(0, ENV_WIDTH)
				doScan = true 
			else
				Moving = true
				Torus.move(gotoX, gotoY, G, color)
				--say("movement: "..Q * Torus.distance(gotoX, gotoY, PositionX, PositionY, ENV_WIDTH, ENV_HEIGHT)
				energy = energy - Q
			end
		elseif doScan == true then
			ores = Torus.squareSpiralTorusScanColor(P,{255,255,255}, G)
			energy = energy - P
			doScan = false
		end
	end
end


function cleanUp()
	say("Agent #: " .. ID .. " is done\n")
	Map.modifyColor(PositionX,PositionY,{0,0,0})	
end
