package java.lang;

import java.io.UnsupportedEncodingException;

import jvml.Iso88591;
import jvml.Utf8;

public class String implements Comparable<String>, CharSequence {

    private static final String UTF_8_ENCODING = "UTF-8";
    private static final String ISO_8859_1_ENCODING = "ISO-8859-1";
    private static final String LATIN_1_ENCODING = "LATIN-1";
    private static final String DEFAULT_ENCODING = UTF_8_ENCODING;

    /** The value is used for character storage. */
    private char value[];

    /** The offset is the first index of the storage that is used. */
    private int offset;

    /** The count is the number of characters in the String. */
    private int count;

    private int hashCode;

    public String() {
        this.offset = 0;
        this.count = 0;
        this.value = new char[0];
    }

    public String(char[] data, int offset, int length) {
        this.offset = 0;
        this.count = length;
        char[] buf = new char[length];
        for (int i = 0; i < length; i++) {
            buf[i] = data[i + offset];
        }
        this.value = buf;
    }

    public String(char[] data) {
        this(data, 0, data.length);
    }

    /**
     * Creates a {@code String} from the contents of the specified {@code
     * StringBuffer}.
     * 
     * @param stringbuffer
     *            the buffer to get the contents from.
     */
    public String(StringBuffer stringbuffer) {
        offset = 0;
        synchronized (stringbuffer) {
            value = stringbuffer.toString().toCharArray();
            count = stringbuffer.length();
        }
    }

    public String(byte bytes[], int offset, int length, String charsetName) throws UnsupportedEncodingException {
        this(bytes, offset, length);
        // FIXME 
        if (!(charsetName.equalsIgnoreCase("UTF-8") || charsetName.equalsIgnoreCase("ISO-8859-1") || charsetName
                .equalsIgnoreCase("US-ASCII"))) {
            throw new UnsupportedEncodingException(charsetName);
        }
    }

    public String(byte[] data, int offset, int length) {
        int l = data.length;
        if (offset < 0 || offset + length > l) {
            throw new IndexOutOfBoundsException(offset + " < 0 or " + offset + " + " + length + " > " + l);
        }
        Object c = Utf8.decode((byte[]) data, offset, length);
        if (c instanceof char[]) {
            length = ((char[]) c).length;
        }
        this.value = ((char[]) c);
        this.offset = 0;
        this.count = length;
    }

    public String(byte[] data) {
        this(data, 0, data.length);
    }

    public String(byte[] data, String charset) throws UnsupportedEncodingException {
        this(data, 0, data.length, charset);
    }

    public String(byte bytes[], int highByte, int offset, int length) {
        if (offset < 0 || offset + length > bytes.length) {
            throw new IndexOutOfBoundsException(offset + " < 0 or " + offset + " + " + length + " > " + bytes.length);
        }

        char[] c = new char[length];
        int mask = highByte << 8;
        for (int i = 0; i < length; ++i) {
            c[i] = (char) ((bytes[offset + i] & 0xFF) | mask);
        }

        this.value = c;
        this.offset = 0;
        this.count = length;
    }

    /*
     * public void getChars(int srcBegin, int srcEnd, char dst[], int dstBegin)
     * { for (int i = srcBegin; i < srcEnd; i++) { dst[dstBegin + i - srcBegin]
     * = value[i]; } }
     */

    public int length() {
        return count;
    }

    @Override
    public String toString() {
        return this;
    }

    /*
     * public char[] toCharArray() { char[] arr = new char[count]; for (int i =
     * 0; i < arr.length; ++i) { arr[i] = value[offset + i]; } return arr; }
     */

    @Override
    public int hashCode() {
        if (hashCode == 0) {
            int h = 0;
            for (int i = 0; i < count; ++i)
                h = (h * 31) + charAt(i);
            hashCode = h;
        }
        return hashCode;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        } else if (o instanceof String) {
            String s = (String) o;
            return s.count == count && compareTo(s) == 0;
        } else {
            return false;
        }
    }

    public boolean equalsIgnoreCase(String s) {
        if (this == s) {
            return true;
        } else {
            return s.count == count && compareToIgnoreCase(s) == 0;
        }
    }

    //@Override
    public int compareTo(String s) {
        if (this == s)
            return 0;

        int idx = 0;
        int result;

        int end = (count < s.count ? count : s.count);

        while (idx < end) {
            if ((result = charAt(idx) - s.charAt(idx)) != 0) {
                return result;
            }
            idx++;
        }
        return count - s.count;
    }

    public int compareToIgnoreCase(String s) {
        if (this == s)
            return 0;

        int idx = 0;
        int result;

        int end = (count < s.count ? count : s.count);

        while (idx < end) {
            if ((result = Character.toLowerCase(charAt(idx)) - Character.toLowerCase(s.charAt(idx))) != 0) {
                return result;
            }
            idx++;
        }
        return count - s.count;
    }

    public String trim() {
        int start = -1;
        for (int i = 0; i < count; ++i) {
            char c = charAt(i);
            if (start == -1 && !Character.isWhitespace(c)) {
                start = i;
                break;
            }
        }

        int end = -1;
        for (int i = count - 1; i >= 0; --i) {
            char c = charAt(i);
            if (end == -1 && !Character.isWhitespace(c)) {
                end = i + 1;
                break;
            }
        }

        if (start >= end) {
            return "";
        } else {
            return substring(start, end);
        }
    }

    public String toLowerCase() {
        for (int j = 0; j < count; ++j) {
            char ch = charAt(j);
            if (Character.toLowerCase(ch) != ch) {
                char[] b = new char[count];
                for (int i = 0; i < count; ++i) {
                    b[i] = Character.toLowerCase(charAt(i));
                }
                return new String(b, 0, count);
            }
        }
        return this;
    }

    public String toUpperCase() {
        for (int j = 0; j < count; ++j) {
            char ch = charAt(j);
            if (Character.toUpperCase(ch) != ch) {
                char[] b = new char[count];
                for (int i = 0; i < count; ++i) {
                    b[i] = Character.toUpperCase(charAt(i));
                }
                return new String(b, 0, count);
            }
        }
        return this;
    }

    public int indexOf(int c) {
        return indexOf(c, 0);
    }

    public int indexOf(int c, int start) {
        for (int i = start; i < count; ++i) {
            if (charAt(i) == c) {
                return i;
            }
        }

        return -1;
    }

    public int lastIndexOf(int ch) {
        return lastIndexOf(ch, count - 1);
    }

    public int indexOf(String s) {
        return indexOf(s, 0);
    }

    public int indexOf(String s, int start) {
        if (s.count == 0)
            return start;

        for (int i = start; i < count - s.count + 1; ++i) {
            int j = 0;
            for (; j < s.count; ++j) {
                if (charAt(i + j) != s.charAt(j)) {
                    break;
                }
            }
            if (j == s.count) {
                return i;
            }
        }

        return -1;
    }

    public int lastIndexOf(String s) {
        return lastIndexOf(s, count - s.count);
    }

    public int lastIndexOf(String s, int lastIndex) {
        if (s.count == 0)
            return lastIndex;

        for (int i = Math.min(count - s.count, lastIndex); i >= 0; --i) {
            int j = 0;
            for (; j < s.count && i + j < count; ++j) {
                if (charAt(i + j) != s.charAt(j)) {
                    break;
                }
            }
            if (j == s.count) {
                return i;
            }
        }

        return -1;
    }

    public String replace(char oldChar, char newChar) {
        char[] buf = new char[count];
        for (int i = 0; i < count; i++) {
            if (charAt(i) == oldChar) {
                buf[i] = newChar;
            } else {
                buf[i] = charAt(i);
            }
        }
        return new String(buf, 0, count);
    }

    public String substring(int start) {
        return substring(start, count);
    }

    public String substring(int start, int end) {
        if (start < 0)
            throw new StringIndexOutOfBoundsException(start);
        else if (end > count)
            throw new StringIndexOutOfBoundsException(end);
        int newLen = end - start;
        if (newLen < 0)
            throw new StringIndexOutOfBoundsException(newLen);

        if (start == 0 && end == count)
            return this;
        else if (end - start == 0)
            return "";
        else
            return new String(value, offset + start, newLen);
    }

    public boolean startsWith(String s) {
        if (count >= s.count) {
            return substring(0, s.count).compareTo(s) == 0;
        } else {
            return false;
        }
    }

    public boolean startsWith(String s, int start) {
        if (count >= s.count + start) {
            return substring(start, s.count).compareTo(s) == 0;
        } else {
            return false;
        }
    }

    public boolean endsWith(String s) {
        if (count >= s.count) {
            return substring(count - s.count).compareTo(s) == 0;
        } else {
            return false;
        }
    }

    public String concat(String s) {
        if (s.length() == 0) {
            return this;
        } else {
            return this + s;
        }
    }

    public void getBytes(int srcOffset, int srcLength, byte[] dst, int dstOffset) {
        if (srcOffset < 0)
            throw new StringIndexOutOfBoundsException(srcOffset);
        else if (srcOffset + srcLength > count)
            throw new StringIndexOutOfBoundsException(srcOffset + srcLength);
        else if (srcLength < 0)
            throw new StringIndexOutOfBoundsException(srcLength);

        char[] src = (char[]) value;
        for (int i = 0; i < srcLength; ++i) {
            dst[i + dstOffset] = (byte) src[i + offset + srcOffset];
        }
    }

    public byte[] getBytes() {
        try {
            return getBytes(DEFAULT_ENCODING);
        } catch (java.io.UnsupportedEncodingException ex) {
            throw new RuntimeException("Default '" + DEFAULT_ENCODING + "' encoding not handled", ex);
        }
    }

    public byte[] getBytes(String format) throws java.io.UnsupportedEncodingException {
        String fmt = format.trim().toUpperCase();
        if (DEFAULT_ENCODING.equals(fmt)) {
            return Utf8.encode((char[]) value, offset, count);
        } else if (ISO_8859_1_ENCODING.equals(fmt) || LATIN_1_ENCODING.equals(fmt)) {
            return Iso88591.encode((char[]) value, offset, count);
        } else {
            throw new java.io.UnsupportedEncodingException("Encoding " + format + " not supported");
        }
    }

    public void getChars(int srcOffset, int srcEnd, char[] dst, int dstOffset) {
        if (srcOffset < 0)
            throw new StringIndexOutOfBoundsException(srcOffset);
        else if (srcEnd > count)
            throw new StringIndexOutOfBoundsException(srcEnd);

        int srcLength = srcEnd - srcOffset;

        char[] src = (char[]) value;
        System.arraycopy(src, offset + srcOffset, dst, dstOffset, srcLength);

    }

    public char[] toCharArray() {
        char[] b = new char[count];
        getChars(0, count, b, 0);
        return b;
    }

    //@Override
    public char charAt(int index) {
        if (index < 0 || index > count) {
            throw new StringIndexOutOfBoundsException(index);
        }
        return ((char[]) value)[index + offset];
    }

    public static String valueOf(Object s) {
        return s == null ? "null" : s.toString();
    }

    public static String valueOf(boolean v) {
        return Boolean.toString(v);
    }

    public static String valueOf(byte v) {
        return Byte.toString(v);
    }

    public static String valueOf(short v) {
        return Short.toString(v);
    }

    public static String valueOf(char v) {
        return Character.toString(v);
    }

    public static String valueOf(int v) {
        return Integer.toString(v);
    }

    public static String valueOf(long v) {
        return Long.toString(v);
    }

    public static String valueOf(float v) {
        return Float.toString(v);
    }

    public static String valueOf(double v) {
        return Double.toString(v);
    }

    public static String valueOf(char[] data, int offset, int length) {
        return new String(data, offset, length);
    }

    public static String valueOf(char[] data) {
        return valueOf(data, 0, data.length);
    }
    
    /**
     * Creates a new string containing the characters in the specified character
     * array. Modifying the character array after creating the string has no
     * effect on the string.
     *
     * @param data
     *            the array of characters.
     * @return the new string.
     * @throws NullPointerException
     *             if {@code data} is {@code null}.
     */
    public static String copyValueOf(char[] data) {
        return new String(data, 0, data.length);
    }

    /**
     * Creates a new string containing the specified characters in the character
     * array. Modifying the character array after creating the string has no
     * effect on the string.
     *
     * @param data
     *            the array of characters.
     * @param start
     *            the starting offset in the character array.
     * @param length
     *            the number of characters to use.
     * @return the new string.
     * @throws NullPointerException
     *             if {@code data} is {@code null}.
     * @throws IndexOutOfBoundsException
     *             if {@code length < 0, start < 0} or {@code start + length >
     *             data.length}.
     */
    public static String copyValueOf(char[] data, int start, int length) {
        return new String(data, start, length);
    }

    public int lastIndexOf(int ch, int lastIndex) {
        if (lastIndex >= count) {
            lastIndex = count - 1;
        }
        for (int i = lastIndex; i >= 0; --i) {
            if (charAt(i) == ch) {
                return i;
            }
        }

        return -1;
    }

    public boolean regionMatches(int thisOffset, String match, int matchOffset, int length) {
        return regionMatches(false, thisOffset, match, matchOffset, length);
    }

    public boolean regionMatches(boolean ignoreCase, int thisOffset, String match, int matchOffset, int length) {
        String a = substring(thisOffset, thisOffset + length);
        String b = match.substring(matchOffset, matchOffset + length);
        if (ignoreCase) {
            return a.equalsIgnoreCase(b);
        } else {
            return a.equals(b);
        }
    }

    public boolean isEmpty() {
        return count == 0;
    }

    public boolean contains(CharSequence match) {
        return indexOf(match.toString()) != -1;
    }

    @Override
    public CharSequence subSequence(int start, int end) {
        return substring(start, end);
    }

    /*
     * public int codePointAt(int offset) { return Character.codePointAt(this,
     * offset); }
     * 
     * public int codePointCount(int start, int end) { return
     * Character.codePointCount(this, start, end); }
     */

}