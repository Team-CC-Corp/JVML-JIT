package java.lang;

import java.io.BufferedInputStream;
import java.io.InputStream;
import java.io.PrintStream;

import cc.terminal.TerminalInputStream;
import cc.terminal.TerminalOutputStream;
import cc.terminal.SystemTerminal;
import cc.terminal.Color;

public final class System {
    public static SystemTerminal term;
    public static PrintStream out;
    public static PrintStream err;
    public static InputStream in;

    static {
        term = new SystemTerminal();
        out = new PrintStream(new TerminalOutputStream(term), true);
        TerminalOutputStream errTerm = new TerminalOutputStream(term);
        err = new PrintStream(errTerm, true);
        errTerm.setTextColor(Color.RED);
        in = new TerminalInputStream();
    }

    native public static void load(String nativeName);

    public static native void arraycopy(Object src, int srcPos, Object dest, int destPos, int length);
}