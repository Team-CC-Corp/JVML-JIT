package java.lang;

public abstract class Number {
    static native String toString(long value);
    static native String toString(double value);
    static native String toString(int value);
    static native String toString(float value);
    
    public abstract byte byteValue();
    public abstract short shortValue();
    public abstract int intValue();
    public abstract long longValue();
    public abstract float floatValue();
    public abstract double doubleValue();
}