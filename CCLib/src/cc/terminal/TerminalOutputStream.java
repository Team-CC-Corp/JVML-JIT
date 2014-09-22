package cc.terminal;

import java.io.OutputStream;
import java.util.ArrayList;

public class TerminalOutputStream extends OutputStream {
	private final Terminal terminal;

	private ArrayList<StringBuilder> outBuffer;

	public TerminalOutputStream(Terminal t) {
		terminal = t;
		outBuffer = new ArrayList<>();
		outBuffer.add(new StringBuilder());
	}

	@Override
	public void flush() {
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