public class ExceptionTest {
	public static void test() {
		throw new RuntimeException();
	}

	public static void main(String[] args) {
		try {
			try {
				throw new Exception();
			} catch(Exception e) {
				System.out.println("Caught");
				test();
			}
		} catch(Exception e) {
			System.out.println("Caught test");
		}
	}
}