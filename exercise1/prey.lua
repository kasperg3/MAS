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
Collision = require "ranalib_collision"
Agent = require "ranalib_agent"
Shared = require "ranalib_shared"

SPEED = Shared.getNumber(3)

-- Init of the lua frog, function called upon initilization of the LUA auton.
function initializeAgent()

	l_debug("Agent #: " .. ID .. " has been initialized") 

	Moving = false
	GridMove = true

	if Moving==false then 	
		Move.to{x=Stat.randomInteger(0,ENV_WIDTH),y=Stat.randomInteger(0,ENV_HEIGHT)}
	end	
	Moving = false
	l_debug(ENV_HEIGHT)
end

function handleEvent(sourceX, sourceY, sourceID, eventDescription, eventTable)
	
	if eventDescription == "Eaten" then 
		say("Agent #: " .. ID .. " got eaten by Agent #: " .. sourceID )
		Agent.removeAgent(ID)
	end
	
end

function takeStep()

	--movement
	--RAND XY POS
	local destX = PositionX
	local destY = PositionY

	--say("Agent" .. ID .. ": Y-Pos: " .. randomInt)
	if Moving == false then 	
		Move.toRandom(SPEED) 
	end	

	Collision.updatePosition(PositionX, PositionY)

	--Event.emit{speed=343,description="EAT",table={msg="I am agent "..ID}}

end

function cleanUp()
	l_debug("Agent #: " .. ID .. " is done\n")
end

function ProcessEvent()

	return 2,0.1

end

