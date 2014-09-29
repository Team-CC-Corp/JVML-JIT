package cc.terminal;

import cc.peripheral.PeripheralNotFoundException;
import cc.peripheral.Peripheral;

public class MonitorTerminal extends Peripheral implements Terminal {
	public MonitorTerminal(String id) throws PeripheralNotFoundException {
		super(id);
		if (!getType().equals("monitor")) {
			throw new PeripheralNotFoundException(id, "monitor");
		}
	}
	

	@Override
	public void write(char c) {
		write(new String(new char[] {c}));
	}

	@Override
	public void write(char[] c) {
		write(new String(c));
	}

	@Override
	public void write(String text) {
		call("write", text);
	}
	
	public void clear() {
		int x = getCursorX();
		int y = getCursorX();

		for (int i = 0; i < height(); ++i) {
			setCursor(x, i);
			clearLine();
		}

		setCursor(x, y);
	}

	@Override
	public void clearLine() {
		call("clearLine");
	}

	@Override
	public int getCursorX() {
		return (Integer)call("getCursorPos")[0];
	}

	@Override
	public int getCursorY() {
		return (Integer)call("getCursorPos")[1];
	}

	@Override
	public void setCursor(int x, int y) {
		call("setCursorPos", x, y);
	}

	@Override
	public boolean isColor() {
		return (Boolean)call("isColor")[0];
	}

	@Override
	public int width() {
		return (Integer)call("getSize")[0];
	}

	@Override
	public int height() {
		return (Integer)call("getSize")[1];
	}

	@Override
	public void scroll(int n) {
		call("scroll", n);
	}

	@Override
	public void setTextColor(Color c) {
		call("setTextColor", c.intValue);
	}

	@Override
	public void setBackgroundColor(Color c) {
		call("setBackgroundColor", c.intValue);
	}
	
	public void setColor(Color textColor, Color backgroundColor) {
		setTextColor(textColor);
		setBackgroundColor(backgroundColor);
	}

	public int nextLine() {
		return nextLine(getCursorX());
	}

	public int nextLine(int x) {
		if (getCursorY() == height() - 1) {
			scroll(1);
			setCursor(x, getCursorY());
		} else {
			setCursor(x, getCursorY() + 1);
		}
		return getCursorY();
	}
}