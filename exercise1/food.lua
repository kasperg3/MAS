--
--
-- Torus implementation by Rikke Tranborg and Maria Dam 
--
--

-- Import Rana lua modules.
Stat = require "ranalib_statistic" 
Agent = require "ranalib_agent"
Shared = require "ranalib_shared"
Map = require "ranalib_map"

function initializeAgent()
	-- Visible is the collision grid
	say("Agent (food) #: " .. ID .. " has been initialized")
	Agent.changeColor{g=255}
	MAX_FOOD = Shared.getNumber(4)
	foodSource = Stat.randomInteger(0, MAX_FOOD)
	Map.modifyColor(PositionX,PositionY,{0,255,0})
end




function handleEvent(sourceX, sourceY, sourceID, eventDescription, eventTable)
	if eventDescription == "EatFood" then 
			foodSource = foodSource - 1
			if foodSource == 0 then
				Agent.removeAgent(ID)
			end
	end
end


function takeStep()

end


function cleanUp()
	say("Agent #: " .. ID .. " is done\n")	
end
