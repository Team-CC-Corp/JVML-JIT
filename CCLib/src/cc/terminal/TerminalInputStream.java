package cc.terminal;

import cc.Computer;

import java.io.IOException;
import java.io.InputStream;

public class TerminalInputStream extends InputStream {
    private char[] current;
    private int index;

    private String replace;

    public TerminalInputStream() {
    }

    public void setReplace(String replace) {
        this.replace = replace;
    }

    public String getReplace() {
        return replace;
    }

    @Override
    public int read() throws IOException {
        if (current != null && index == current.length)
            current = null;

        if (current == null) {
            if (this.replace == null)
                current = (Computer.read() + "\n").toCharArray();
            else
                current = (Computer.read(replace) + "\n").toCharArray();
            this.index = 0;
        }

        char c = current[index];
        index++;
        return c;
    }

    @Override
    public int read(byte b[], int off, int len) throws IOException {
        if (b == null) {
            throw new NullPointerException();
        } else if (off < 0 || len < 0 || len > b.length - off) {
            throw new IndexOutOfBoundsException();
        } else if (len == 0) {
            return 0;
        }

        int c = read();
        if (c == -1) {
            return -1;
        }
        b[off] = (byte) c;

        int i = 1;
        try {
            for (; i < len && c != '\n'; i++) {
                c = read();
                if (c == -1) {
                    break;
                }
                b[off + i] = (byte) c;
            }
        } catch (IOException ee) {
        }
        return i;
    }
}