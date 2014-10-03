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

    public StringBuilder insert(int offset, Character[] arr) {
        for (Character c : arr) {
            string.add(offset++, c);
        }
        return this;
    }

    public StringBuilder insert(int offset, char[] arr) {
        Character[] ch = new Character[arr.length];
        for (int i = 0; i < arr.length; ++i) {
            ch[i] = arr[i];
        }
        return insert(offset, ch);
    }

    public StringBuilder insert(int offset, String s) {
        return insert(offset, s.toCharArray());
    }

    public StringBuilder insert(int offset, Object o) {
        return insert(offset, o.toString());
    }

    public StringBuilder insert(int offset, boolean b) {
        return insert(offset, Boolean.valueOf(b));
    }

    public StringBuilder insert(int offset, char c) {
        return insert(offset, Character.valueOf(c));
    }

    public StringBuilder insert(int offset, int i) {
        return insert(offset, Integer.valueOf(i));
    }

    public StringBuilder insert(int offset, long lng) {
        return insert(offset, Long.valueOf(lng));
    }

    public StringBuilder insert(int offset, float f) {
        return insert(offset, Float.valueOf(f));
    }

    public StringBuilder insert(int offset, double d) {
        return insert(offset, Double.valueOf(d));
    }

    public StringBuilder delete(int start, int end) {
        for (int i = start; i < end; ++i) {
            string.remove(start);
        }

        return this;
    }

    public String substring(int start) {
        return substring(start, length());
    }

    public String substring(int start, int end) {
        char[] c = new char[end - start];
        for (int i = start; i < end; ++i) {
            c[i - start] = string.get(i);
        }
        return new String(c);
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