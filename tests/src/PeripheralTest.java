import cc.terminal.MonitorTerminal;
import cc.terminal.Color;
import cc.peripheral.PeripheralNotFoundException;

public class PeripheralTest {
	public static void main(String[] args) throws PeripheralNotFoundException {
		MonitorTerminal m = new MonitorTerminal("left");
		m.setTextColor(Color.GREEN);
		m.write("Green ");
		m.setTextColor(Color.BLUE);
		m.write("Blue ");
		m.setTextColor(Color.WHITE);
		m.write("White");
	}
}