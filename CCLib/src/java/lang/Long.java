package java.lang;

public class Long extends Number {
    private final long value;
    public static final Class<Long>  TYPE = (Class<Long>) Class.getPrimitiveClass("long");

    public static Long valueOf(long value) {
        return new Long(value);
    }

    public Long(long value) {
        this.value = value;
    }

    public String toString() {
        return Number.toString(value);
    }

    public long longValue() {
        return value;
    }

    @Override
    public boolean equals(Object obj) {
        if(obj instanceof Long) {
            return value == ((Long)obj).longValue();
        }
        return false;
    }
}