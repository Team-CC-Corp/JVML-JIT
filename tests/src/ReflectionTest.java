import java.lang.reflect.Method;

public class ReflectionTest {
	public int a(String s) {
		System.out.println("Reflect: a("+s+")");
		return 3;
	}

	public static void main(String[] args) {
		Method m = ReflectionTest.class.getMethod("a", String.class);
		System.out.println((Integer) m.invoke(new ReflectionTest(), "Testing reflected invocation") * 2);
	}
}