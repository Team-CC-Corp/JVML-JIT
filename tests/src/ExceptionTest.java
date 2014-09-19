public class ExceptionTest {
	static int[] strArray = new int[10];
	public static void main(String[] args) {
		try {
			System.out.println(strArray[10]);
		} catch(Exception e) {
			e.printStackTrace();
			System.out.println("Caught");
		}
	}
}