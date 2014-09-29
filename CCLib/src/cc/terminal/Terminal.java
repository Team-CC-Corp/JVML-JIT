package cc.terminal;

public interface Terminal {
	public void write(char c);

	public void write(char[] c);

	public void write(String text);

	public void clearLine();

	public void clear();

	public int getCursorX();

	public int getCursorY();

	public void setCursor(int x, int y);

	public boolean isColor();

	public int width(); 

	public int height();

	public void scroll(int n);

	public void setTextColor(Color c);

	public void setBackgroundColor(Color c);

	public void setColor(Color textColor, Color backgroundColor);

	public int nextLine();

	public int nextLine(int x);
}