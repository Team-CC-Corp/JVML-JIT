package cc.terminal;

public abstract class Terminal {
	public abstract void write(String text);

	public abstract void clearLine();
	public void clear() {
		int x = getCursorX();
		int y = getCursorX();

		for (int i = 0; i < height(); ++i) {
			setCursor(x, i);
			clearLine();
		}

		setCursor(x, y);
	}

	public abstract int getCursorX();
	public abstract int getCursorY();
	public abstract void setCursor(int x, int y);

	public abstract boolean isColor();

	public abstract int width();
	public abstract int height();

	public abstract void scroll(int n);

	public abstract void setTextColor(Color c);
	public abstract void setBackgroundColor(Color c);
	public void setColor(Color textColor, Color backgroundColor) {
		setTextColor(textColor);
		setBackgroundColor(backgroundColor);
	}
}