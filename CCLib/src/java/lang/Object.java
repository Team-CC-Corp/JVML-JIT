package java.lang;

public class Object {
	private static native void registerNatives();
    static {
        registerNatives();
    }

    public String toString() {
        return "OBJECT";
    }
}