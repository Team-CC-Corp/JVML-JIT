import cc.terminal.MonitorTerminal;
import cc.terminal.TerminalOutputStream;
import cc.terminal.Color;
import cc.peripheral.PeripheralNotFoundException;
import java.io.PrintStream;
import java.io.IOException;

public class PeripheralTest {
	public static void main(String[] args) throws PeripheralNotFoundException {
		TerminalOutputStream termOut = new TerminalOutputStream(new MonitorTerminal("left"));
		PrintStream monitorPrinter = new PrintStream(termOut, true);

		termOut.setTextColor(Color.RED);
		monitorPrinter.print("R");
		termOut.setTextColor(Color.GREEN);
		monitorPrinter.print("G");
		termOut.setTextColor(Color.BLUE);
		monitorPrinter.print("B");
	}
}