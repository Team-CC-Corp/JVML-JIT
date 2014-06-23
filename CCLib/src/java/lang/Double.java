package java.lang;

public class Double extends Number {
    private final double value;
    public static final Class<Double>  TYPE = (Class<Double>) Class.getPrimitiveClass("double");

    public static Double valueOf(double value) {
        return new Double(value);
    }

    public Double(double value) {
        this.value = value;
    }

    public String toString() {
        return Number.toString(value);
    }

    public double doubleValue() {
        return value;
    }
}