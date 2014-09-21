package cc.peripheral;

public class Peripheral {
	public final String id;
	public Peripheral(String id) throws PeripheralNotFoundException {
		this.id = id;
		if (!isPresent()) {
			throw new PeripheralNotFoundException(id);
		}
	}

	native public Object[] call(String method, Object... arguments);
	native public boolean isPresent();
	native public String getType();

	static {
		System.load("cc/native/Peripheral.lua");
	}
}