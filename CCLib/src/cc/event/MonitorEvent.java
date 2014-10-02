package cc.event;

import cc.terminal.MonitorTerminal;
import cc.peripheral.PeripheralNotFoundException;

public abstract class MonitorEvent {
	public final String side;

	public MonitorEvent(String side) {
		this.side = side;
	}

	public static class MonitorTouchEvent extends MonitorEvent {
		public final int x, y;

		public MonitorTouchEvent(String side, int x, int y) {
			super(side);
			this.x = x;
			this.y = y;
		}
	}

	public static class MonitorResizeEvent extends MonitorEvent {
		public final int newWidth, newHeight;

		public MonitorResizeEvent(String side) throws PeripheralNotFoundException {
			super(side);

			MonitorTerminal t = new MonitorTerminal(side);
			newWidth = t.width();
			newHeight = t.height();
		}
	}
}