--[[
#-----------------------------------------------------------------------------#
----*					MTA DayZ: consume_player.lua					*----
----* Original Author: Marwin W., Germany, Lower Saxony, Otterndorf		*----

----* This gamemode is being developed by L, CiBeR96, 1B0Y				*----
----* Type: SERVER														*----
#-----------------------------------------------------------------------------#
]]

function addPlayerStats (player,data,value)
	-- Fix for nil values on value,data,player variables
	if not value or not player or not data then 
		outputDebugString("[DayZ] ERROR: Nil values in addPlayerStats@consume_player.lua [SERVER]")
	return end
	--
	if data == "food" then
		local current = playerStatusTable[player]["food"]
		if current + value > 100 then
			playerStatusTable[player]["food"] = 100
		elseif current + value < 1 then
			playerStatusTable[player]["food"] = 0
		else
			playerStatusTable[player]["food"] = current+value
		end
	elseif data == "thirst" then
		local current = playerStatusTable[player]["thirst"]
		if current + value > 100 then
			playerStatusTable[player]["thirst"] = 100
		elseif 	current + value < 1 then
			playerStatusTable[player]["thirst"] = 0
		else
			playerStatusTable[player]["thirst"] = current+value
		end
	elseif data == "blood" then
		local current = playerStatusTable[player]["blood"]
		if current + value > 12000 then
		playerStatusTable[player]["blood"] = 12000
		elseif 	current + value < 1 then
			playerStatusTable[player]["blood"] = 0
		else
			playerStatusTable[player]["blood"] = current+value
		end
	elseif data == "temperature" then
		local current = playerStatusTable[player]["temperature"]
		if current + value > 41 then
			playerStatusTable[player]["temperature"] = 41
		elseif 	current + value <= 31 then
			playerStatusTable[player]["temperature"] = 31
		else
			playerStatusTable[player]["temperature"] = current+value
		end
	elseif data == "humanity" then
		local current = playerStatusTable[player]["humanity"]
		if current + value > 5000 then
			playerStatusTable[player]["temperature"] = 5000
		else
			playerStatusTable[player]["temperature"] = current+value
		end
	--[[
	elseif data == "calories" then
		local current = getElementData(player,data)
		if current + value > 3610 then
			setElementData(player,data,3610)
		else
			setElementData(player,data,current+value)
		end
	]]
	end
end

function onPlayerRequestChangingStats(itemName,itemInfo,data)
	for i, value in ipairs(gameplayVariables["nutritions"]) do
		if itemName == value[1] then
			bloodRegen = value[2]
			calorieGain = value[3]/10
			foodGain = value[4]/10
			waterGain = value[5]/10
			temperatureGain = value[6]
		end
	end
	if data == "food" then
		setPedAnimation (source,"FOOD","EAT_Burger",6000,false,false,nil,false)
	elseif data == "thirst" then
		setPedAnimation (source,"VENDING","VEND_Drink2_P",6000,false,false,nil,false)
		if itemName == "Water Bottle" then
			setElementData(source,"Empty Water Bottle",(getElementData(source,"Empty Water Bottle") or 0)+1)
		end
	end
	setElementData(source,itemName,getElementData(source,itemName)-1)
	addPlayerStats (source,"blood",bloodRegen)
	--addPlayerStats (source,"calories",calorieGain)
	addPlayerStats (source,"food",foodGain)
	addPlayerStats (source,"thirst",waterGain)
	if playerStatusTable[source]["temperature"] <= 35 then
		addPlayerStats(source,"temperature",temperatureGain)
	end
	triggerClientEvent (source, "displayClientInfo", source,"Food",shownInfos["youconsumed"].." "..itemName,22,255,0)
	triggerClientEvent(source,"refreshInventoryManual",source)
end
addEvent("onPlayerRequestChangingStats",true)
addEventHandler("onPlayerRequestChangingStats",getRootElement(),onPlayerRequestChangingStats)

function onPlayerCreateDIYBandage(itemName, itemInfo)
	local playersource = source
	setPedAnimation (playersource,"BOMBER","BOM_Plant",3000,false,false,nil,false)
	if itemInfo == "Tear cloth up" then
		setElementData(playersource,itemName,getElementData(playersource,itemName)-1)
		setElementData(playersource,"Bandage",getElementData(playersource,"Bandage")+1)
	end
	triggerClientEvent(playersource,"refreshInventoryManual",playersource)
end
addEvent("onPlayerCreateDIYBandage",true)
addEventHandler("onPlayerCreateDIYBandage",getRootElement(),onPlayerCreateDIYBandage)

function onPlayerUseMedicObject(itemName)
	local playersource = source
	setPedAnimation (playersource,"BOMBER","BOM_Plant",5000,false,false,nil,false)
	setTimer( function ()
		if itemName == "Bandage" then
			playerStatusTable[playersource]["bleeding"] = 0
			setElementData(playersource,itemName,getElementData(playersource,itemName)-1)
		elseif itemName == "Medic Kit" then
			addPlayerStats (playersource,"blood",7000)
			playerStatusTable[playersource]["bleeding"] = 0
			setElementData(playersource,itemName,getElementData(playersource,itemName)-1)
		elseif itemName == "Heat Pack" then
			playerStatusTable[playersource]["cold"] = false
			playerStatusTable[playersource]["temperature"] = 37
			setElementData(playersource,itemName,getElementData(playersource,itemName)-1)
		elseif itemName == "Painkiller" then
			playerStatusTable[playersource]["pain"] = false
			setElementData(playersource,itemName,getElementData(playersource,itemName)-1)
		elseif itemName == "Antibiotics" then
			playerStatusTable[playersource]["sepsis"] = false
			playerStatusTable[playersource]["infection"] = false
			setElementData(playersource,itemName,getElementData(playersource,itemName)-1)
		elseif itemName == "Morphine" then
			playerStatusTable[playersource]["brokenbone"] = false
			playerStatusTable[playersource]["fracturedArms"] = false
			playerStatusTable[playersource]["fracturedLegs"] = false
			setElementData(playersource,itemName,getElementData(playersource,itemName)-1)
			setPlayerFracturedBones(playersource,false)
		elseif itemName == "Blood Bag" then
			addPlayerStats (playersource,"blood",4000)
			setElementData(playersource,itemName,getElementData(playersource,itemName)-1)
			setElementData(playersource,"Blood Bag (Empty)",getElementData(playersource,"Blood Bag (Empty)")+1)
		end
	end,1500,1)	
	triggerClientEvent(playersource,"refreshInventoryManual",playersource)
end
addEvent("onPlayerUseMedicObject",true)
addEventHandler("onPlayerUseMedicObject",getRootElement(),onPlayerUseMedicObject)

function onPlayerGiveMedicObject(itemName,player)
	local playersource = source
	setPedAnimation (playersource,"BOMBER","BOM_Plant",5000,false,false,nil,false)
	setTimer( function (player,playersource,itemName)
		if itemName == "bandage" then
			playerStatusTable[player]["bleeding"] = 0
			setElementData(playersource,"Bandage",getElementData(playersource,"Bandage")-1)
			addPlayerStats (playersource,"humanity",40)
		elseif itemName == "giveblood" then
			if playerStatusTable[player]["bloodtype"] == playerStatusTable[playersource]["bloodtype"] or playerStatusTable[player]["bloodtype"] == "AB" then
				addPlayerStats (player,"blood",12000)
				setElementData(playersource,"Blood Bag",getElementData(playersource,"Blood Bag")-1)
				setElementData(playersource,"Blood Bag (Empty)",getElementData(playersource,"Blood Bag (Empty)")+1)
				addPlayerStats (playersource,"humanity",250)
			else
				playerStatusTable[player]["blood"] = playerStatusTable[player]["blood"]-2000
				setElementData(playersource,"Blood Bag",getElementData(playersource,"Blood Bag")-1)
				setElementData(playersource,"Blood Bag (Empty)",getElementData(playersource,"Blood Bag (Empty)")+1)
				triggerClientEvent(playersource,"displayClientInfo",playersource,"BloodType","Your blood type is incompatible with "..getPlayerName(player).."!",255,0,0)
				triggerClientEvent(player,"displayClientInfo",player,"BloodType","Your blood type is incompatible with "..getPlayerName(playersource).."!",255,0,0)
			end
		elseif itemName == "morphine" then
			playerStatusTable[player]["brokenbone"] = false
			playerStatusTable[player]["fracturedArms"] = false
			playerStatusTable[player]["fracturedLegs"] = false
			setElementData(playersource,"Morphine",getElementData(playersource,"Morphine")-1)
			addPlayerStats (playersource,"humanity",50)
			setPlayerFracturedBones(player,false)
		elseif itemName == "antibiotics" then
			playerStatusTable[player]["sepsis"] = false
			playerStatusTable[player]["infection"] = false
			setElementData(playersource,itemName,getElementData(playersource,"Antibiotics")-1)
			addPlayerStats (playersource,"humanity",20)
		elseif itemName == "epipen" then
			playerStatusTable[player]["unconscious"] = false
			setElementData(playersource,itemName,getElementData(playersource,"Epi-Pen")-1)
			addPlayerStats (playersource,"humanity",25)
		end
	end,1500,1,player,playersource,itemName)	
end
addEvent("onPlayerGiveMedicObject",true)
addEventHandler("onPlayerGiveMedicObject",getRootElement(),onPlayerGiveMedicObject)

function onPlayerTransfuseBlood()
	if getElementData(source,"Transfusion Kit") > 0 then
		if getElementData(source,"Blood Bag (Empty)") > 0 then
			if playerStatusTable[source]["blood"] >= 4001 then
				setPedAnimation (source,"BOMBER","BOM_Plant",5000,false,false,nil,false)
				setElementData(source,"Blood Bag",getElementData(source,"Blood Bag")+1)
				setElementData(source,"Blood Bag (Empty)",getElementData(source,"Blood Bag (Empty)")-1)
				playerStatusTable[source]["blood"] = playerStatusTable[source]["blood"]-4000
				triggerClientEvent(source,"displayClientInfo",source,"BloodTransfusion","You transfused your blood into the blood bag.",0,255,0)
			else
				triggerClientEvent(source,"displayClientInfo",source,"BloodType","That action would kill you!",255,0,0)
				return
			end
		else
			triggerClientEvent(source,"displayClientInfo",source,"BloodType","You need Blood Bag (Empty) for that!",255,0,0)
			return
		end
	else
		triggerClientEvent(source,"displayClientInfo",source,"BloodType","You need a Transfusion Kit!",255,0,0)
		return
	end
end
addEvent("onPlayerTransfuseBlood",true)
addEventHandler("onPlayerTransfuseBlood",root,onPlayerTransfuseBlood)

function onPlayerRefillWaterBottle (itemName)
	if isElementInWater(source) then
		triggerClientEvent(source,"onPlayerActionPlaySound",source,"water")
		setElementData(source,"Water Bottle",getElementData(source,"Water Bottle")+1)
		setElementData(source,itemName,getElementData(source,itemName)-1)
		triggerClientEvent(source,"refreshInventoryManual",source)
		triggerClientEvent (source, "displayClientInfo", source,"Water Bottle",shownInfos["filledup"],22,255,0)
	else
		triggerClientEvent (source, "displayClientInfo", source,"Water Bottle",shownInfos["needwatersource"],255,22,0)
	end	
end
addEvent("onPlayerRefillWaterBottle",true)
addEventHandler("onPlayerRefillWaterBottle",getRootElement(),onPlayerRefillWaterBottle)

function addPlayerCookMeat ()
	local playersource = source
	setPedAnimation (playersource,"BOMBER","BOM_Plant",5000,false,false,nil,false)
	triggerClientEvent(source,"onPlayerActionPlaySound",playersource,"meat")
	local meat = getElementData(playersource,"Raw Meat")
	setTimer(function()
			setElementData(playersource,"Raw Meat",0)
			setElementData(playersource,"Cooked Meat",getElementData(playersource,"Cooked Meat")+meat)
			triggerClientEvent (playersource, "displayClientInfo", playersource,"Fireplace","You cooked "..meat.." Raw Meat.",22,255,0)
	end,5000,1)
end
addEvent("addPlayerCookMeat",true)
addEventHandler("addPlayerCookMeat",getRootElement(),addPlayerCookMeat)
