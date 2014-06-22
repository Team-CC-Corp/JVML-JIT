import cc.peripheral.Peripheral;

public class PeripheralTest {
	public static void main(String[] args) {
		Peripheral p = new Peripheral("left");
		if (p.isPresent() && p.getType().equals("monitor")) {
			p.call("write", "Hey");
			Object[] arr = p.call("getSize");
			System.out.println((Integer)arr[0] + (Integer)arr[1]);
		}
	}
}