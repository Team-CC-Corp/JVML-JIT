package java.lang;

import java.lang.reflect.Method;
import java.lang.annotation.Annotation;

public final class Class<T> {
	private String name;

	/*
	 * Constructor. Only the VM creates Class
	 * objects.
	 */
	private Class() {
	}

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
	
	public native boolean isPrimitive();
	
	public native boolean isArray();

	native public boolean isAssignableFrom(Class<?> cls);

	native public T newInstance();
	
	native public T[] getEnumConstants();

	public T cast(Object obj) {
		if (obj != null && !this.isInstance(obj)) {
			// TODO throw exception
			return null;
		}
		return (T) obj;
	}

	native public static Class getPrimitiveClass(String name);

	public native <A extends Annotation> A getAnnotation(Class<A> annotationClass);

	public Class getComponentType() {
		if (isArray()) {
			String n = getName();
			if ("[Z".equals(n)) {
				return Boolean.TYPE;
			} else if ("[B".equals(n)) {
				return Byte.TYPE;
			} else if ("[S".equals(n)) {
				return Short.TYPE;
			} else if ("[C".equals(n)) {
				return Character.TYPE;
			} else if ("[I".equals(n)) {
				return Integer.TYPE;
			} else if ("[F".equals(n)) {
				return Float.TYPE;
			} else if ("[J".equals(n)) {
				return Long.TYPE;
			} else if ("[D".equals(n)) {
				return Double.TYPE;
			}

			try {
				return forName(n.substring(n.lastIndexOf("[") + 1)); // TODO: Not tested
			} catch (ClassNotFoundException e) {
				return null;
			}
		} else {
			return null;
		}
	}

	public native static Class forName(String name) throws ClassNotFoundException;

	public native static Class<?> forName(String name, boolean initialize, ClassLoader loader) throws ClassNotFoundException;

}