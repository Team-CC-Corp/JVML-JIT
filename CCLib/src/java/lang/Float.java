package java.lang;

public class Float extends Number {
    private final float value;

    public Float(float value) {
        this.value = value;
    }

    public String toString() {
        return Number.toString(value);
    }
}