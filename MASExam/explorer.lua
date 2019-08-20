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
	--say("Agent #: " .. ID .. " has been initialized")
	Agent.changeColor{r=255}	
	color = {255, 0, 0}	

	-- parameters
	energy = Shared.getNumber(1) -- current energy
	FULL_ENERGY = Shared.getNumber(1)
	LOW_ENERGY = Shared.getNumber(2)
	G = Shared.getNumber(3)
	P = Shared.getNumber(4)
	Q = Shared.getNumber(5)
	S = Shared.getNumber(6)

	doScan = false
	base = false -- not at base (for now)
	timeIsUp = false

	gotoX = PositionX -- Starts in reachedDestination and gets a new one
	gotoY = PositionY -- Starts in reachedDestination and gets a new one

	baseX = PositionX
	baseY = PositionY


end

function handleEvent(sourceX, sourceY, sourceID, eventDescription, eventTable)
	if eventDescription == "timesUp" then
		timeIsUp = true
	end
end



function takeStep()
	LOW_ENERGY = ENV_HEIGHT * 0.7
	if Moving == false then
		if energy < 0 then
			say("AGENT DIED!")
			Event.emit{speed=1000000, description="deadAgent"}
			Map.modifyColor(PositionX,PositionY,{0,0,0})
			Agent.removeAgent(ID)
		elseif timeIsUp == true then
			--say("time is up")
			if Torus.reachedDestination(baseX, baseY) == false then
				Moving = true
				Torus.move(baseX, baseY, G, color)
				energy = energy - Q 
				--say("moving towards base")
			else
				Collision.updatePosition(-1,-1)
				Map.modifyColor(DestinationX,DestinationY,{0,0,0})
				Agent.removeAgent(ID) -- remove to make space for others
			end
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
			--TODO: Add memory to store values and transmit to transporter, if value already is present, dont add
			Event.emit{sourceX = PositionX, sourceY = PositionY, speed=1000000, description="oreDetected", table = {oreX=ores[1]["posX"], oreY=ores[1]["posY"]}}
			energy = energy - 1	
			ores = nil
		elseif doScan == true then
			ores = Torus.squareSpiralTorusScanColor(P,{255,255,255}, G)
			energy = energy - P
			doScan = false
		else --RANDOM MOVEMENT
			if Torus.reachedDestination(gotoX, gotoY) == true then
				doScan = true
				local randSteps = Stat.randomInteger(0, ENV_HEIGHT/5) -- 1/5 because of perception range
				while Torus.distance(PositionX,PositionY,gotoX,gotoY,ENV_WIDTH,ENV_HEIGHT) < randSteps do
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
