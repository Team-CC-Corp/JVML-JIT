public class EnumTest {
	public static void main(String[] args) {
		ExampleEnum e = ExampleEnum.valueOf("A");

		switch(e) {
			case A:
				System.out.println("A");
				break;
			case B:
				System.out.println("B");
				break;
			case C:
				System.out.println("C");
				break;
		}
	}
}

enum ExampleEnum {
	A, B, C;
}