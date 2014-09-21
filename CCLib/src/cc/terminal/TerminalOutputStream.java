package cc.terminal;

import java.io.OutputStream;

public class TerminalOutputStream extends OutputStream {
	private final Terminal terminal;

	public TerminalOutputStream(Terminal t) {
		terminal = t;
	}

	@Override
	public void write(int b) {
		if (b == '\n') {
			terminal.nextLine(0);
		} else {
			terminal.write((char)b);
		}
	}
}