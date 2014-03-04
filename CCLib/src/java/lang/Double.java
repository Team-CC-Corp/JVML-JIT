package java.lang;

public class Double extends Number {
    private final double value;

    public static Double valueOf(double value) {
        return new Double(value);
    }

    public Double(double value) {
        this.value = value;
    }

    public String toString() {
        return Number.toString(value);
    }
}