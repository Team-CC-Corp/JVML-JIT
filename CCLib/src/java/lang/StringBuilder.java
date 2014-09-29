package java.lang;

import java.util.List;
import java.util.ArrayList;
import java.util.Arrays;

public class StringBuilder {
	private List<Character> string;

	public StringBuilder() {
		string = new ArrayList<Character>();
	}

	public StringBuilder(String s) {
		this();
		append(s);
	}

	public StringBuilder append(Character[] arr) {
		for (Character c : arr) {
			string.add(c);
		}
		return this;
	}

	public StringBuilder append(char[] arr) {
		Character[] ch = new Character[arr.length];
		for (int i = 0; i < arr.length; ++i) {
			ch[i] = arr[i];
		}
		return append(ch);
	}

	public StringBuilder append(String s) {
		return append(s.toCharArray());
	}

	public StringBuilder append(Object o) {
		return append(o.toString());
	}

	public StringBuilder append(boolean b) {
		return append(Boolean.valueOf(b));
	}

	public StringBuilder append(char c) {
		return append(Character.valueOf(c));
	}

	public StringBuilder append(int i) {
		return append(Integer.valueOf(i));
	}

	public StringBuilder append(long lng) {
		return append(Long.valueOf(lng));
	}

	public StringBuilder append(float f) {
		return append(Float.valueOf(f));
	}

	public StringBuilder append(double d) {
		return append(Double.valueOf(d));
	}

	public String toString() {
		char[] arr = new char[string.size()];
		for (int i = 0; i < arr.length; ++i) {
			arr[i] = string.get(i);
		}
		return new String(arr);
	}

	public int length() {
		return string.size();
	}
}