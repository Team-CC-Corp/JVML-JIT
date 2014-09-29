package java.io;

public abstract class OutputStream implements AutoCloseable {
	@Override
	public void close() throws IOException {
	}

	public void flush() throws IOException {
	}

	public void write(byte[] b) throws IOException {
		write(b, 0, b.length);
	}

	public void write(byte[] b, int off, int len) throws IOException {
		for (int i = off; i < off + len; ++i) {
			write(b[i]);
		}
	}

	public abstract void write(int b) throws IOException;
}