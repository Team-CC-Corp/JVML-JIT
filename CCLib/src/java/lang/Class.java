package java.lang;

import java.lang.reflect.Method;

public final class Class<T> {
	private String name;

	/*
     * Constructor. Only the VM creates Class
     * objects.
     */
    private Class() {}


    @Override
    public String toString() {
        return "class " + name;
    }

    public String getName() {
        return name;
    }

    native public Class<? super T> getSuperclass();
    native public Method getMethod(String name, Class<?>... parameterTypes);
    native public Method[] getMethods();

    native public static Class getPrimitiveClass(String name);
}