package java.lang;

public class Boolean {
    public static final Boolean TRUE = new Boolean(true);
    public static final Boolean FALSE = new Boolean(false);
    public static final Class<Boolean>  TYPE = (Class<Boolean>) Class.getPrimitiveClass("boolean");
    
    private final boolean value;

    public static Boolean valueOf(boolean value) {
        return value ? TRUE : FALSE;
    }

    public Boolean(boolean value) {
        this.value = value;
    }

    @Override
    public String toString() {
        return value ? "true" : "false";
    }

    public boolean booleanValue() {
        return value;
    }

    @Override
    public boolean equals(Object obj) {
        if(obj instanceof Boolean) {
            return value == ((Boolean)obj).booleanValue();
        }
        return false;
    }
    
    @Override
    public int hashCode() {
        if(value) {
            return 1231;
        } else {
            return 1237;
        }
    }
}