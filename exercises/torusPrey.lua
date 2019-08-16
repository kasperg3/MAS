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
local G = ENV_WIDTH
StepMultiple = Shared.getNumber(3)
local doScan = true

function initializeAgent()
	-- Visible is the collision grid

	GridMovement = true	-- Visible is the collision grid

	GridMovement = true
	say("Agent #: " .. ID .. " has been initialized")

	gotoX = Stat.randomInteger(0, ENV_HEIGHT)
	gotoY = Stat.randomInteger(0, ENV_WIDTH)
	counter = 0
	sleepCounter = 0

end



function handleEvent(sourceX, sourceY, sourceID, eventDescription, eventTable)
	
	if eventDescription == "Eaten" then 
		if math.abs(PositionX - sourceX) < 2 and math.abs(PositionY - sourceY) < 2 then
			Map.modifyColor(PositionX,PositionY,{0,0,0})
			Agent.removeAgent(ID)
		end
	end
	
end



function takeStep()
	local color = {255,255,255}
	local dim = 50
	local res = Torus.squareSpiralTorusScanColor(dim,{255,0,0},G)
	local food = Torus.squareSpiralTorusScanColor(dim,{0,255,0},G)
	--If predator is withing range, move opposite direction
	if res then
		if Moving == false then
			local dest = getDestinationOppositeFromAgent(res)
			gotoX = dest["X"]
			gotoY = dest["Y"]
			Torus.move(dest["X"],dest["Y"], G, color)
		end
	elseif food then
		if Moving == false then
			gotoX =  food[1]["posX"]
			gotoY = food[1]["posY"]
			Torus.move(food[1]["posX"],food[1]["posY"], G, color)
			Event.emit{sourceX = food[1][""], sourceY = food[1]["posY"], speed=1, description="EatFood"}

		end
	elseif reachedDestination(gotoX, gotoY) == true then
		gotoX = Stat.randomInteger(0, ENV_HEIGHT)
		gotoY = Stat.randomInteger(0, ENV_WIDTH)
	elseif math.abs(PositionX - gotoX) > 1 or math.abs(PositionY - gotoY) > 1 then
		if Moving == false then	
			Moving = true;	
			Torus.move(gotoX, gotoY, G, color)
		end
	end
end

function reachedDestination(gotoX, gotoY)
	result = false
	if math.abs(PositionX - gotoX) < 2 or math.abs(PositionY - gotoY) < 2 then
		--say("1-posX:"..PositionX.." posY:"..PositionY.." gotoX:"..gotoX.." gotoY:"..gotoY)
		result = true
	end
	if math.abs(PositionX - gotoX - ENV_WIDTH) < 2 or math.abs(PositionY - gotoY - ENV_HEIGHT) < 2 then
		--say("2-posX:"..PositionX.." posY:"..PositionY.." gotoX:"..gotoX.." gotoY:"..gotoY)
		result = true
	end
	return result
end

function getDestinationOppositeFromAgent(res)
	local destX = res[1]["posX"]
	local destY = res[1]["posY"]
	local directionX = PositionX-destX
	local directionY = PositionY-destY

	-- Changing direction to go through the edge of the map if path is shorter
	if math.abs(directionX) > G/2 	then directionX = -directionX end
	if math.abs(directionY) > G/2 	then directionY = -directionY end
	
	-- Determining destination point
	if	directionX > 0 then destX = PositionX+1
	elseif	directionX < 0 then destX = PositionX-1
	else	destX = PositionX	end
	
	if	directionY > 0 then destY = PositionY+1
	elseif	directionY < 0 then destY = PositionY-1
	else	destY = PositionY	end
	
	-- Determining destination point if direction is through the edge of the map
	if destX < 0 then 
		destX = G-1
	elseif destX >= G then
		destX = 0
	end
	
	if destY < 0 then
		destY = G-1
	elseif destY >= G then
		destY = 0
	end

	return {X = destX, Y=destY}
end

function cleanUp()
	say("Agent #: " .. ID .. " is done\n")
	Map.modifyColor(PositionX,PositionY,{0,0,0})	
end
