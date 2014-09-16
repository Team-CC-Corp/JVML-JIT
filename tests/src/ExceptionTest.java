public class ExceptionTest {
	public static void test() {
		throw new RuntimeException("Runtime Exception message");
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
			e.printStackTrace();
		}
	}
}