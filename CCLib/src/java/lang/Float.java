package java.lang;

public class Float extends Number {
    private final float value;
    public static final Class<Float>  TYPE = (Class<Float>) Class.getPrimitiveClass("float");

    public static Float valueOf(float value) {
        return new Float(value);
    }

    public Float(float value) {
        this.value = value;
    }

    public String toString() {
        return Number.toString(value);
    }

    public float floatValue() {
        return value;
    }
}