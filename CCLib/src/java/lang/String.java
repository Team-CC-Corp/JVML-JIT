package java.lang;

public final class String {
    /**
     * The value is used for character storage.
     */
    private char value[];

    /**
     * The offset is the first index of the storage that is used.
     */
    private final int offset;

    /**
     * The count is the number of characters in the String.
     */
    private final int count;

    public String() {
        this.offset = 0;
        this.count = 0;
        this.value = new char[0];
    }

    public String(char value[]) {
        int size = value.length;
        this.offset = 0;
        this.count = size;
        char[] buf = new char[size];
        for (int i = 0; i < value.length; i++) {
            buf[i] = value[i];
        }
        this.value = buf;
    }

    String(int offset, int count, char value[]) {
        this.offset = offset;
        this.count = count;
        this.value = value;
    }

    public String concat(String str) {
        int otherLen = str.count;
        if (otherLen == 0) {
            return this;
        }
        char buf[] = new char[count + otherLen];
        getChars(0, count, buf, 0);
        str.getChars(0, otherLen, buf, count);
        return new String(0, count + otherLen, buf);
    }

    public void getChars(int srcBegin, int srcEnd, char dst[], int dstBegin) {
        for (int i = srcBegin; i < srcEnd; i++) {
            dst[dstBegin + i - srcBegin] = charAt(i);
        }
    }

    public char charAt(int index) {
        if ((index < 0) || (index >= count)) {
            throw new StringIndexOutOfBoundsException(index);
        }
        return value[index + offset];
    }

    @Override
    public boolean equals(Object anObject) {
        if (this == anObject) {
            return true;
        }

        if (anObject instanceof String) {
            String anotherString = (String) anObject;
            int n = count;
            if (n == anotherString.count) {
                char v1[] = value;
                char v2[] = anotherString.value;
                int i = offset;
                int j = anotherString.offset;
                while (n-- != 0) {
                    if (v1[i++] != v2[j++])
                        return false;
                }
                return true;
            }
        }
        return false;
    }

    public int length() {
        return count;
    }

    @Override
    public String toString() {
        return this;
    }
    
    @Override
    public int hashCode() {
    	int hash = 0;
    	for(int i = 0; i < count; i++) {
    		hash += charAt(i) * Math.pow(31, count - i - 1);
    	}
    	return hash;
    }

    public char[] toCharArray() {
        char[] arr = new char[count];
        for (int i = 0; i < arr.length; ++i) {
            arr[i] = value[offset + i];
        }
        return arr;
    }

    public int indexOf(String str) {
        return indexOf(str, 0);
    }

    public int indexOf(String str, int fromIndex) {
        return indexOf(value, 0, value.length,
                str.value, 0, str.value.length, fromIndex);
    }

    static int indexOf(char[] source, int sourceOffset, int sourceCount,
            String target, int fromIndex) {
        return indexOf(source, sourceOffset, sourceCount,
                       target.value, 0, target.value.length,
                       fromIndex);
    }

    static int indexOf(char[] source, int sourceOffset, int sourceCount,
            char[] target, int targetOffset, int targetCount,
            int fromIndex) {
        if (fromIndex >= sourceCount) {
            return (targetCount == 0 ? sourceCount : -1);
        }
        if (fromIndex < 0) {
            fromIndex = 0;
        }
        if (targetCount == 0) {
            return fromIndex;
        }

        char first = target[targetOffset];
        int max = sourceOffset + (sourceCount - targetCount);

        for (int i = sourceOffset + fromIndex; i <= max; i++) {
            /* Look for first character. */
            if (source[i] != first) {
                while (++i <= max && source[i] != first);
            }

            /* Found first character, now look at the rest of v2 */
            if (i <= max) {
                int j = i + 1;
                int end = j + targetCount - 1;
                for (int k = targetOffset + 1; j < end && source[j]
                        == target[k]; j++, k++);

                if (j == end) {
                    /* Found whole string. */
                    return i - sourceOffset;
                }
            }
        }
        return -1;
    }

    public int lastIndexOf(String str) {
        return lastIndexOf(str, value.length);
    }

    public int lastIndexOf(String str, int fromIndex) {
        return lastIndexOf(value, 0, value.length,
                str.value, 0, str.value.length, fromIndex);
    }

    static int lastIndexOf(char[] source, int sourceOffset, int sourceCount,
            String target, int fromIndex) {
        return lastIndexOf(source, sourceOffset, sourceCount,
                       target.value, 0, target.value.length,
                       fromIndex);
    }

    static int lastIndexOf(char[] source, int sourceOffset, int sourceCount,
            char[] target, int targetOffset, int targetCount,
            int fromIndex) {
        /*
         * Check arguments; return immediately where possible. For
         * consistency, don't check for null str.
         */
        int rightIndex = sourceCount - targetCount;
        if (fromIndex < 0) {
            return -1;
        }
        if (fromIndex > rightIndex) {
            fromIndex = rightIndex;
        }
        /* Empty string always matches. */
        if (targetCount == 0) {
            return fromIndex;
        }

        int strLastIndex = targetOffset + targetCount - 1;
        char strLastChar = target[strLastIndex];
        int min = sourceOffset + targetCount - 1;
        int i = min + fromIndex;

    startSearchForLastChar:
        while (true) {
            while (i >= min && source[i] != strLastChar) {
                i--;
            }
            if (i < min) {
                return -1;
            }
            int j = i - 1;
            int start = j - (targetCount - 1);
            int k = strLastIndex - 1;

            while (j > start) {
                if (source[j--] != target[k--]) {
                    i--;
                    continue startSearchForLastChar;
                }
            }
            return start - sourceOffset + 1;
        }
    }

    public String substring(int beginIndex) {
        if (beginIndex < 0) {
            throw new StringIndexOutOfBoundsException(beginIndex);
        }
        int subLen = value.length - beginIndex;
        if (subLen < 0) {
            throw new StringIndexOutOfBoundsException(subLen);
        }
        return (beginIndex == 0) ? this : new String(value, beginIndex, subLen);
    }

    public String substring(int beginIndex, int endIndex) {
        if (beginIndex < 0) {
            throw new StringIndexOutOfBoundsException(beginIndex);
        }
        if (endIndex > value.length) {
            throw new StringIndexOutOfBoundsException(endIndex);
        }
        int subLen = endIndex - beginIndex;
        if (subLen < 0) {
            throw new StringIndexOutOfBoundsException(subLen);
        }
        return ((beginIndex == 0) && (endIndex == value.length)) ? this
                : new String(value, beginIndex, subLen);
    }
}