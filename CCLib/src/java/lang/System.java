package java.lang;

import java.io.InputStream;
import java.io.BufferedInputStream;
import java.io.PrintStream;
import java.util.HashMap;

import cc.terminal.TerminalInputStream;
import cc.terminal.TerminalOutputStream;
import cc.terminal.SystemTerminal;
import cc.terminal.Color;

public final class System {
    public static SystemTerminal term;
    public static PrintStream out;
    public static PrintStream err;
    public static InputStream in;

    private static HashMap<String, String> props;
    private static native void initProperties();

    static {
        props = new HashMap<>();
        initProperties();

        term = new SystemTerminal();
        out = new PrintStream(new TerminalOutputStream(term), true);
        TerminalOutputStream errTerm = new TerminalOutputStream(term);
        err = new PrintStream(errTerm, true);
        errTerm.setTextColor(Color.RED);
        in = new BufferedInputStream(new TerminalInputStream());
    }

    native public static void load(String nativeName);

    public static native void arraycopy(Object src, int srcPos, Object dest, int destPos, int length);

    public static String getProperty(String key) {
        checkKey(key);
        return props.get(key);
    }

    public static String getProperty(String key, String def) {
        checkKey(key);
        String value = props.get(key);
        if (value == null)
            return def;
        return value;
    }

    public static String setProperty(String key, String value) {
        checkKey(key);
        return props.put(key, value);
    }

    public static String clearProperty(String key) {
        checkKey(key);
        return props.remove(key);
    }

    private static void checkKey(String key) {
        if (key == null) {
            throw new NullPointerException("key can't be null");
        }
        if (key.equals("")) {
            throw new IllegalArgumentException("key can't be empty");
        }
    }
}