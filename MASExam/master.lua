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

Agent = require "ranalib_agent"
Shared = require "ranalib_shared"
Stat = require "ranalib_statistic"
Map = require "ranalib_map"
Core = require "ranalib_core"
Event = require "ranalib_event"
function initializeAgent()

	Agent.changeColor{b=100, r=100, g=100}
	PositionX = ENV_WIDTH + 10
	PositionY = ENV_HEIGHT + 10
	callBackUnits = false
	printResults = false
	getOres = false
	
	-- PARAMETERS from exercise	
	D = 250-- ores
	X = 40 -- explorer
	Y = 10-- transporters
	G = ENV_WIDTH -- grid
	N = 1 -- bases
	M = 0 -- cooperative mode -- 0 = true, 1 = false 
	I = G/5-1 -- communication scope
	P = G/20-1 -- perception scope
	W = 5 -- limited capacity of robots
	C = 1000 -- capacity of base
	E = 1000 -- energy
	--Q = 0 -- cost of sending message
	T = 2 -- time t to return to the base [SEC]
	S = X + Y - 1 -- memory of robots/bases
	Q = 1 -- Cost of motion
	O = 2 -- OreTasks to send to the transporters

	-- Own PARAMETERS
	LOW_ENERGY = 50
	deadAgents = 0
	totalOres = 0

	-- Shared values
	Shared.storeNumber(0, C, true)
	Shared.storeNumber(1, E, true)
	Shared.storeNumber(2, LOW_ENERGY, true)
	Shared.storeNumber(3, G, true)
	Shared.storeNumber(4, P, true)
	Shared.storeNumber(5, Q, true)
	Shared.storeNumber(6, S, true)
	Shared.storeNumber(7, W, true)
	Shared.storeNumber(8, I,true)
	Shared.storeNumber(9, M, true)
	Shared.storeNumber(10, O, true)


	-- initializAgents
	for i=0, (D - 1) do
		Agent.addAgent("ore.lua")
	end

	spawnBase(X, Y, N)

	startTime = Core.time()
end

function spawnBase(exp, trans, base)
	for i=0, (base - 1) do -- For each base, initialize X + Y with certain x, y
		x = Stat.randomInteger(1, ENV_HEIGHT-1)
		y = Stat.randomInteger(1, ENV_WIDTH-1)

		Agent.addAgent("base.lua", x, y)
		for i=0, (exp - 1) do
			Agent.addAgent("explorer.lua", x, y)
		end
	
		for i=0, (trans - 1) do
			Agent.addAgent("transporter.lua", x, y)
		end
	end
end

function handleEvent(sourceX, sourceY, sourceID, eventDescription, eventTable)
	if eventDescription == "deadAgent" then
		deadAgents = deadAgents + 1
	end 
	if eventDescription == "oresCollected" then
		--say("adding ores.." .. eventTable["ores"])
		totalOres = totalOres + eventTable["ores"] 
	end
end

function takeStep()
	--say("current time: " .. Core.time() - startTime)
	if (Core.time() - startTime) > T and callBackUnits == false then
		say("timesUpThatsTheNameOfTheGame")
		Event.emit{speed=1000000, description="timesUp"}
		callBackUnits = true
	end

	-- When all robots home / after certain time t
	if (Core.time() - startTime) > T+1 and getOres == false then
		Event.emit{speed=1000000, description="getOres"}
		getOres = true
	end
	if (Core.time() - startTime) > T+1.2 and printResults == false then
		say("-- RESULTS --")
		say("Alive robots: " .. X+Y-deadAgents .. " out of " .. X+Y .. " | percentage: " .. ((X+Y-deadAgents)/(X+Y))*100)
		say("Ores collected: " ..  totalOres .. " out of " .. D .. " | percentage: " .. ((totalOres/D)*100))
		say("Time spent: " .. T)


		printResults = true
		l_stopSimulation()
	end
end

function cleanUp()
	--say("tring to write..")
	deadRobots = ((X+Y-deadAgents)/(X+Y))*100
	oresCollected = ((totalOres/D)*100)
	file = io.open("/home/walsted/workspace/RANA/MAS/MASExam/test.dat", "a")
	file:write(deadRobots .. "\n")
	file:write(oresCollected .. "\n")
	file:close()

	--file = io.open("/home/walsted/workspace/RANA/MAS/MASExam/test")
	--say(file:read())
	--say("Trying to read after write")

	



end


