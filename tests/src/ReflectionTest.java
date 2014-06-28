import java.lang.reflect.Method;

public class ReflectionTest {
	public int a(String s) {
		System.out.println("Reflect: a("+s+")");
		return 3;
	}

	public static void b(String s) {
		System.out.println(s);
	}

	public static void main(String[] args) {
		Method m1 = ReflectionTest.class.getMethod("a", String.class);
		System.out.println((Integer) m1.invoke(new ReflectionTest(), "Testing reflected invocation") * 2);

		Method m2 = ReflectionTest.class.getMethod("b", String.class);
		m2.invoke(null, "Testing static reflected invocation");
	}
}