Agent = require "ranalib_agent"
Shared = require "ranalib_shared"
Stat = require "ranalib_statistic"

function initializeAgent()

	PositionY = Stat.randomInteger(0,ENV_HEIGHT*2)
	PositionX = Stat.randomInteger(0,ENV_WIDTH*2)

	MAX_PREDATOR = 1
	MAX_PREY = 5
	Agent.changeColor{b=255}
	for i=0, (MAX_PREDATOR - 1) do
		Agent.addAgent("predator.lua")
	end
	
	for i=0, (MAX_PREY - 1) do
		Agent.addAgent("prey.lua")
	end

	
end
