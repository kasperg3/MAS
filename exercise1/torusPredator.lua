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


function randomWithStep(first, last, stepSize)
    local maxSteps = math.floor((last-first)/stepSize)
    return first + stepSize * Stat.randomInteger(0, maxSteps)
end


function compareTables(table1, table2)
	if #table1 == #table2 then
		for i=1, #table1 do
			if table1[i] ~= table2[i] then
				return false
			end
		end
		return true
	else
		return false
	end
end

function squareSpiralTorusScanColor(dimension, color)
	local x = 0
	local y = 0
	local dx = 0
	local dy = -1
	local collisionTable = {}
	local checkColor = {}
	
	
	-- Spiral check starting from the Agent position and spiraling out
	for i=1, (dimension+1)*(dimension+1) do
		local checkX = PositionX + x
		local checkY = PositionY + y
		
		-- Check through walls
		if checkX >= G then checkX = checkX - G end
		if checkX < 0 then checkX = checkX + G end
		if checkY >= G then checkY = checkY - G end
		if checkY < 0 then checkY = checkY + G end
		
		
		-- Check if position is the given color 
		checkColor = Map.checkColor(checkX,checkY)
		if compareTables(checkColor,color) then
			table.insert(collisionTable, {posX=checkX, posY=checkY})
		end
		
		-- Caluculating next position
		if x == y or (x < 0 and x == -y) or (x > 0 and x == 1-y) then
			local temp = dx
			dx = -dy
			dy = temp
		end
		
		-- Next position
		x = x+dx
		y = y+dy
	end
	
	-- Returns
	if #collisionTable > 0 then
		return collisionTable
	else
		return nil
	end
end

 



function moveTorus(x,y)

	local destX = x
	local destY = y
	local directionX = destX-PositionX
	local directionY = destY-PositionY
	

	Map.modifyColor(DestinationX,DestinationY,{0,0,0})

	-- Changing direction to go through the edge of the map if path is shorter
	if math.abs(directionX) > G/2 	then directionX = -directionX end
	if math.abs(directionY) > G/2 	then directionY = -directionY end
	
	-- Determining destination point
	if	directionX > 0 then destX = PositionX+1
	elseif	directionX < 0 then destX = PositionX-1
	else	destX = PositionX	end
	
	if	directionY > 0 then destY = PositionY+1
	elseif	directionY < 0 then destY = PositionY-1
	else	destY = PositionY	end
	
	-- Determining destination point if direction is through the edge of the map
	if destX < 0 then 
		destX = G-1
	elseif destX >= G then
		destX = 0
	end
	
	if destY < 0 then
		destY = G-1
	elseif destY >= G then
		destY = 0
	end
	
	-- If no other agent is at the destination or the destination is the base
	if (not Collision.checkCollision(destX,destY)) or (destX == basePosX and destY == basePosY)  then
		-- Moving the Agent	
		Collision.updatePosition(destX,destY) 
	-- If there is a collision
	else
		-- If destination is on the same y
		if destX ~= PositionX and destY == PositionY then
			-- Change y with either -1 or 1
			local randStep = randomWithStep(-1,1,2)
			destY = PositionY+randStep

			-- If still collision
			if Collision.checkCollision(destX,destY) then
				-- Change y with the opposite as before
				destY = PositionY-randStep
			end
			
			-- If still collision
			if Collision.checkCollision(destX,destY) then
				-- Stay
				destX = PositionX
				destY = PositionY
			end
		
		-- If destination is on the same x
		elseif destY ~= PositionY and destX == PositionX then
			-- Change x with either -1 or 1
			local randStep = randomWithStep(-1,1,2)
			destX = PositionX+randStep
			
			-- If still collision
			if Collision.checkCollision(destX,destY) then
				-- Change x with the opposite as before
				destX = PositionX-randStep
			end
			
			-- If still collision
			if Collision.checkCollision(destX,destY) then
				-- Stay
				destX = PositionX
				destY = PositionY
			end
			
		-- If destination is diagonal
		elseif destY ~= PositionY and destX ~= PositionX then
			local tempDestX = destX
			local tempDestY = destY
			-- Change either y or x destination to position
			local randNum = Stat.randomInteger(0,1)
			if randNum == 0 then
				destY = PositionY
			else
				destX = PositionX
			end
			
			-- If still collision
			if Collision.checkCollision(destX,destY) then
				-- Change the opposite as before
				if randNum == 1 then
					destY = PositionY
					destX = tempDestX
				else
					destY = tempDestY
					destX = PositionX
				end
			end
			
			-- If still collision
			if Collision.checkCollision(destX,destY) then
				-- Stay
				destX = PositionX
				destY = PositionY
			end
		end
		
		-- Update position
		Collision.updatePosition(destX,destY) 

	end

	DestinationX = destX
	DestinationY = destY
	
	Map.modifyColor(PositionX,PositionY,{255,0,0})
end



function handleEvent(sourceX, sourceY, sourceID, eventDescription, eventTable)

	
end

function tprint (t, s)
    for k, v in pairs(t) do
        local kfmt = '["' .. tostring(k) ..'"]'
        if type(k) ~= 'string' then
            kfmt = '[' .. k .. ']'
        end
        local vfmt = '"'.. tostring(v) ..'"'
        if type(v) == 'table' then
            tprint(v, (s or '')..kfmt)
        else
            if type(v) ~= 'string' then
                vfmt = tostring(v)
            end
            print(type(t)..(s or '')..kfmt..' = '..vfmt)
        end
    end
end


function takeStep()
	
	--say("gotoX: "..gotoX.." PositionX: "..PositionX.."gotoY: "..gotoY.." PositionY: "..PositionY)
	dim = 100
	res = squareSpiralTorusScanColor(dim,{255,255,255})
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
			moveTorus(gotoX, gotoY)
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
		moveTorus(res[1]["posX"],res[1]["posY"])
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
