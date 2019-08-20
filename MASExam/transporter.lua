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
	--say("Agent #: " .. ID .. " has been initialized")
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
	I = Shared.getNumber(8)
	M = Shared.getNumber(9)
	oreStored = 0
	oreLocated = false
	doScan = false
	base = false -- not at base (for now)
	unloadingOreSend = false
	gotoX = PositionX -- Starts in reachedDestination and gets a new one
	gotoY = PositionY -- Starts in reachedDestination and gets a new one

	baseX = PositionX
	baseY = PositionY
	scanForBase = false
	timeIsUp = false

end



function handleEvent(sourceX, sourceY, sourceID, eventDescription, eventTable)
	if eventDescription == "timesUp" then
		timeIsUp = true
	end
	if Torus.distance(sourceX, sourceY, PositionX, PositionY, ENV_WIDTH, ENV_HEIGHT) < I/2 then
		if eventDescription == "oreDetected" and oreLocated == false then 
			oreLocated = true
			for i = 1, memory:length() do 
				if memory:peek(i)["oreX"] == eventTable["oreX"] and memory:peek(i)["oreY"] == eventTable["oreY"] then
					memory:remove(i)
				end
			end
			memory:push({eventTable["oreX"],eventTable["oreY"]})
		end

		if eventDescription == "oreStored" then
			if eventTable["destinationID"] == ID then
				unloadingOreSend = false
				oreStored = eventTable["oresReturned"]	
				if oreStored ~= 0 and M == 0 then
					--FIND NEW BASE	
					baseX = nil
					baseY = nil
				end
			end
		end
	end
end

function takeStep()
	local LOW_ENERGY = ENV_HEIGHT * 0.7
	if Moving == false then
		if energy < 0 then
			say("AGENT DIED!")
			Event.emit{speed=1000000, description="deadAgent"}
			Map.modifyColor(PositionX,PositionY,{0,0,0})
			Agent.removeAgent(ID)
		elseif timeIsUp == true then
			--say("time is up")
			if baseX == nil and baseY == nil then
				say("i dont have a base :(")
				if scanForBase == true then
					base = Torus.squareSpiralTorusScanColor(P,{0,0,255}, G)
					scanForBase = false
					energy = energy - P
					if base ~= nil then
						--say("found a base!!")
						baseX = base[1]["posX"]
						baseY = base[1]["posY"]
					end
				else
					if Torus.reachedDestination(gotoX, gotoY) == true then
						gotoX = Stat.randomInteger(0, ENV_HEIGHT)
						gotoY = Stat.randomInteger(0, ENV_WIDTH)
						scanForBase = true
					else
						Moving = true
						Torus.move(gotoX, gotoY, G, color)
						energy = energy - Q
					end
				end
			elseif Torus.reachedDestination(baseX, baseY) == false then
				--say("moving towards base")
				Moving = true
				Torus.move(baseX, baseY, G, color)
				energy = energy - Q 
			else
				Collision.updatePosition(-1,-1)
				Map.modifyColor(DestinationX,DestinationY,{0,0,0})
				Agent.removeAgent(ID) -- remove to make space for others
			end
		elseif baseX == nil and baseY == nil then
			if M == 0 then
				if scanForBase == true then
					base = Torus.squareSpiralTorusScanColor(P,{0,0,255}, G)
					scanForBase = false
					energy = energy - P
					if base ~= nil then
						say("found a base!!")
						baseX = base[1]["posX"]
						baseY = base[1]["posY"]
					end
				else
					if Torus.reachedDestination(gotoX, gotoY) == true then
						gotoX = Stat.randomInteger(0, ENV_HEIGHT)
						gotoY = Stat.randomInteger(0, ENV_WIDTH)
						scanForBase = true
					else
						Moving = true
						Torus.move(gotoX, gotoY, G, color)
						energy = energy - Q
					end
				end
			else
				say("nothing more for me to do..")
				-- can't do more, camp at base
			end
		elseif Torus.distance(PositionX, PositionY, baseX, baseY, ENV_WIDTH, ENV_HEIGHT) < 2 and energy ~= FULL_ENERGY then -- if base and not full energy
			--say("T: at base")
			energy = FULL_ENERGY
			if unloadingOreSend == false and oreStored ~= 0 then --If in base to charge, unload ores if carrying any
				Event.emit{sourceX = PostionX, sourceY = PositionY, sourceID = ID, speed=1000000, description="unloadingOre", table={ores=oreStored}}
				-- In base no need to retract energy
				unloadingOreSend = true
				--say("TRANSPORTER: sending unloadingOre request for " .. oreStored .. "ores" )
			end
		elseif energy < LOW_ENERGY then -- If low energy return to base
			--say("T: low energy")
			Moving = true
			Torus.move(baseX, baseY, G, color)
			energy = energy - Q 
		elseif oreStored == W then -- If capacity reached, unload to base
			--say("T: full capacity" )
			Moving = true
			Torus.move(baseX, baseY, G, color)
			energy = energy - Q

		elseif oreLocated == true then 
			--say("T: oreLocated")
			if Torus.distance(PositionX,PositionY,memory:peek()[1], memory:peek()[2], ENV_WIDTH,ENV_HEIGHT) < 2 then
				oreLocated = false
				Event.emit{sourceX = PostionX, sourceY = PositionY, speed=1000000, description="oreDepleted", table={oreX = memory:peek()[1], oreY = memory:peek()[2]}}
				memory:pop() --Remove ore from memory
				energy = energy - 1
				oreStored = oreStored + 1
			else
				Moving = true
				Torus.move(memory:peek()[1], memory:peek()[2], G, color)
				energy = energy - Q
			end
		else -- random Movement
			--say("T: random movement") 
			if Torus.reachedDestination(gotoX, gotoY) == true then
				gotoX = Stat.randomInteger(0, ENV_HEIGHT)
				gotoY = Stat.randomInteger(0, ENV_WIDTH)
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
