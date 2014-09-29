/* Copyright (c) 2008-2014, Avian Contributors

Permission to use, copy, modify, and/or distribute this software
for any purpose with or without fee is hereby granted, provided
that the above copyright notice and this permission notice appear
in all copies.

There is NO WARRANTY for this software.  See license.txt for
details. */

package java.lang;

//import java.util.Random;

public final class Math {
	public static final double E = 2.718281828459045;
	public static final double PI = 3.141592653589793;
//	private static final Random random = new Random();

	private Math() {
	}

	public static double max(double a, double b) {
		return (a < b ? b : a);
	}

	public static double min(double a, double b) {
		return (a > b ? b : a);
	}

	public static float max(float a, float b) {
		return (a < b ? b : a);
	}

	public static float min(float a, float b) {
		return (a > b ? b : a);
	}

	public static long max(long a, long b) {
		return (a < b ? b : a);
	}

	public static long min(long a, long b) {
		return (a > b ? b : a);
	}

	public static int max(int a, int b) {
		return (a < b ? b : a);
	}

	public static int min(int a, int b) {
		return (a > b ? b : a);
	}

	public static int abs(int v) {
		return (v < 0 ? -v : v);
	}

	public static long abs(long v) {
		return (v < 0 ? -v : v);
	}

	public static float abs(float v) {
		return (v < 0 ? -v : v);
	}

	public static double abs(double v) {
		return (v < 0 ? -v : v);
	}

	/*public static long round(double v) {
		return (long) Math.floor(v + 0.5);
	}

	public static int round(float v) {
		return (int) Math.floor(v + 0.5);
	}*/

	public static double signum(double d) {
		return d > 0 ? +1.0 : d < 0 ? -1.0 : 0;
	}

	public static float signum(float f) {
		return f > 0 ? +1.0f : f < 0 ? -1.0f : 0;
	}
	
	/**
     * Returns the double conversion of the most negative (closest to negative
     * infinity) integer value which is greater than the argument.
     * <p>
     * Special cases:
     * <ul>
     * <li>{@code ceil(+0.0) = +0.0}</li>
     * <li>{@code ceil(-0.0) = -0.0}</li>
     * <li>{@code ceil((anything in range (-1,0)) = -0.0}</li>
     * <li>{@code ceil(+infinity) = +infinity}</li>
     * <li>{@code ceil(-infinity) = -infinity}</li>
     * <li>{@code ceil(NaN) = NaN}</li>
     * </ul>
     * 
     * @param d
     *            the value whose closest integer value has to be computed.
     * @return the ceiling of the argument.
     */
    public static native double ceil(double d);
    
    /**
     * Returns the closest double approximation of the natural logarithm of the
     * argument. The returned result is within 1 ulp (unit in the last place) of
     * the real result.
     * <p>
     * Special cases:
     * <ul>
     * <li>{@code log(+0.0) = -infinity}</li>
     * <li>{@code log(-0.0) = -infinity}</li>
     * <li>{@code log((anything < 0) = NaN}</li>
     * <li>{@code log(+infinity) = +infinity}</li>
     * <li>{@code log(-infinity) = NaN}</li>
     * <li>{@code log(NaN) = NaN}</li>
     * </ul>
     * 
     * @param d
     *            the value whose log has to be computed.
     * @return the natural logarithm of the argument.
     */
    public static native double log(double d);
    
    /**
     * Returns the closest double approximation of the square root of the
     * argument.
     * <p>
     * Special cases:
     * <ul>
     * <li>{@code sqrt(+0.0) = +0.0}</li>
     * <li>{@code sqrt(-0.0) = -0.0}</li>
     * <li>{@code sqrt( (anything < 0) ) = NaN}</li>
     * <li>{@code sqrt(+infinity) = +infinity}</li>
     * <li>{@code sqrt(NaN) = NaN}</li>
     * </ul>
     * 
     * @param d
     *            the value whose square root has to be computed.
     * @return the square root of the argument.
     */
    public static native double sqrt(double d);

    public static native double pow(double v, double e);

	/*
	public static double random() {
		return random.nextDouble();
	}

	public static native double floor(double v);

	public static native double ceil(double v);

	public static native double exp(double v);

	public static native double log(double v);

	public static native double cos(double v);

	public static native double sin(double v);

	public static native double tan(double v);

	public static native double cosh(double v);

	public static native double sinh(double v);

	public static native double tanh(double v);

	public static native double acos(double v);

	public static native double asin(double v);

	public static native double atan(double v);

	public static native double sqrt(double v);

	public static native double pow(double v, double e);
	
	*/
}
