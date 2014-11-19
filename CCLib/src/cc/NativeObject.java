package cc;
/* Contains basic methods for working with native objects.*/
public abstract class NativeObject {
	static {
		System.load("cc/native/NativeObject.lua");
	}

    public native String toString();
    public native int hashCode();
    public boolean equals(Object other)
    {
        if (other==null) throw new NullPointerException("other must != null");
        if (other instanceof NativeObject) return equalsInner((NativeObject)other);
        return false;
    }
    private native boolean equalsInner(NativeObject other);
}
