// Just to see how quick virtual method calls can be made in a large loop
class PerfTest {
	public static void main(String[] args) {
		for (Integer i = 0; i < 10000; ++i) {
			System.out.println(i.toString());
		}
	}
}