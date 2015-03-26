package java.io;

public abstract class InputStream implements Closeable {
    public int available() throws IOException {
        return 0;
    }
    
    @Override
    public void close() throws IOException {
    }

    public void mark(int readLimit) {
    }

    public boolean markSupported() throws IOException {
        return false;
    }
    public void reset() throws IOException {
        throw new IOException("Default behavior is to throw this(reset in InputStream!)");
    }
    public int read(byte[] b) throws IOException {
        return read(b, 0, b.length);
    }

    public int read(byte[] b, int off, int len) throws IOException {
        for (int i = off; i < off + len; ++i) {
            int bv=read();
            if (bv==-1)
                return i;
            b[i]=(byte)bv;
        }
        return len;
    }

    public abstract int read() throws IOException;

    public long skip(long n) throws IOException {
        for (long i=0;i<n;i++)
        {
            int b=read();
            if (b==-1)
                return i;
        }
        return n;
    }
}