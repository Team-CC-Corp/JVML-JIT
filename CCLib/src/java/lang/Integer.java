package java.lang;

public class Integer extends Number {
	public static final int MIN_VALUE = 0x80000000;
	public static final int MAX_VALUE = 0x7fffffff;
	public static final Class<Integer> TYPE = (Class<Integer>) Class.getPrimitiveClass("int");

	private final int value;

	private static class IntegerCache {
		static final int low = -128;
		static final int high = 127;
		static final Integer cache[];
		static {
			cache = new Integer[(high - low) + 1];
			int j = low;
			for (int k = 0; k < cache.length; k++)
				cache[k] = new Integer(j++);
		}

		private IntegerCache() {
		}
	}

	public static Integer valueOf(int i) {
		assert IntegerCache.high >= 127;
		if (i >= IntegerCache.low && i <= IntegerCache.high)
			return IntegerCache.cache[i + (-IntegerCache.low)];
		return new Integer(i);
	}

	final static int[] sizeTable = { 9, 99, 999, 9999, 99999, 999999, 9999999, 99999999, 999999999, Integer.MAX_VALUE };

	static int stringSize(int x) {
		for (int i = 0;; i++)
			if (x <= sizeTable[i])
				return i + 1;
	}

	public Integer(int value) {
		this.value = value;
	}

	public String toString() {
		return toString(value);
	}

	public int intValue() {
		return value;
	}

	@Override
	public boolean equals(Object obj) {
		if (obj instanceof Integer) {
			return value == ((Integer) obj).intValue();
		}
		return false;
	}

	public static Integer valueOf(String value) {
		return valueOf(parseInt(value));
	}

	public int hashCode() {
		return value;
	}

	public int compareTo(Integer other) {
		return value - other.value;
	}

	public static String toString(int v, int radix) {
		return Long.toString(v, radix);
	}

	public static String toString(int v) {
		return toString(v, 10);
	}

	public static String toHexString(int v) {
		return Long.toString(((long) v) & 0xFFFFFFFFL, 16);
	}

	public static String toOctalString(int v) {
		return Long.toString(((long) v) & 0xFFFFFFFFL, 8);
	}

	public static String toBinaryString(int v) {
		return Long.toString(((long) v) & 0xFFFFFFFFL, 2);
	}

	public byte byteValue() {
		return (byte) value;
	}

	public short shortValue() {
		return (short) value;
	}

	public long longValue() {
		return value;
	}

	public float floatValue() {
		return (float) value;
	}

	public double doubleValue() {
		return (double) value;
	}

	public static int signum(int v) {
		if (v == 0)
			return 0;
		else if (v > 0)
			return 1;
		else
			return -1;
	}

	// See http://graphics.stanford.edu/~seander/bithacks.html#CountBitsSetParallel
	public static int bitCount(int v) {
		v = v - ((v >> 1) & 0x55555555);
		v = (v & 0x33333333) + ((v >> 2) & 0x33333333);
		return ((v + (v >> 4) & 0xF0F0F0F) * 0x1010101) >> 24;
	}

	public static int reverseBytes(int v) {
		int byte3 = v >>> 24;
		int byte2 = (v >>> 8) & 0xFF00;
		int byte1 = (v << 8) & 0xFF00;
		int byte0 = v << 24;
		return (byte0 | byte1 | byte2 | byte3);
	}

	public static int parseInt(String s) {
		return parseInt(s, 10);
	}

	public static int parseInt(String s, int radix) {
		return (int) Long.parseLong(s, radix);
	}

	public static Integer decode(String string) {
		if (string.startsWith("-")) {
			if (string.startsWith("-0") || string.startsWith("-#")) {
				return new Integer(-decode(string.substring(1)));
			}
		} else if (string.startsWith("0")) {
			char c = string.length() < 2 ? (char) -1 : string.charAt(1);
			if (c == 'x' || c == 'X') {
				return new Integer(parseInt(string.substring(2), 0x10));
			}
			return new Integer(parseInt(string, 010));
		} else if (string.startsWith("#")) {
			return new Integer(parseInt(string.substring(1), 0x10));
		}
		return new Integer(parseInt(string, 10));
	}
}