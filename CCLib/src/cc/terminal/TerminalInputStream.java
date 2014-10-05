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
                current = Computer.read().toCharArray();
            else
                current = Computer.read(replace).toCharArray();
            this.index = 0;
        }

        char c = current[index];
        index++;
        return c;
    }
}