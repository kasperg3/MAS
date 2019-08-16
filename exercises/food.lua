
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
Stat = require "ranalib_statistic" 
Agent = require "ranalib_agent"
Shared = require "ranalib_shared"
Map = require "ranalib_map"
Collision = require "ranalib_collision"
Torus = require "torus"
GridMove = true

function initializeAgent()
	-- Visible is the collision grid
	say("Agent (food) #: " .. ID .. " has been initialized")
	Agent.changeColor{g=255}
	MAX_FOOD = Shared.getNumber(4)
	foodSource = Stat.randomInteger(0, MAX_FOOD)
end

function handleEvent(sourceX, sourceY, sourceID, eventDescription, eventTable)
	if eventDescription == "EatFood" then 
		if Torus.distance(PositionX, PositionY, sourceX, sourceY, ENV_WIDTH, ENV_HEIGHT) <= 2 then 
			foodSource = foodSource - 1
			if foodSource < 0 then
				Map.modifyColor(PositionX,PositionY,{0,0,0})
				Agent.removeAgent(ID)
			end
		end
	end
end

function takeStep()
	Collision.updatePosition(PositionX,PositionY)
	--if Map.checkColor(PositionX,PositionY) ~= {0,255,0} then
		Map.modifyColor(PositionX,PositionY,{0,255,0})
	--end
end

function cleanUp()
	say("Agent #: " .. ID .. " is done\n")	
	Map.modifyColor(PositionX,PositionY,{0,0,0})
end
