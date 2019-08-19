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

	Agent.changeColor{b=255}
	
	-- PARAMETERS from exercise	
	O = 1 -- ores
	X = 5 -- explorer
	Y = 0 -- transporters
	G = 200 -- grid
	N = 2 -- bases
	M = false -- cooperative mode
	D = 0 -- density
	I = 0 -- communication scope
	P = 5 -- perception scope
	W = 0 -- limited capacity of robots
	C = 0 -- capacity of base
	E = 100 -- energy
	Q = 0 -- cost of sending message
	T = 0 -- time t to return to the base
	S = 0 -- memory of robots/bases

	-- Own PARAMETERS
	LOW_ENERGY = 0

	-- Shared values
	Shared.storeNumber(0, C, true)
	Shared.storeNumber(1, E, true)
	Shared.storeNumber(2, LOW_ENERGY, true)
	Shared.storeNumber(3, G, true)
	Shared.storeNumber(4, P, true)

	-- initializAgents
	for i=0, (O - 1) do
		Agent.addAgent("ore.lua")
	end
	
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



	-- Remove master agent from the map
	Agent.removeAgent(ID)
end
