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

 -- Grid size 
Speed = 1
local G = ENV_WIDTH
StepMultiple = Shared.getNumber(2)
--StepMultiple = 4
function initializeAgent()
	-- Visible is the collision grid

	GridMovement = true	-- Visible is the collision grid
	say("Agent #: " .. ID .. " has been initialized")

	--Map.modifyColor(10,10,{255,255,255})
	Agent.changeColor{r=255, g=0, b=0}

	gotoX = Stat.randomInteger(0, ENV_HEIGHT)
	gotoY = Stat.randomInteger(0, ENV_WIDTH)

end

function handleEvent(sourceX, sourceY, sourceID, eventDescription, eventTable)

	
end

function takeStep()
	
	--say("gotoX: "..gotoX.." PositionX: "..PositionX.."gotoY: "..gotoY.." PositionY: "..PositionY)
	local dim = 100
	local color = {255,0,0}
	local res = Torus.squareSpiralTorusScanColor(dim,{255,255,255}, G)
	if res then
			withinRangeOfPrey = true
	end
	if withinRangeOfPrey == false then
		if Torus.reachedDestination(gotoX, gotoY) == true then
			gotoX = Stat.randomInteger(0, ENV_HEIGHT)
			gotoY = Stat.randomInteger(0, ENV_WIDTH)
		end
		if Moving == false then
			Moving = true
			Torus.move(gotoX, gotoY, G, color)
		end
	elseif withinRangeOfPrey == true then
		if math.abs(PositionX - res[1]["posX"]) < 2 and math.abs(PositionY - res[1]["posY"]) < 2 then
			Event.emit{sourceX = res[1]["posX"], sourceY = res[1]["posY"], speed=1000, description="Eaten"}
		end
	end
	-- move towards prey
	if res then
		Moving = true
		Torus.move(res[1]["posX"],res[1]["posY"], G, color)
	end			
	withinRangeOfPrey = false
end

function cleanUp()
	say("Agent #: " .. ID .. " is done\n")
	Map.modifyColor(PositionX,PositionY,{0,0,0})	

end
