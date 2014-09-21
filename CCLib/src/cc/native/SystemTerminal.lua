natives["cc.terminal.SystemTerminal"] = natives["cc.terminal.SystemTerminal"] or {}

natives["cc.terminal.SystemTerminal"]["write(C)V"] = function(this, c)
	term.write(string.char(c))
end

natives["cc.terminal.SystemTerminal"]["write(Ljava/lang/String;)V"] = function(this, text)
	term.write(toLString(text))
end

natives["cc.terminal.SystemTerminal"]["clearLine()V"] = function(this)
	term.clearLine()
end

natives["cc.terminal.SystemTerminal"]["clear()V"] = function(this)
	term.clear();
end

natives["cc.terminal.SystemTerminal"]["getCursorX()I"] = function(this)
	local x, y = term.getCursorPos()
	return x - 1
end

natives["cc.terminal.SystemTerminal"]["getCursorY()I"] = function(this)
	local x, y = term.getCursorPos()
	return y - 1
end

natives["cc.terminal.SystemTerminal"]["setCursor(II)V"] = function(this, x, y)
	term.setCursorPos(x + 1, y + 1)
end

natives["cc.terminal.SystemTerminal"]["isColor()Z"] = function(this)
	return term.isColor() and 1 or 0
end

natives["cc.terminal.SystemTerminal"]["width()I"] = function(this)
	local w, h = term.getSize()
	return w
end

natives["cc.terminal.SystemTerminal"]["height()I"] = function(this)
	local w, h = term.getSize()
	return h
end

natives["cc.terminal.SystemTerminal"]["scroll(I)V"] = function(this, n)
	term.scroll(n)
end

natives["cc.terminal.SystemTerminal"]["setTextColor(Lcc/terminal/Color;)V"] = function(this, c)
	term.setTextColor(getObjectField(c, "intValue"))
end

natives["cc.terminal.SystemTerminal"]["setBackgroundColor(Lcc/terminal/Color;)V"] = function(this, c)
	term.setBackgroundColor(getObjectField(c, "intValue"))
end