natives["cc.turtle.Turtle"] = natives["cc.turtle.Turtle"] or {}

natives["cc.turtle.Turtle"]["forward()Z"] = function()
	local success = turtle.forward()
	return success;
end

natives["cc.turtle.Turtle"]["back()Z"] = function()
	local success = turtle.back()
	return success;
end

natives["cc.turtle.Turtle"]["up()Z"] = function()
	local success = turtle.up()
	return success;
end

natives["cc.turtle.Turtle"]["down()Z"] = function()
	local success = turtle.down()
	return success;
end

natives["cc.turtle.Turtle"]["turnLeft()Z"] = function()
	local success = turtle.turnLeft()
	return success;
end

natives["cc.turtle.Turtle"]["turnRight()Z"] = function()
	local success = turtle.turnRight()
	return success;
end

natives["cc.turtle.Turtle"]["select(I)Z"] = function(slot)
	local success = turtle.select(slot)
	return success;
end

natives["cc.turtle.Turtle"]["getSelectedSlot()I"] = function()
	local slot = turtle.getSelectedSlot()
	return slot;
end

natives["cc.turtle.Turtle"]["getItemCount(I)I"] = function(slot)
	local count = turtle.getItemCount(slot);
	return count;
end

natives["cc.turtle.Turtle"]["getItemSpace(I)I"] = function(slot)
	local space = turtle.getItemSpace(slot);
	return space;
end

natives["cc.turtle.Turtle"]["getItemDetail(I)Lcc/turtle/ItemStack;"] = function(slot)
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

natives["cc.turtle.Turtle"]["equipLeft()Z"] = function()
	local success = turtle.equipLeft()
	return success
end

natives["cc.turtle.Turtle"]["equipRight()Z"] = function()
	local success = turtle.equipRight()
	return success
end

natives["cc.turtle.Turtle"]["place(Ljava/lang/String;)Z"] = function(text)
	local success = turtle.place(toLString(text))
	return success
end

natives["cc.turtle.Turtle"]["placeUp()Z"] = function()
	local success = turtle.placeUp()
	return success
end

natives["cc.turtle.Turtle"]["placeDown()Z"] = function()
	local success = turtle.placeDown()
	return success
end

natives["cc.turtle.Turtle"]["detect()Z"] = function()
	local success = turtle.detect()
	return success
end

natives["cc.turtle.Turtle"]["detectUp()Z"] = function()
	local success = turtle.detect()
	return success
end

natives["cc.turtle.Turtle"]["detectDown()Z"] = function()
	local success = turtle.detect()
	return success
end

natives["cc.turtle.Turtle"]["inspect()Lcc/turtle/InspectionReport;"] = function()
	local success, data = turtle.inspect()
	return createInspectionReport(success, data)
end

natives["cc.turtle.Turtle"]["inspectUp()Lcc/turtle/InspectionReport;"] = function()
	local success, data = turtle.inspectUp()
	return createInspectionReport(success, data)
end

natives["cc.turtle.Turtle"]["inspectDown()Lcc/turtle/InspectionReport;"] = function()
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