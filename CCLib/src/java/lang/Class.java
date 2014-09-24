package java.lang;

import java.lang.reflect.Method;
import java.lang.annotation.Annotation;

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
    native public Class<?>[] getInterfaces();
    native public boolean isInterface();
    native public boolean isInstance(Object obj);
    native public boolean isAssignableFrom(Class<?> cls);
    native public T newInstance();

    public T cast(Object obj)
    {
        if(obj != null && !this.isInstance(obj))
        {
            // TODO throw exception
            return null;
        }
        return (T) obj;
    }

    native public static Class getPrimitiveClass(String name);

    public native <A extends Annotation> A getAnnotation(Class<A> annotationClass);
}