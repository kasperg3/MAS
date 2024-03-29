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
--Torus = require "torus"


function initializeAgent()

	GridMovement = true	-- Visible is the collision grid
	--say("Agent #: " .. ID .. " has been initialized")
	Agent.changeColor{r=255, g=255, b=255}	
	if PositionX == ENV_WIDTH then
		PositionX = PositionX - 1
	elseif PositionX == 0 then 
		PositionX = PositionX + 1
	end
	if PositionY == ENV_WIDTH then PositionY = PositionY - 1
	elseif PositionY == 0 then PositionY = PositionY + 1 end
end



function handleEvent(sourceX, sourceY, sourceID, eventDescription, eventTable)
	if eventDescription == "oreDepleted" and eventTable["oreX"] == PositionX and eventTable["oreY"] == PositionY then
		Map.modifyColor(PositionX,PositionY,{0,0,0})	
		Event.emit{sourceX = PostionX, sourceY = PositionY, speed=1000000, description="oreDepletedACK", table={transporterID = sourceID}}
		--say("ORE: sending ACK to ID#: " .. sourceID )
		Agent.removeAgent(ID)
	end
end



function takeStep()
	Collision.updatePosition(PositionX,PositionY)
	Map.modifyColor(PositionX,PositionY,{255,255,255})
end


function cleanUp()
	--say("Agent #: " .. ID .. " is done\n")
	Map.modifyColor(PositionX,PositionY,{0,0,0})	
end
