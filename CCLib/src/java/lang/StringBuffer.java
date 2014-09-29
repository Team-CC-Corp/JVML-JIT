/*
 *  Licensed to the Apache Software Foundation (ASF) under one or more
 *  contributor license agreements.  See the NOTICE file distributed with
 *  this work for additional information regarding copyright ownership.
 *  The ASF licenses this file to You under the Apache License, Version 2.0
 *  (the "License"); you may not use this file except in compliance with
 *  the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */

package java.lang;

//import java.io.IOException;
//import java.io.ObjectInputStream;
//import java.io.ObjectOutputStream;
//import java.io.ObjectStreamField;
import java.io.Serializable;

/**
 * StringBuffer is a variable size contiguous indexable array of characters. The
 * length of the StringBuffer is the number of characters it contains. The
 * capacity of the StringBuffer is the number of characters it can hold.
 * <p>
 * Characters may be inserted at any position up to the length of the
 * StringBuffer, increasing the length of the StringBuffer. Characters at any
 * position in the StringBuffer may be replaced, which does not affect the
 * StringBuffer length.
 * <p>
 * The capacity of a StringBuffer may be specified when the StringBuffer is
 * created. If the capacity of the StringBuffer is exceeded, the capacity is
 * increased.
 * 
 * @see String
 * @see StringBuilder
 * @since 1.0
 */
public final class StringBuffer extends AbstractStringBuilder implements
        Appendable, Serializable, CharSequence {

    private static final long serialVersionUID = 3388685877147921107L;

//    private static final ObjectStreamField serialPersistentFields[] = {
//            new ObjectStreamField("count", int.class), //$NON-NLS-1$
//            new ObjectStreamField("shared", boolean.class), //$NON-NLS-1$
//            new ObjectStreamField("value", char[].class), }; //$NON-NLS-1$

    /**
     * Constructs a new StringBuffer using the default capacity which is 16.
     */
    public StringBuffer() {
        super();
    }

    /**
     * Constructs a new StringBuffer using the specified capacity.
     * 
     * @param capacity
     *            the initial capacity.
     */
    public StringBuffer(int capacity) {
        super(capacity);
    }

    /**
     * Constructs a new StringBuffer containing the characters in the specified
     * string. The capacity of the new buffer will be the length of the
     * {@code String} plus the default capacity.
     * 
     * @param string
     *            the string content with which to initialize the new instance.
     * @throws NullPointerException
     *            if {@code string} is {@code null}.
     */
    public StringBuffer(String string) {
        super(string);
    }

    /**
     * Constructs a StringBuffer and initializes it with the content from the
     * specified {@code CharSequence}. The capacity of the new buffer will be
     * the length of the {@code CharSequence} plus the default capacity.
     * 
     * @param cs
     *            the content to initialize the instance.
     * @throws NullPointerException
     *            if {@code cs} is {@code null}.
     * @since 1.5
     */
    public StringBuffer(CharSequence cs) {
        super(cs.toString());
    }

    /**
     * Adds the string representation of the specified boolean to the end of
     * this StringBuffer.
     * <p>
     * If the argument is {@code true} the string {@code "true"} is appended,
     * otherwise the string {@code "false"} is appended.
     *
     * @param b
     *            the boolean to append.
     * @return this StringBuffer.
     * @see String#valueOf(boolean)
     */
    public StringBuffer append(boolean b) {
        return append(b ? "true" : "false"); //$NON-NLS-1$//$NON-NLS-2$
    }

    /**
     * Adds the specified character to the end of this buffer.
     * 
     * @param ch
     *            the character to append.
     * @return this StringBuffer.
     * @see String#valueOf(char)
     */
    public synchronized StringBuffer append(char ch) {
        append0(ch);
        return this;
    }

    /**
     * Adds the string representation of the specified double to the end of this
     * StringBuffer.
     * 
     * @param d
     *            the double to append.
     * @return this StringBuffer.
     * @see String#valueOf(double)
     */
    public StringBuffer append(double d) {
        return append(Double.toString(d));
    }

    /**
     * Adds the string representation of the specified float to the end of this
     * StringBuffer.
     * 
     * @param f
     *            the float to append.
     * @return this StringBuffer.
     * @see String#valueOf(float)
     */
    public StringBuffer append(float f) {
        return append(Float.toString(f));
    }

    /**
     * Adds the string representation of the specified integer to the end of
     * this StringBuffer.
     * 
     * @param i
     *            the integer to append.
     * @return this StringBuffer.
     * @see String#valueOf(int)
     */
    public StringBuffer append(int i) {
        return append(Integer.toString(i));
    }

    /**
     * Adds the string representation of the specified long to the end of this
     * StringBuffer.
     * 
     * @param l
     *            the long to append.
     * @return this StringBuffer.
     * @see String#valueOf(long)
     */
    public StringBuffer append(long l) {
        return append(Long.toString(l));
    }

    /**
     * Adds the string representation of the specified object to the end of this
     * StringBuffer.
     * <p>
     * If the specified object is {@code null} the string {@code "null"} is
     * appended, otherwise the objects {@code toString} is used to get its
     * string representation.
     *
     * @param obj
     *            the object to append (may be null).
     * @return this StringBuffer.
     * @see String#valueOf(Object)
     */
    public synchronized StringBuffer append(Object obj) {
        if (obj == null) {
            appendNull();
        } else {
            append0(obj.toString());
        }
        return this;
    }

    /**
     * Adds the specified string to the end of this buffer.
     * <p>
     * If the specified string is {@code null} the string {@code "null"} is
     * appended, otherwise the contents of the specified string is appended.
     *
     * @param string
     *            the string to append (may be null).
     * @return this StringBuffer.
     */
    public synchronized StringBuffer append(String string) {
        append0(string);
        return this;
    }

    /**
     * Adds the specified StringBuffer to the end of this buffer.
     * <p>
     * If the specified StringBuffer is {@code null} the string {@code "null"}
     * is appended, otherwise the contents of the specified StringBuffer is
     * appended.
     *
     * @param sb
     *            the StringBuffer to append (may be null).
     * @return this StringBuffer.
     * 
     * @since 1.4
     */
    public synchronized StringBuffer append(StringBuffer sb) {
        if (sb == null) {
            appendNull();
        } else {
            synchronized (sb) {
                append0(sb.getValue(), 0, sb.length());
            }
        }
        return this;
    }

    /**
     * Adds the character array to the end of this buffer.
     * 
     * @param chars
     *            the character array to append.
     * @return this StringBuffer.
     * @throws NullPointerException
     *            if {@code chars} is {@code null}.
     */
    public synchronized StringBuffer append(char chars[]) {
        append0(chars);
        return this;
    }

    /**
     * Adds the specified sequence of characters to the end of this buffer.
     * 
     * @param chars
     *            the character array to append.
     * @param start
     *            the starting offset.
     * @param length
     *            the number of characters.
     * @return this StringBuffer.
     * @throws ArrayIndexOutOfBoundsException
     *             if {@code length < 0} , {@code start < 0} or {@code start +
     *             length > chars.length}.
     * @throws NullPointerException
     *            if {@code chars} is {@code null}.
     */
    public synchronized StringBuffer append(char chars[], int start, int length) {
        append0(chars, start, length);
        return this;
    }

    /**
     * Appends the specified CharSequence to this buffer.
     * <p>
     * If the specified CharSequence is {@code null} the string {@code "null"}
     * is appended, otherwise the contents of the specified CharSequence is
     * appended.
     *
     * @param s
     *            the CharSequence to append.
     * @return this StringBuffer.
     * @since 1.5
     */
    public synchronized StringBuffer append(CharSequence s) {
        if (s == null) {
            appendNull();
        } else {
            append0(s.toString());
        }
        return this;
    }

    /**
     * Appends the specified subsequence of the CharSequence to this buffer.
     * <p>
     * If the specified CharSequence is {@code null}, then the string {@code
     * "null"} is used to extract a subsequence.
     *
     * @param s
     *            the CharSequence to append.
     * @param start
     *            the inclusive start index.
     * @param end
     *            the exclusive end index.
     * @return this StringBuffer.
     * @throws IndexOutOfBoundsException
     *             if {@code start} or {@code end} are negative, {@code start}
     *             is greater than {@code end} or {@code end} is greater than
     *             the length of {@code s}.
     * @since 1.5
     */
    public synchronized StringBuffer append(CharSequence s, int start, int end) {
        append0(s, start, end);
        return this;
    }

    /**
     * Appends the string representation of the specified Unicode code point to
     * the end of this buffer.
     * <p>
     * The code point is converted to a {@code char[]} as defined by
     * {@link Character#toChars(int)}.
     *
     * @param codePoint
     *            the Unicode code point to encode and append.
     * @return this StringBuffer.
     * @see Character#toChars(int)
     * @since 1.5
     */
    public StringBuffer appendCodePoint(int codePoint) {
        return append(Character.toChars(codePoint));
    }

    @Override
    public synchronized char charAt(int index) {
        return super.charAt(index);
    }

//    @Override
//    public synchronized int codePointAt(int index) {
//        return super.codePointAt(index);
//    }
//
//    @Override
//    public synchronized int codePointBefore(int index) {
//        return super.codePointBefore(index);
//    }
//
//    @Override
//    public synchronized int codePointCount(int beginIndex, int endIndex) {
//        return super.codePointCount(beginIndex, endIndex);
//    }

    /**
     * Deletes a range of characters.
     * 
     * @param start
     *            the offset of the first character.
     * @param end
     *            the offset one past the last character.
     * @return this StringBuffer.
     * @throws StringIndexOutOfBoundsException
     *             if {@code start < 0}, {@code start > end} or {@code end >
     *             length()}.
     */
    public synchronized StringBuffer delete(int start, int end) {
        delete0(start, end);
        return this;
    }

    /**
     * Deletes the character at the specified offset.
     * 
     * @param location
     *            the offset of the character to delete.
     * @return this StringBuffer.
     * @throws StringIndexOutOfBoundsException
     *             if {@code location < 0} or {@code location >= length()}
     */
    public synchronized StringBuffer deleteCharAt(int location) {
        deleteCharAt0(location);
        return this;
    }

    @Override
    public synchronized void ensureCapacity(int min) {
        super.ensureCapacity(min);
    }

    /**
     * Copies the requested sequence of characters to the {@code char[]} passed
     * starting at {@code idx}.
     * 
     * @param start
     *            the starting offset of characters to copy.
     * @param end
     *            the ending offset of characters to copy.
     * @param buffer
     *            the destination character array.
     * @param idx
     *            the starting offset in the character array.
     * @throws IndexOutOfBoundsException
     *             if {@code start < 0}, {@code end > length()}, {@code start >
     *             end}, {@code index < 0}, {@code end - start > buffer.length -
     *             index}
     */
    @Override
    public synchronized void getChars(int start, int end, char[] buffer, int idx) {
        super.getChars(start, end, buffer, idx);
    }

    @Override
    public synchronized int indexOf(String subString, int start) {
        return super.indexOf(subString, start);
    }

    /**
     * Inserts the character into this buffer at the specified offset.
     * 
     * @param index
     *            the index at which to insert.
     * @param ch
     *            the character to insert.
     * @return this buffer.
     * @throws ArrayIndexOutOfBoundsException
     *             if {@code index < 0} or {@code index > length()}.
     */
    public synchronized StringBuffer insert(int index, char ch) {
        insert0(index, ch);
        return this;
    }

    /**
     * Inserts the string representation of the specified boolean into this
     * buffer at the specified offset.
     * 
     * @param index
     *            the index at which to insert.
     * @param b
     *            the boolean to insert.
     * @return this buffer.
     * @throws StringIndexOutOfBoundsException
     *             if {@code index < 0} or {@code index > length()}.
     */
    public StringBuffer insert(int index, boolean b) {
        return insert(index, b ? "true" : "false"); //$NON-NLS-1$ //$NON-NLS-2$
    }

    /**
     * Inserts the string representation of the specified integer into this
     * buffer at the specified offset.
     * 
     * @param index
     *            the index at which to insert.
     * @param i
     *            the integer to insert.
     * @return this buffer.
     * @throws StringIndexOutOfBoundsException
     *             if {@code index < 0} or {@code index > length()}.
     */
    public StringBuffer insert(int index, int i) {
        return insert(index, Integer.toString(i));
    }

    /**
     * Inserts the string representation of the specified long into this buffer
     * at the specified offset.
     * 
     * @param index
     *            the index at which to insert.
     * @param l
     *            the long to insert.
     * @return this buffer.
     * @throws StringIndexOutOfBoundsException
     *             if {@code index < 0} or {@code index > length()}.
     */
    public StringBuffer insert(int index, long l) {
        return insert(index, Long.toString(l));
    }

    /**
     * Inserts the string representation of the specified into this buffer
     * double at the specified offset.
     * 
     * @param index
     *            the index at which to insert.
     * @param d
     *            the double to insert.
     * @return this buffer.
     * @throws StringIndexOutOfBoundsException
     *             if {@code index < 0} or {@code index > length()}.
     */
    public StringBuffer insert(int index, double d) {
        return insert(index, Double.toString(d));
    }

    /**
     * Inserts the string representation of the specified float into this buffer
     * at the specified offset.
     * 
     * @param index
     *            the index at which to insert.
     * @param f
     *            the float to insert.
     * @return this buffer.
     * @throws StringIndexOutOfBoundsException
     *             if {@code index < 0} or {@code index > length()}.
     */
    public StringBuffer insert(int index, float f) {
        return insert(index, Float.toString(f));
    }

    /**
     * Inserts the string representation of the specified object into this
     * buffer at the specified offset.
     * <p>
     * If the specified object is {@code null}, the string {@code "null"} is
     * inserted, otherwise the objects {@code toString} method is used to get
     * its string representation.
     *
     * @param index
     *            the index at which to insert.
     * @param obj
     *            the object to insert (may be null).
     * @return this buffer.
     * @throws StringIndexOutOfBoundsException
     *             if {@code index < 0} or {@code index > length()}.
     */
    public StringBuffer insert(int index, Object obj) {
        return insert(index, obj == null ? "null" : obj.toString()); //$NON-NLS-1$
    }

    /**
     * Inserts the string into this buffer at the specified offset.
     * <p>
     * If the specified string is {@code null}, the string {@code "null"} is
     * inserted, otherwise the contents of the string is inserted.
     *
     * @param index
     *            the index at which to insert.
     * @param string
     *            the string to insert (may be null).
     * @return this buffer.
     * @throws StringIndexOutOfBoundsException
     *             if {@code index < 0} or {@code index > length()}.
     */
    public synchronized StringBuffer insert(int index, String string) {
        insert0(index, string);
        return this;
    }

    /**
     * Inserts the character array into this buffer at the specified offset.
     * 
     * @param index
     *            the index at which to insert.
     * @param chars
     *            the character array to insert.
     * @return this buffer.
     * @throws StringIndexOutOfBoundsException
     *             if {@code index < 0} or {@code index > length()}.
     * @throws NullPointerException
     *            if {@code chars} is {@code null}.
     */
    public synchronized StringBuffer insert(int index, char[] chars) {
        insert0(index, chars);
        return this;
    }

    /**
     * Inserts the specified subsequence of characters into this buffer at the
     * specified index.
     * 
     * @param index
     *            the index at which to insert.
     * @param chars
     *            the character array to insert.
     * @param start
     *            the starting offset.
     * @param length
     *            the number of characters.
     * @return this buffer.
     * @throws NullPointerException
     *             if {@code chars} is {@code null}.
     * @throws StringIndexOutOfBoundsException
     *             if {@code length < 0}, {@code start < 0}, {@code start +
     *             length > chars.length}, {@code index < 0} or {@code index >
     *             length()}
     */
    public synchronized StringBuffer insert(int index, char chars[], int start,
            int length) {
        insert0(index, chars, start, length);
        return this;
    }

    /**
     * Inserts the specified CharSequence into this buffer at the specified
     * index.
     * <p>
     * If the specified CharSequence is {@code null}, the string {@code "null"}
     * is inserted, otherwise the contents of the CharSequence.
     *
     * @param index
     *            The index at which to insert.
     * @param s
     *            The char sequence to insert.
     * @return this buffer.
     * @throws IndexOutOfBoundsException
     *             if {@code index < 0} or {@code index > length()}.
     * @since 1.5
     */
    public synchronized StringBuffer insert(int index, CharSequence s) {
        insert0(index, s == null ? "null" : s.toString()); //$NON-NLS-1$
        return this;
    }

    /**
     * Inserts the specified subsequence into this buffer at the specified
     * index.
     * <p>
     * If the specified CharSequence is {@code null}, the string {@code "null"}
     * is inserted, otherwise the contents of the CharSequence.
     * 
     * @param index
     *            The index at which to insert.
     * @param s
     *            The char sequence to insert.
     * @param start
     *            The inclusive start index in the char sequence.
     * @param end
     *            The exclusive end index in the char sequence.
     * @return this buffer.
     * @throws IndexOutOfBoundsException
     *             if {@code index} is negative or greater than the current
     *             length, {@code start} or {@code end} are negative, {@code
     *             start} is greater than {@code end} or {@code end} is greater
     *             than the length of {@code s}.
     * @since 1.5
     */
    public synchronized StringBuffer insert(int index, CharSequence s,
            int start, int end) {
        insert0(index, s, start, end);
        return this;
    }

    @Override
    public synchronized int lastIndexOf(String subString, int start) {
        return super.lastIndexOf(subString, start);
    }

//    @Override
//    public synchronized int offsetByCodePoints(int index, int codePointOffset) {
//        return super.offsetByCodePoints(index, codePointOffset);
//    }

    /**
     * Replaces the characters in the specified range with the contents of the
     * specified string.
     * 
     * @param start
     *            the inclusive begin index.
     * @param end
     *            the exclusive end index.
     * @param string
     *            the string that will replace the contents in the range.
     * @return this buffer.
     * @throws StringIndexOutOfBoundsException
     *             if {@code start} or {@code end} are negative, {@code start}
     *             is greater than {@code end} or {@code end} is greater than
     *             the length of {@code s}.
     */
    public synchronized StringBuffer replace(int start, int end, String string) {
        replace0(start, end, string);
        return this;
    }

    /**
     * Reverses the order of characters in this buffer.
     * 
     * @return this buffer.
     */
    public synchronized StringBuffer reverse() {
        reverse0();
        return this;
    }

    @Override
    public synchronized void setCharAt(int index, char ch) {
        super.setCharAt(index, ch);
    }

    @Override
    public synchronized void setLength(int length) {
        super.setLength(length);
    }

    @Override
    public synchronized CharSequence subSequence(int start, int end) {
        return super.substring(start, end);
    }

    @Override
    public synchronized String substring(int start) {
        return super.substring(start);
    }

    @Override
    public synchronized String substring(int start, int end) {
        return super.substring(start, end);
    }

    @Override
    public synchronized String toString() {
        return super.toString();
    }

    @Override
    public synchronized void trimToSize() {
        super.trimToSize();
    }

//    private synchronized void writeObject(ObjectOutputStream out)
//            throws IOException {
//        ObjectOutputStream.PutField fields = out.putFields();
//        fields.put("count", length()); //$NON-NLS-1$
//        fields.put("shared", false); //$NON-NLS-1$
//        fields.put("value", getValue()); //$NON-NLS-1$
//        out.writeFields();
//    }
//
//    private void readObject(ObjectInputStream in) throws IOException,
//            ClassNotFoundException {
//        ObjectInputStream.GetField fields = in.readFields();
//        int count = fields.get("count", 0); //$NON-NLS-1$
//        char[] value = (char[]) fields.get("value", null); //$NON-NLS-1$
//        set(value, count);
//    }
}
