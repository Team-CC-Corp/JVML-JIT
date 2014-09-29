public class ExceptionTest {
	static int[] strArray = new int[10];
	public static void main(String[] args) {
		try {
			System.out.println(strArray[10]);
		} catch(Exception e) {
			e.printStackTrace();
			System.out.println("Caught");
		}
		try {
			Object a = null;
			System.out.println(a.toString());
		} catch(NullPointerException e) {
			e.printStackTrace();
			System.out.println("Caught null pointer");
		}
		try {
			int x = 5;
			int y = 0;
			int z = x/y;
		} catch(ArithmeticException e) {
			e.printStackTrace();
			System.out.println("Caught / by zero");
		}
		try {
			int x = 5;
			int y = 0;
			int z = x%y;
		} catch(ArithmeticException e) {
			e.printStackTrace();
			System.out.println("Caught / by zero");
		}
		try {
			Object o = (Integer)5;
			String s = (String)o;
		} catch(ClassCastException e) {
			e.printStackTrace();
			System.out.println("Caught invalid cast");
		}
	}
}