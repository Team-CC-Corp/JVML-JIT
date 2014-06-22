package java.lang;

import java.io.PrintStream;

public final class System {
	public static PrintStream out = new PrintStream();

	native public static void load(String nativeName);
}