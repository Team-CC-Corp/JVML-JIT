package java.lang;

import java.io.PrintStream;
import cc.terminal.SystemTerminal;

public final class System {
	public static SystemTerminal term = new SystemTerminal();

	public static PrintStream out = new PrintStream();
	public static PrintStream err = new PrintStream();

	native public static void load(String nativeName);

	public static native void arraycopy(Object src,  int  srcPos, Object dest, int destPos, int length);
}