package java.lang;


public class Object {
	private static native void registerNatives();
    private static int hashCodeGenerator = 1;
	static {
        registerNatives();
    }
	
	private int hashCode = 0;

    public native String toString();
    public native Class<?> getClass();

    public boolean equals(Object obj) {
        return this == obj;
    }
	
	public int hashCode() {
		return identityHashCode();
	}
	
	int identityHashCode() {
		if (hashCode == 0) {
			hashCode = hashCodeGenerator++;
		}
		return hashCode;
	}
	
	protected Object clone() throws CloneNotSupportedException {
        throw new CloneNotSupportedException();
    }
}