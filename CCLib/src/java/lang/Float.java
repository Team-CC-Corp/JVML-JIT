package java.lang;

public class Float extends Number {

	private static final int EXP_BIT_MASK = 0x7F800000;
	private static final int SIGNIF_BIT_MASK = 0x007FFFFF;

	public static final float NEGATIVE_INFINITY = -1.0f / 0.0f;
	public static final float POSITIVE_INFINITY = 1.0f / 0.0f;
	public static final float NaN = 0.0f / 0.0f;

	private final float value;
	public static final Class<Float> TYPE = (Class<Float>) Class.getPrimitiveClass("float");

	public static Float valueOf(float value) {
		return new Float(value);
	}

	public Float(float value) {
		this.value = value;
	}

	public String toString() {
		return toString(value);
	}

	public float floatValue() {
		return value;
	}

	@Override
	public boolean equals(Object obj) {
		if (obj instanceof Float) {
			return value == ((Float) obj).floatValue();
		}
		return false;
	}

	public Float(String value) {
		this.value = parseFloat(value);
	}

	public static Float valueOf(String s) {
		return new Float(s);
	}

	public int hashCode() {
		return floatToRawIntBits(value);
	}

	public static String toString(float v) {
		return Double.toString(v);
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

	public double doubleValue() {
		return (double) value;
	}

	public boolean isInfinite() {
		return isInfinite(value);
	}

	public boolean isNaN() {
		return isNaN(value);
	}

	public static float parseFloat(String s) {
		int[] numRead = new int[1];
		float f = floatFromString(s, numRead);
		if (numRead[0] == 1) {
			return f;
		} else {
			throw new NumberFormatException(s);
		}
	}

	public static int floatToIntBits(float value) {
		int result = floatToRawIntBits(value);

		// Check for NaN based on values of bit fields, maximum
		// exponent and nonzero significand.
		if (((result & EXP_BIT_MASK) == EXP_BIT_MASK) && (result & SIGNIF_BIT_MASK) != 0) {
			result = 0x7fc00000;
		}
		return result;
	}

	public static native int floatToRawIntBits(float value);

	public static native float intBitsToFloat(int bits);

	public static native boolean isInfinite(float value);

	public static native boolean isNaN(float value);

	public static native float floatFromString(String s, int[] numRead);
}