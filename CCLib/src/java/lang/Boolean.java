/* Copyright (c) 2008-2014, Avian Contributors

   Permission to use, copy, modify, and/or distribute this software
   for any purpose with or without fee is hereby granted, provided
   that the above copyright notice and this permission notice appear
   in all copies.

   There is NO WARRANTY for this software.  See license.txt for
   details. */
package java.lang;

public class Boolean {
	public static final Boolean TRUE = new Boolean(true);
	public static final Boolean FALSE = new Boolean(false);
	public static final Class<Boolean> TYPE = (Class<Boolean>) Class.getPrimitiveClass("boolean");

	private final boolean value;

	public static Boolean valueOf(boolean value) {
		return value ? TRUE : FALSE;
	}

	public Boolean(boolean value) {
		this.value = value;
	}

	public boolean booleanValue() {
		return value;
	}

	@Override
	public boolean equals(Object obj) {
		if (obj instanceof Boolean) {
			return value == ((Boolean) obj).booleanValue();
		}
		return false;
	}

	public Boolean(String s) {
		this.value = "true".equals(s);
	}

	public int compareTo(Boolean o) {
		return (value ? (o.value ? 0 : 1) : (o.value ? -1 : 0));
	}

	@Override
	public int hashCode() {
		return (value ? 1 : 0);
	}

	@Override
	public String toString() {
		return toString(value);
	}

	public static String toString(boolean v) {
		return (v ? "true" : "false");
	}

	
	public static boolean getBoolean(String name) {
		return parseBoolean(System.getProperty(name));
	}

	public static boolean parseBoolean(String string) {
		return string != null && string.equalsIgnoreCase("true");
	}
}