--
--
-- Torus implementation by Rikke Tranborg and Maria Dam 
--
--

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
local G = 200
local doScan = true
Speed = Shared.getNumber(2)

function initializeAgent()
	-- Visible is the collision grid

	GridMovement = true	-- Visible is the collision grid
	say("Agent #: " .. ID .. " has been initialized")

	--Map.modifyColor(10,10,{255,255,255})
	Agent.changeColor{r=255, g=0, b=0}

	gotoX = Stat.randomInteger(0, ENV_HEIGHT)
	gotoY = Stat.randomInteger(0, ENV_WIDTH)
	sleepCounter = 0

end

function handleEvent(sourceX, sourceY, sourceID, eventDescription, eventTable)

	
end

function takeStep()
	
	--say("gotoX: "..gotoX.." PositionX: "..PositionX.."gotoY: "..gotoY.." PositionY: "..PositionY)
	dim = 100
	local color = {255,0,0}
	res = Torus.squareSpiralTorusScanColor(dim,{255,255,255}, G)
	if res then
			withinRangeOfPrey = true
	end
	if withinRangeOfPrey == false then
		if reachedDestination(gotoX, gotoY) == true then
			gotoX = Stat.randomInteger(0, ENV_HEIGHT)
			gotoY = Stat.randomInteger(0, ENV_WIDTH)
		end
		if Moving == false then
			Moving = true
			Torus.move(gotoX, gotoY, G, color)
		end
	elseif withinRangeOfPrey == true then
		if math.abs(PositionX - res[1]["posX"]) < 2 and math.abs(PositionY - res[1]["posY"]) < 2 then
			Event.emit{sourceX = res[1]["posX"], sourceY = res[1]["posY"], speed=1000, description="Eaten"}
		else
			--distance(res[1]["posX"], res[1]["posY"])
			--Event.emit{table=dist, speed = 1000, description="Hunting"}
		end
	end
	-- move towards prey
	if res then
		Moving = true
		Torus.move(res[1]["posX"],res[1]["posY"], G, color)
	end			
	withinRangeOfPrey = false
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

function distance(gotoX, gotoY)

	local distanceX = math.abs(gotoX-PositionX)
	local distanceY = math.abs(gotoY-PositionY)

	if math.abs(distanceX) > ENV_WIDTH/2 	then --if go through wall X direction
		distanceX = math.abs(distanceX - ENV_WIDTH)
	end
	if math.abs(distanceY) > ENV_HEIGHT/2 	then --if go through wall Y direction
		distanceY = math.abs(distanceY - ENV_HEIGHT)
	end
	--dist = (PositionX - gotoY)*(PositionX - gotoY)+(PositionY - gotoX)*(PositionY - gotoX)
	dist = distanceX * distanceX + distanceY * distanceY
	
	say("distX: "..distanceX.." distY: "..distanceY)
	say("currX: "..PositionX.." currY: "..PositionY)
	say("gotoX: "..gotoX.." gotoY: "..gotoY)
	
	dist = math.sqrt(dist)
	say("total dist: "..dist)
	say("")
	return dist
end

function cleanUp()
	say("Agent #: " .. ID .. " is done\n")
	Map.modifyColor(PositionX,PositionY,{0,0,0})	

end
