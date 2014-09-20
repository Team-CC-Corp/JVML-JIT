package cc.peripheral;

public class PeripheralNotFoundException extends Exception {
	public PeripheralNotFoundException(String side, String expectedType) {
		super("Peripheral of expected type '" + expectedType + "' not found on side '" + side + "'");
	}
}