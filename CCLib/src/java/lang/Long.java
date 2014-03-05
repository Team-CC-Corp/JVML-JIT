package java.lang;

public class Long extends Number {
    private final long value;

    public static Long valueOf(long value) {
        return new Long(value);
    }

    public Long(long value) {
        this.value = value;
    }

    public String toString() {
        return Number.toString(value);
    }
}