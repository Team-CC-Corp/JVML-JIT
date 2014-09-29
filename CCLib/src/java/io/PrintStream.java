/* Copyright (c) 2008-2014, Avian Contributors

   Permission to use, copy, modify, and/or distribute this software
   for any purpose with or without fee is hereby granted, provided
   that the above copyright notice and this permission notice appear
   in all copies.

   There is NO WARRANTY for this software.  See license.txt for
   details. */

package java.io;

public class PrintStream extends OutputStream {
	private final OutputStream out;
	private final boolean autoFlush;

	private static class Static {
		private static final char[] newline = { '\n' }; //System.getProperty("line.separator").toCharArray();
	}

	public PrintStream(OutputStream out, boolean autoFlush) {
		this.out = out;
		this.autoFlush = autoFlush;
	}

	public PrintStream(OutputStream out, boolean autoFlush, String encoding) throws UnsupportedEncodingException {
		this.out = out;
		this.autoFlush = autoFlush;

		if (!(encoding.equals("UTF-8") || encoding.equals("ISO-8859-1"))) {
			throw new UnsupportedEncodingException(encoding);
		}
	}

	public PrintStream(OutputStream out) {
		this(out, false);
	}

	public void print(String str) {
		print((char[]) (str == null ? new char[] { '(', 'n', 'u', 'l', 'l', ')' } : str.toCharArray()));
	}

	public void print(Object o) {
		print(String.valueOf(o));
	}

	public void print(boolean v) {
		print(String.valueOf(v));
	}

	public void print(char c) {
		print(String.valueOf(c));
	}

	public void print(int v) {
		print(String.valueOf(v));
	}

	public void print(long v) {
		print(String.valueOf(v));
	}

	public void print(float v) {
		print(String.valueOf(v));
	}

	public void print(double v) {
		print(String.valueOf(v));
	}

	public void print(char[] c) {
		byte[] b = new byte[c.length];
		for (int i = 0; i < c.length; ++i) {
			b[i] = (byte) c[i];
		}
		try {
			write(b);
		} catch (IOException e) {
		}
	}

	public void println(String str) {
		println((char[]) (str == null ? new char[] { '(', 'n', 'u', 'l', 'l', ')' } : str.toCharArray()));
	}

	public synchronized void println() {
		print(Static.newline);
		if (autoFlush)
			flush();
	}

	public void println(Object o) {
		println(String.valueOf(o));
	}

	public void println(boolean v) {
		println(String.valueOf(v));
	}

	public void println(char c) {
		println(String.valueOf(c));
	}

	public void println(int v) {
		println(String.valueOf(v));
	}

	public void println(long v) {
		println(String.valueOf(v));
	}

	public void println(float v) {
		println(String.valueOf(v));
	}

	public void println(double v) {
		println(String.valueOf(v));
	}

	public void println(char[] c) {
		print(c);
		print(new char[] { '\n' });
	}

	public void write(int c) throws IOException {
		out.write(c);
		if (autoFlush && c == '\n')
			flush();
	}

	public void write(byte[] buffer, int offset, int length) throws IOException {
		out.write(buffer, offset, length);
		if (autoFlush)
			flush();
	}

	public void flush() {
		try {
			out.flush();
		} catch (IOException e) {
		}
	}

	public void close() {
		try {
			out.close();
		} catch (IOException e) {
		}
	}
}
