package java.lang;

public class String {
    /** The value is used for character storage. */
    private final char value[];

    /** The offset is the first index of the storage that is used. */
    private final int offset;

    /** The count is the number of characters in the String. */
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
        for(int i = 0; i < value.length; i++) {
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
        int otherLen = str.length();
        if (otherLen == 0) {
            return this;
        }
        char buf[] = new char[count + otherLen];
        getChars(0, count, buf, 0);
        str.getChars(0, otherLen, buf, count);
        return new String(0, count + otherLen, buf);
    }

    public void getChars(int srcBegin, int srcEnd, char dst[], int dstBegin) {
        for(int i = srcBegin; i < srcEnd; i++) {
            dst[dstBegin + i - srcBegin] = value[i];
        }
    }

    public int length() {
        return count;
    }

    public String toString() {
        return this;
    }
}