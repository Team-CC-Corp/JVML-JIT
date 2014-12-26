package java.lang;

public class Byte extends Number {
    public static final byte MIN_VALUE = -128;
    public static final byte MAX_VALUE = 127;
    public static final Class<Byte>  TYPE = (Class<Byte>) Class.getPrimitiveClass("byte");

    private final byte value;

    private static class ByteCache {
        private ByteCache(){}

        static final Byte cache[] = new Byte[-(-128) + 127 + 1];

        static {
            for(int i = 0; i < cache.length; i++)
                cache[i] = new Byte((byte)(i - 128));
        }
    }

    public static Byte valueOf(byte b) {
        final int offset = 128;
        return ByteCache.cache[(int)b + offset];
    }

    public static String toString(byte b) {
        return Integer.toString((int)b);
    }

    public Byte(byte value) {
        this.value = value;
    }

    public String toString() {
        return Integer.toString((int)value);
    }

    public byte byteValue() {
        return value;
    }

    @Override
    public boolean equals(Object obj) {
        if(obj instanceof Byte) {
            return value == ((Byte)obj).byteValue();
        }
        return false;
    }
    
    @Override
    public int hashCode() {
    	return (int) value;
    }
}