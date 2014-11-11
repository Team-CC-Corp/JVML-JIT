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