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

	PositionY = Stat.randomInteger(0,ENV_HEIGHT*2)
	PositionX = Stat.randomInteger(0,ENV_WIDTH*2)

	MAX_PREDATOR = 1
	MAX_PREY = 10
	SPEED_PREDATOR = 1	--This controls how many steps the predator should skip.
	SPEED_PREY = 5		--This controls how many steps the prey should skip, the lager value the slower agent
	STARTING_FOOD = 40
	MAX_FOOD = 100

	Shared.storeNumber(0, MAX_PREDATOR, true)
	Shared.storeNumber(1, MAX_PREY, true)
	Shared.storeNumber(2, SPEED_PREDATOR, true)
	Shared.storeNumber(3, SPEED_PREY, true)
	Shared.storeNumber(4, MAX_FOOD, true)

	Agent.changeColor{b=255}
	for i=0, (MAX_PREDATOR - 1) do
		Agent.addAgent("torusPredator.lua")
	end
	
	for i=0, (MAX_PREY - 1) do
		Agent.addAgent("torusPrey.lua")
	end

	for i=0, (STARTING_FOOD - 1) do
		Agent.addAgent("food.lua")
	end

	Agent.removeAgent(ID)
end
