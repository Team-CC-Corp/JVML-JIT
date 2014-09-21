package cc.peripheral;

public class PeripheralNotFoundException extends Exception {
	public PeripheralNotFoundException(String id, String expectedType) {
		super("Peripheral ID not found: " + id + (expectedType == null ? "" : "\nExpected type: " + expectedType));
	}

	public PeripheralNotFoundException(String id) {
		this(id, null);
	}
}