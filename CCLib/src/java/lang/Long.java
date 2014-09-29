package java.lang;

public class Long extends Number {

	public static final long MIN_VALUE = -9223372036854775808l;
	public static final long MAX_VALUE = 9223372036854775807l;

	private final long value;
	public static final Class<Long> TYPE = (Class<Long>) Class.getPrimitiveClass("long");

	public static Long valueOf(long value) {
		return new Long(value);
	}

	public Long(long value) {
		this.value = value;
	}

	public Long(String s) {
		this.value = parseLong(s);
	}

	public long longValue() {
		return value;
	}

	@Override
	public boolean equals(Object obj) {
		if (obj instanceof Long) {
			return value == ((Long) obj).longValue();
		}
		return false;
	}

	public static Long valueOf(String value) {
		return new Long(value);
	}

	public int compareTo(Long o) {
		return value > o.value ? 1 : (value < o.value ? -1 : 0);
	}

	public int hashCode() {
		return (int) ((value >> 32) ^ (value & 0xFF));
	}

	public String toString() {
		return toString(value);
	}

	public static String toString(long v, int radix) {
		if (radix < 1 || radix > 36) {
			throw new IllegalArgumentException("radix " + radix + " not in [1,36]");
		}

		if (v == 0) {
			return "0";
		}

		boolean negative = v < 0;

		int size = (negative ? 1 : 0);
		for (long n = v; n != 0; n /= radix)
			++size;

		char[] array = new char[size];

		int i = size - 1;
		for (long n = v; n != 0; n /= radix) {
			long digit = n % radix;
			if (negative)
				digit = -digit;

			if (digit >= 0 && digit <= 9) {
				array[i] = (char) ('0' + digit);
			} else {
				array[i] = (char) ('a' + (digit - 10));
			}
			--i;
		}

		if (negative) {
			array[i] = '-';
		}

		return new String(array, 0, size);
	}

	public static String toString(long v) {
		return Number.toString(v);
		//return toString(v, 10);
	}

	public static String toHexString(long v) {
		return toString(v, 16);
	}

	public static String toOctalString(long v) {
		return toString(v, 8);
	}

	public static String toBinaryString(long v) {
		return toString(v, 2);
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

	public float floatValue() {
		return (float) value;
	}

	public double doubleValue() {
		return (double) value;
	}

	public static int signum(long v) {
		if (v == 0)
			return 0;
		else if (v > 0)
			return 1;
		else
			return -1;
	}

	private static long pow(long a, long b) {
		long c = 1;
		for (int i = 0; i < b; ++i)
			c *= a;
		return c;
	}

	public static long parseLong(String s) {
		return parseLong(s, 10);
	}

	public static long parseLong(String s, int radix) {
		int i = 0;
		long number = 0;
		boolean negative = s.startsWith("-");
		int length = s.length();
		if (negative) {
			i = 1;
			--length;
		}

		long factor = pow(radix, length - 1);
		for (; i < s.length(); ++i) {
			char c = s.charAt(i);
			int digit = Character.digit(c, radix);
			if (digit >= 0) {
				number += digit * factor;
				factor /= radix;
			} else {
				throw new NumberFormatException("invalid character " + c + " code " + (int) c);
			}
		}

		if (negative) {
			number = -number;
		}

		return number;
	}
}