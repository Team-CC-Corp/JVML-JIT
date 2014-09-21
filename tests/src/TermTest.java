public class TermTest {
	public static void main(String[] args) {
		System.term.write("Terminal testing");
		if (System.term.getCursorY() == System.term.height() - 1) {
			System.term.scroll(1);
			System.term.setCursor(0, System.term.getCursorY());
		} else {
			System.term.setCursor(0, System.term.getCursorY() + 1);
		}
	}
}