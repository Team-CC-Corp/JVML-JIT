package java.lang;

public final class Class<T> {
	private String name;

	/*
     * Constructor. Only the VM creates Class
     * objects.
     */
    private Class() {}

    native public Class<? super T> getSuperclass();

    @Override
    public String toString() {
    	return "class " + name;
    }

    public String getName() {
    	return name;
    }
    native public static Class getPrimitiveClass(String name);
}