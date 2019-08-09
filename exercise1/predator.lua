--begin_license--
--
--Copyright 	2013 - 2016 	Søren Vissing Jørgensen.
--
--This file is part of RANA.
--
--RANA is free software: you can redistribute it and/or modify
--it under the terms of the GNU General Public License as published by
--the Free Software Foundation, either version 3 of the License, or
--(at your option) any later version.
--
--RANA is distributed in the hope that it will be useful,
--but WITHOUT ANY WARRANTY; without even the implied warranty of
--MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--GNU General Public License for more details.
--
--You should have received a copy of the GNU General Public License
--along with RANA.  If not, see <http://www.gnu.org/licenses/>.
--
----end_license--

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
-- Speed 			-- Movement speed of the agent in meters pr. second.
-- Moving 			-- Denotes wether this agent is moving (default = false).
-- GridMove 		-- Is collision detection active (default = false).
-- ------------------------------------

-- Import valid Rana lua libraries.
Event = require "ranalib_event"
Stat = require "ranalib_statistic"
Move = require "ranalib_movement"
Agent = require "ranalib_agent"
Collision = require "ranalib_collision"
Shared = require "ranalib_shared"

above_count = 1
below_count = 1
speed = 10
Displacement = 1
STEP_RESOLUTION = 1
SPEED = 2
MAX_PREDATOR = Shared.getNumber(0)

-- Init of the lua frog, function called upon initilization of the LUA auton.
function initializeAgent()

	l_debug("Agent #: " .. ID .. " has been initialized") 

	PositionY = Stat.randomInteger(0,ENV_HEIGHT)
	PositionX = Stat.randomInteger(0,ENV_WIDTH)
	description = "predator"
	GridMove = true
	Moving = false
	--Change Color
	Agent.changeColor{r=255, g=0, b=0}
	withinRangeOfPrey = false
	counter = 0
	l_debug("POS :" .. PositionY .. " , " .. PositionX)
end

function handleEvent(sourceX, sourceY, sourceID, eventDescription, eventTable)
	
	
	
end

function takeStep()

	--movement
	--RAND XY POS
	if Moving == false then
		t = Collision.radialCollisionScan(20)
		
		if(t ~= nil) then
			withinRangeOfPrey = true
		end	

		if withinRangeOfPrey == false then
			local destX = 0
			local destY = 0
			randomInt = Stat.randomInteger(1,2)
			if  randomInt == 1 then
				destX = PositionX - 1
			elseif randomInt == 2 then
				destX = PositionX + 1
			end

			randomInt = Stat.randomInteger(1,2)
			if  randomInt == 1 then
				destY = PositionY - 1
			elseif randomInt == 2 then
				destY = PositionY + 1
			end
			
			if PositionX > ENV_WIDTH then 
				destX = 0 
			end
			if PositionY > ENV_HEIGHT then
				destY = 0	
			end

			if PositionX < 0 then 
				destX = ENV_WIDTH 
			end
			if PositionY < 0 then
				destY = ENV_HEIGHT
			end
			Move.to{x=destX,y=destY,speed=10}
			
		elseif withinRangeOfPrey == true then
			-- move towards prey
			 Move.to{x=t[1].posX,y=t[1].posY,speed=10}
		end
		Collision.updatePosition(PositionX, PositionY)
	end
end

function cleanUp()
	l_debug("Agent #: " .. ID .. " is done\n")
end

function ProcessEvent()

	return 2,0.1

end

