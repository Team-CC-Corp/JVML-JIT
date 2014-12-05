package java.lang;

public class Object {
    private static native void registerNatives();
    static {
        registerNatives();
    }

    public native String toString();
    public native Class<?> getClass();

    public boolean equals(Object obj) {
        return this == obj;
    }
    
    public native int hashCode();
}