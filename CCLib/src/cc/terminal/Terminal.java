package cc.terminal;

public interface Terminal {
	public void write(String text);

	public void clearLine();
	public default void clear() {
		int x = getCursorX();
		int y = getCursorX();

		for (int i = 0; i < height(); ++i) {
			setCursor(x, i);
			clearLine();
		}

		setCursor(x, y);
	}

	public int getCursorX();
	public int getCursorY();
	public void setCursor(int x, int y);

	public boolean isColor();

	public int width();
	public int height();

	public void scroll(int n);

	public void setTextColor(Color c);
	public void setBackgroundColor(Color c);
	public default void setColor(Color textColor, Color backgroundColor) {
		setTextColor(textColor);
		setBackgroundColor(backgroundColor);
	}
}