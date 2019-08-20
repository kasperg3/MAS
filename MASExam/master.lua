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
function initializeAgent()

	Agent.changeColor{b=100, r=100, g=100}
	PositionX = ENV_WIDTH + 10
	PositionY = ENV_HEIGHT + 10
	
	-- PARAMETERS from exercise	
	O = 3-- ores
	X = 5 -- explorer
	Y = 5-- transporters
	G = ENV_WIDTH -- grid
	N = 1 -- bases
	M = 0 -- cooperative mode -- 0 = true, 1 = false 
	D = 0 -- density
	I = G/5-1 -- communication scope
	P = 50 -- perception scope
	W = 1 -- limited capacity of robots
	C = 2 -- capacity of base
	E = 100000 -- energy
	Q = 0 -- cost of sending message
	T = 0 -- time t to return to the base
	S = X + Y - 1 -- memory of robots/bases
	Q = 1 -- Cost of motion

	-- Own PARAMETERS
	LOW_ENERGY = 50

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


	-- initializAgents
	for i=0, (O - 1) do
		Agent.addAgent("ore.lua")
	end

	Agent.addAgent("base.lua", x, y) -- empty base NO explorers or transporters -- used for test
	
	for i=0, (N - 1) do -- For each base, initialize X + Y with certain x, y
		x = Stat.randomInteger(0, ENV_HEIGHT)
		y = Stat.randomInteger(0, ENV_WIDTH)

		Agent.addAgent("base.lua", x, y)
		for i=0, (X - 1) do
			Agent.addAgent("explorer.lua", x, y)
		end
	
		for i=0, (Y - 1) do
			Agent.addAgent("transporter.lua", x, y)
		end
	end
	local x = os.clock()
    local s = 0
    for i=1,10000 do s = s + i end
    print(string.format("elapsed time: %.2f\n", os.clock() - x))
end
