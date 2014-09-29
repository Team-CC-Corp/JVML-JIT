package cc.terminal;

import java.io.OutputStream;
import java.util.ArrayList;

// Optional type parameter.
public class TerminalOutputStream<T extends Terminal> extends OutputStream {
	private final T terminal;

	private ArrayList<StringBuilder> outBuffer;

	private Color textColor = Color.WHITE;
	private Color backgroundColor = Color.BLACK;

	public TerminalOutputStream(T t) {
		terminal = t;
		outBuffer = new ArrayList<>();
		outBuffer.add(new StringBuilder());
	}

	public void setTextColor(Color c) {
		textColor = c;
	}

	public void setBackgroundColor(Color c) {
		backgroundColor = c;
	}

	public void setColor(Color text, Color bg) {
		setTextColor(text);
		setBackgroundColor(bg);
	}

	@Override
	public void flush() {
		terminal.setTextColor(textColor);
		terminal.setBackgroundColor(backgroundColor);

		for (int i = 0; i < outBuffer.size(); ++i) {
			terminal.write(outBuffer.get(i).toString());
			if (i != outBuffer.size() - 1) {
				terminal.nextLine(0);
			}
		}
		outBuffer.clear();
		outBuffer.add(new StringBuilder());
	}

	@Override
	public void write(int b) {
		if (b == '\n') {
			outBuffer.add(new StringBuilder());
			return;
		}

		int width = outBuffer.size() == 1 ? terminal.width() - terminal.getCursorX() : terminal.width();

		StringBuilder builder = outBuffer.get(outBuffer.size() - 1);
		if (builder.length() >= width) {
			builder = new StringBuilder();
			outBuffer.add(builder);
		}

		builder.append((char)b);
	}
}