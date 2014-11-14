natives["cc.turtle.Turtle"] = natives["cc.turtle.Turtle"] or {}

function booleanToInt(b)
	if b then
		return 1
	else
		return 0
	end
end

natives["cc.turtle.Turtle"]["forward()Z"] = function(this)
	local success = turtle.forward()
	return booleanToInt(success)
end

natives["cc.turtle.Turtle"]["back()Z"] = function(this)
	local success = turtle.back()
	return booleanToInt(success)
end

natives["cc.turtle.Turtle"]["up()Z"] = function(this)
	local success = turtle.up()
	return booleanToInt(success)
end

natives["cc.turtle.Turtle"]["down()Z"] = function(this)
	local success = turtle.down()
	return booleanToInt(success)
end

natives["cc.turtle.Turtle"]["turnLeft()Z"] = function(this)
	local success = turtle.turnLeft()
	return booleanToInt(success)
end

natives["cc.turtle.Turtle"]["turnRight()Z"] = function(this)
	local success = turtle.turnRight()
	return booleanToInt(success)
end

natives["cc.turtle.Turtle"]["select(I)Z"] = function(this, slot)
	local success = turtle.select(slot)
	return booleanToInt(success)
end

natives["cc.turtle.Turtle"]["getSelectedSlot()I"] = function(this)
	local slot = turtle.getSelectedSlot()
	return slot;
end

natives["cc.turtle.Turtle"]["getItemCount(I)I"] = function(this, slot)
	local count = turtle.getItemCount(slot);
	return count;
end

natives["cc.turtle.Turtle"]["getItemSpace(I)I"] = function(this, slot)
	local space = turtle.getItemSpace(slot);
	return space;
end

natives["cc.turtle.Turtle"]["getItemDetail(I)Lcc/turtle/ItemStack;"] = function(this, slot)
	local data = turtle.getItemDetail(slot);
	if data == nil then
		return null
	end
	local class = classByName("cc.turtle.ItemStack")
    local itemstack = newInstance(class)
    findMethod(class, "<init>()V")[1](itemstack)
	setObjectField(itemstack, "name", toJString(data.name))
	setObjectField(itemstack, "damage", data.damage)
	setObjectField(itemstack, "count", data.count)
	return itemstack;
end

natives["cc.turtle.Turtle"]["equipLeft()Z"] = function(this)
	local success = turtle.equipLeft()
	return success
end

natives["cc.turtle.Turtle"]["equipRight()Z"] = function(this)
	local success = turtle.equipRight()
	return success
end

natives["cc.turtle.Turtle"]["place(Ljava/lang/String;)Z"] = function(this, text)
	local success = turtle.place(toLString(text))
	return booleanToInt(success)
end

natives["cc.turtle.Turtle"]["placeUp()Z"] = function(this)
	local success = turtle.placeUp()
	return booleanToInt(success)
end

natives["cc.turtle.Turtle"]["placeDown()Z"] = function(this)
	local success = turtle.placeDown()
	return booleanToInt(success)
end

natives["cc.turtle.Turtle"]["detect()Z"] = function(this)
	local success = turtle.detect()
	return booleanToInt(success)
end

natives["cc.turtle.Turtle"]["detectUp()Z"] = function(this)
	local success = turtle.detect()
	return booleanToInt(success)
end

natives["cc.turtle.Turtle"]["detectDown()Z"] = function(this)
	local success = turtle.detect()
	return booleanToInt(success)
end

natives["cc.turtle.Turtle"]["inspect()Lcc/turtle/InspectionReport;"] = function(this)
	local success, data = turtle.inspect()
	return createInspectionReport(success, data)
end

natives["cc.turtle.Turtle"]["inspectUp()Lcc/turtle/InspectionReport;"] = function(this)
	local success, data = turtle.inspectUp()
	return createInspectionReport(success, data)
end

natives["cc.turtle.Turtle"]["inspectDown()Lcc/turtle/InspectionReport;"] = function(this)
	local success, data = turtle.inspectDown()
	return createInspectionReport(success, data)
end

function createInspectionReport(success, data)
	local class = classByName("cc.turtle.InspectionReport")
    local report = newInstance(class)
    findMethod(class, "<init>()V")[1](report)
    if success then
    	setObjectField(report, "success", 1)
    	setObjectField(report, "blockName", toJString(data.name))
    	setObjectField(report, "blockMetadata", data.metadata)
    else
    	setObjectField(report, "success", 0)
    	setObjectField(report, "errorMessage", toJString(data))
    end
    return report
end

natives["cc.turtle.Turtle"]["compare()Z"] = function(this)
	local success = turtle.compare()
	return booleanToInt(success)
end

natives["cc.turtle.Turtle"]["compareUp()Z"] = function(this)
	local success = turtle.compareUp()
	return booleanToInt(success)
end

natives["cc.turtle.Turtle"]["compareDown()Z"] = function(this)
	local success = turtle.compareDown()
	return booleanToInt(success)
end

natives["cc.turtle.Turtle"]["compareTo(I)Z"] = function(this, slot)
	local success = turtle.compareTo(slot)
	return booleanToInt(success)
end

natives["cc.turtle.Turtle"]["drop(I)Z"] = function(this, count)
	local success = turtle.drop(count)
	return booleanToInt(success)
end

natives["cc.turtle.Turtle"]["dropUp(I)Z"] = function(this, count)
	local success = turtle.dropUp(count)
	return booleanToInt(success)
end

natives["cc.turtle.Turtle"]["dropDown(I)Z"] = function(this, count)
	local success = turtle.dropDown(count)
	return booleanToInt(success)
end

natives["cc.turtle.Turtle"]["suck(I)Z"] = function(this, count)
	local success = turtle.suck(count)
	return booleanToInt(success)
end

natives["cc.turtle.Turtle"]["suckUp(I)Z"] = function(this, count)
	local success = turtle.suckUp(count)
	return booleanToInt(success)
end

natives["cc.turtle.Turtle"]["suckDown(I)Z"] = function(count)
	local success = turtle.suckDown(count)
	return booleanToInt(success)
end

natives["cc.turtle.Turtle"]["refuel(I)Z"] = function(quantity)
	local success = turtle.refuel(quantity)
	return booleanToInt(success)
end

natives["cc.turtle.Turtle"]["getFuelLevel()I"] = function()
	local level = turtle.getFuelLevel()
	return level
end

natives["cc.turtle.Turtle"]["getFuelLimit()I"] = function()
	local level = turtle.getFuelLimit()
	return level
end

natives["cc.turtle.Turtle"]["transferTo(II)Z"] = function(slot, quantity)
	local success = turtle.transferTo(slot, quantity)
	return booleanToInt(success)
end

-- crafty turtles only
natives["cc.turtle.Turtle"]["craft(I)Z"] = function(quantity)
	local success = turtle.craft(quantity)
	return booleanToInt(success)
end

-- digging, felling, mining, farming turtles
natives["cc.turtle.Turtle"]["dig()Z"] = function()
	local success = turtle.dig()
	return booleanToInt(success)
end

natives["cc.turtle.Turtle"]["digUp()Z"] = function()
	local success = turtle.digUp()
	return booleanToInt(success)
end

natives["cc.turtle.Turtle"]["digDown()Z"] = function()
	local success = turtle.digDown()
	return booleanToInt(success)
end

-- all tools only
natives["cc.turtle.Turtle"]["attack()Z"] = function()
	local success = turtle.attack()
	return booleanToInt(success)
end

natives["cc.turtle.Turtle"]["attackUp()Z"] = function()
	local success = turtle.attackUp()
	return booleanToInt(success)
end

natives["cc.turtle.Turtle"]["attackDown()Z"] = function()
	local success = turtle.attackDown()
	return booleanToInt(success)
end
