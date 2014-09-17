public class ExceptionTest {
	public static void main(String[] args) {
		a(3);
	}

	public static void a(int x) {
		if(x == 0)
			throw new RuntimeException("Runtime Exception message");
		b(x);
	}

	public static void b(int x) {
		c(x);
	}

	public static void c(int x) {
		a(x - 1);
	}
}