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