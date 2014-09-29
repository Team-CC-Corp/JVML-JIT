package java.lang.reflect;

import java.lang.annotation.Annotation;

public class Method {
	private Method(){}

	private String name;
	private Class declaringClass;
	native public Object invoke(Object target, Object... args);
	public native <T extends Annotation> T getAnnotation(Class<T> annotationClass);
	public native Class<?>[] getParameterTypes();
	public native int getParameterCount();
}