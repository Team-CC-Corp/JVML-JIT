package java.lang.reflect;

public class Method {
	private Method(){}

	private String name;
	private Class declaringClass;
	native public Object invoke(Object target, Object... args);
}