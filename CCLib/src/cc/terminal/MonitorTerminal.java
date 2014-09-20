package cc.terminal;

import cc.peripheral.PeripheralNotFoundException;
import cc.peripheral.Peripheral;

public class MonitorTerminal extends Terminal {
	private final Peripheral monitor;

	public MonitorTerminal(String side) throws PeripheralNotFoundException {
		monitor = new Peripheral(side);
		if (!monitor.isPresent() || !monitor.getType().equals("monitor")) {
			throw new PeripheralNotFoundException(side, "monitor");
		}
	}

	public void write(String text) {
		monitor.call("write", text);
	}

	public void clearLine() {
		monitor.call("clearLine");
	}

	public int getCursorX() {
		return (Integer)monitor.call("getCursorPos")[0];
	}

	public int getCursorY() {
		return (Integer)monitor.call("getCursorPos")[1];
	}

	public void setCursor(int x, int y) {
		monitor.call("setCursorPos", x, y);
	}

	public boolean isColor() {
		return (Boolean)monitor.call("isColor")[0];
	}

	public int width() {
		return (Integer)monitor.call("getSize")[0];
	}

	public int height() {
		return (Integer)monitor.call("getSize")[1];
	}

	public void scroll(int n) {
		monitor.call("scroll", n);
	}

	public void setTextColor(Color c) {
		monitor.call("setTextColor", c.intValue);
	}

	public void setBackgroundColor(Color c) {
		monitor.call("setBackgroundColor", c.intValue);
	}
}