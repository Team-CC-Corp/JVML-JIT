package java.lang;

public class Double extends Number {
    
    public static final double MAX_VALUE = 1.79769313486231570e+308;
    public static final double MIN_VALUE = 5e-324;
	public static final double NEGATIVE_INFINITY = -1.0 / 0.0;
	public static final double POSITIVE_INFINITY = 1.0 / 0.0;
	public static final double NaN = 0.0 / 0.0;
	public static final Class<Double> TYPE = (Class<Double>) Class.getPrimitiveClass("double");

	private final double value;

	public static Double valueOf(double value) {
		return new Double(value);
	}

	public Double(double value) {
		this.value = value;
	}

	public Double(String value) {
		this.value = parseDouble(value);
	}

	public String toString() {
		return toString(value);
	}

	public double doubleValue() {
		return value;
	}

	@Override
	public boolean equals(Object obj) {
		if (obj instanceof Double) {
			return value == ((Double) obj).doubleValue();
		}
		return false;
	}

	public static Double valueOf(String s) {
		return new Double(s);
	}

	public int hashCode() {
		long v = doubleToRawLongBits(value);
		return (int) ((v >> 32) ^ (v & 0xFF));
	}

	public static String toString(double v) {
		return Number.toString(v);
	}

	public byte byteValue() {
		return (byte) value;
	}

	public short shortValue() {
		return (short) value;
	}

	public int intValue() {
		return (int) value;
	}

	public long longValue() {
		return (long) value;
	}

	public float floatValue() {
		return (float) value;
	}

	public boolean isInfinite() {
		return isInfinite(value);
	}

	public boolean isNaN() {
		return isNaN(value);
	}

	public static double parseDouble(String s) {
		int[] numRead = new int[1];
		double d = doubleFromString(s, numRead);
		if (numRead[0] == 1) {
			return d;
		} else {
			throw new NumberFormatException(s);
		}
	}

	public static long doubleToLongBits(double value) {
		if (isNaN(value))
			return 0x7ff8000000000000L;
		return doubleToRawLongBits(value);
	}

	public static native long doubleToRawLongBits(double value);

	public static native double longBitsToDouble(long bits);

	public static native boolean isInfinite(double value);

	public static native boolean isNaN(double value);

	public static native double doubleFromString(String s, int[] numRead);
}