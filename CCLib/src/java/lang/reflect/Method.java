package java.lang.reflect;

public class Method {
	private Method(){}

	private String name;
	native public Object invoke(Object target, Object... args);
}