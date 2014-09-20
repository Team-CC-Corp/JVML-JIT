public class TermTest {
	public static void main(String[] args) {
		System.term.write("Terminal testing");
		System.term.setCursor(0, System.term.getCursorY() + 1);
	}
}