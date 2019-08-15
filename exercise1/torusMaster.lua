Agent = require "ranalib_agent"
Shared = require "ranalib_shared"
Stat = require "ranalib_statistic"
Map = require "ranalib_map"
function initializeAgent()

	PositionY = Stat.randomInteger(0,ENV_HEIGHT*2)
	PositionX = Stat.randomInteger(0,ENV_WIDTH*2)

	MAX_PREDATOR = 2
	MAX_PREY = 20
	SPEED_PREDATOR =2
	SPEED_PREY = 1
	STARTING_FOOD = 20
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

	
end
