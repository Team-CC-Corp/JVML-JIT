import cc.terminal.MonitorTerminal;
import cc.terminal.TerminalOutputStream;
import cc.terminal.Color;
import cc.terminal.Window;
import cc.peripheral.PeripheralNotFoundException;
import java.io.PrintStream;
import java.io.IOException;

public class PeripheralTest {
	public static void main(String[] args) throws PeripheralNotFoundException, IOException {
		MonitorTerminal mon = new MonitorTerminal("left");
		mon.setCursor(0, 0);
		mon.setBackgroundColor(Color.BLACK);
		mon.clear();

		Window win = new Window(mon, 2, 2, 5, 3, Color.ORANGE, Color.YELLOW, true);

		TerminalOutputStream termOut = new TerminalOutputStream(win);
		PrintStream monitorPrinter = new PrintStream(termOut, true);

		win.setCursor(0,0);
		termOut.setBackgroundColor(Color.YELLOW);

		termOut.setTextColor(Color.RED);
		monitorPrinter.print("R");
		termOut.setTextColor(Color.GREEN);
		monitorPrinter.print("G");
		termOut.setTextColor(Color.BLUE);
		monitorPrinter.print("B");
	}
}