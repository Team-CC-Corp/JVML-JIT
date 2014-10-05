package java.io;

public class FilterInputStream extends InputStream {
    protected InputStream in;

    public FilterInputStream(InputStream in) {
        this.in = in;
    }

    @Override
    public int read() throws IOException {
        return in.read();
    }
}