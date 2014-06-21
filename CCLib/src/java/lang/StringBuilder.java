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

	public StringBuilder append(String s) {
		char[] c = s.toCharArray();
		Character[] ch = new Character[c.length];
		for (int i = 0; i < c.length; ++i) {
			ch[i] = c[i];
		}
		return append(ch);
	}

	public StringBuilder append(Object o) {
		return append(o.toString());
	}

	public String toString() {
		char[] arr = new char[string.size()];
		for (int i = 0; i < arr.length; ++i) {
			arr[i] = string.get(i);
		}
		return new String(arr);
	}
}