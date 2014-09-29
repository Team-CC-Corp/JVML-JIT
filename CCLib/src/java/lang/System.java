package java.lang;

import java.io.PrintStream;
import cc.terminal.TerminalOutputStream;
import cc.terminal.SystemTerminal;
import cc.terminal.Color;

public final class System {
    
    private static char[] lineSeparator = new char[] { '\n' };
    
	public static SystemTerminal term;
	public static PrintStream out;
	public static PrintStream err;

	static {
		term = new SystemTerminal();
		out = new PrintStream(new TerminalOutputStream(term), true);
		TerminalOutputStream errTerm = new TerminalOutputStream(term);
		err = new PrintStream(errTerm, true);
		errTerm.setTextColor(Color.RED);
	}

	native public static void load(String nativeName);

	public static native void arraycopy(Object src,  int  srcPos, Object dest, int destPos, int length);

	// TODO
	public static java.lang.String getProperty(java.lang.String name) {
		return null;
	}
	
	 public static native long currentTimeMillis();
	 
	 public static int identityHashCode(Object x) {
		 return x.identityHashCode();
	 }

    public static char[] lineSeparator() {
        return lineSeparator;
    }
	
}