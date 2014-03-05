package java.lang;

public class Short extends Number {
    private final short value;

    public static Short valueOf(short value) {
        return new Short(value);
    }

    public Short(short value) {
        this.value = value;
    }

    public String toString() {
        return Number.toString(value);
    }
}