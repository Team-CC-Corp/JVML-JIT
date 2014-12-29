package java.io;

public class PrintStream extends FilterOutputStream {
    private final boolean autoFlush;

    public PrintStream(OutputStream out) {
        this(out, false);
    }

    public PrintStream(OutputStream out, boolean autoFlush) {
        super(out);
        this.autoFlush = autoFlush;
    }

    public void println(char[] c) {
        print(c);
        print(new char[] {'\n'});
    }
    public void println(Object obj) {
        println((String)(obj == null ? null : obj.toString()));
    }
    public void println(String str) {
        println((char[])(str == null ? new char[] {'(','n','u','l','l',')'} : str.toCharArray()));
    }


    public void print(char[] c) {
        byte[] b = new byte[c.length];
        for (int i = 0; i < c.length; ++i) {
            b[i] = (byte)c[i];
        }
        try {
            write(b);
        } catch(IOException e) {}
    }
    public void print(Object obj) {
        print((String)(obj == null ? null : obj.toString()));
    }
    public void print(String str) {
        print((char[])(str == null ? new char[] {'(','n','u','l','l',')'} : str.toCharArray()));
    }

    @Override
    public void write(byte[] b) throws IOException {
        super.write(b);
        if (autoFlush) {
            flush();
        }
    }

    @Override
    public void write(byte[] b, int off, int len) throws IOException {
        super.write(b, off, len);
        if (autoFlush) {
            flush();
        }
    }

    @Override
    public void write(int b) throws IOException {
        super.write(b);
        if (autoFlush && b == '\n') {
            flush();
        }
    }
}