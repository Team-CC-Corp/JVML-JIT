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

    public String toString() {
        return value ? "true" : "false";
    }

    public boolean booleanValue() {
        return value;
    }
}