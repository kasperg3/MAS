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

--Edit these from the master agent
MAX_PREDATOR = Shared.getNumber(0)
SPEED = Shared.getNumber(2)

-- Init of the lua frog, function called upon initilization of the LUA auton.
function initializeAgent()

	l_debug("Agent #: " .. ID .. " has been initialized") 

	PositionY = Stat.randomInteger(0,ENV_HEIGHT)
	PositionX = Stat.randomInteger(0,ENV_WIDTH)
	description = "predator"
	GridMove = true
	Moving = false
	Agent.changeColor{r=255, g=0, b=0}
	withinRangeOfPrey = false
	counter = 0
	STEPS = 20
	l_debug("POS :" .. PositionY .. " , " .. PositionX)
end

function handleEvent(sourceX, sourceY, sourceID, eventDescription, eventTable)
	
	
	
end

function takeStep()

	--movement
	--RAND XY POS
	if Moving == false then
		t = Collision.radialCollisionScan(20)
		tableID = 0
		if(t ~= nil) then
			if t[1].id > MAX_PREDATOR then 
				withinRangeOfPrey = true
			end
		end	

		if withinRangeOfPrey == false then
			local destX = PositionX
			local destY = PositionY
			
			if counter % STEPS == 0 then
				randomX = Stat.randomInteger(0,2)
				randomY = Stat.randomInteger(0,2)
				counter = 0
			end
			counter = counter + 1

			if  randomX == 1 then 
				destX = PositionX - 1
			elseif randomX == 2 then 
				destX = PositionX + 1
			end

			if  randomY == 1 then 
				destY = PositionY - 1
			elseif randomY == 2 then 
				destY = PositionY + 1
			end
			
			--Wrap around
			if PositionX > ENV_WIDTH then destX = 0 end
			if PositionY > ENV_HEIGHT then destY = 0 end
			if PositionX < 0 then destX = ENV_WIDTH end
			if PositionY < 0 then destY = ENV_HEIGHT end
			
			Move.to{x=destX,y=destY,speed=SPEED}
			
		elseif withinRangeOfPrey == true then
			--Check if the prey is within reach
			if PositionX == t[1].posX + 1 or  PositionX == t[1].posX or PositionX == t[1].posX - 1 then
				if PositionY == t[1].posY or PositionY == t[1].posY + 1 or PositionY == t[1].posY - 1 then
					Event.emit{targetID=t[1].id, speed=1000, description="Eaten"}
				end
			end
			-- move towards prey
			Move.to{x=t[1].posX,y=t[1].posY,speed=SPEED}
			withinRangeOfPrey = false
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

