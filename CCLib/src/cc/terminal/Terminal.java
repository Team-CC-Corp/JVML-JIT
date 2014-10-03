package cc.terminal;

public interface Terminal {
    public void write(char c);
    public default void write(char[] c) {
        for (char ch : c) {
            write(ch);
        }
    }
    public default void write(String text) {
        write(text.toCharArray());
    }

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

    public default int nextLine() {
        return nextLine(getCursorX());
    }

    public default int nextLine(int x) {
        if (getCursorY() == height() - 1) {
            scroll(1);
            setCursor(x, getCursorY());
        } else {
            setCursor(x, getCursorY() + 1);
        }
        return getCursorY();
    }
}