package java.io;

public class PrintStream {
    public void println(char[] c) {
    	println((String)(c == null ? null : new String(c)));
    }
    public void println(Object obj) {
    	println((String)(obj == null ? null : obj.toString()));
    }
    public native void println(String str);
    public void print(char[] c) {
        print((String)(c == null ? null : new String(c)));
    }
    public void print(Object obj) {
        print((String)(obj == null ? null : obj.toString()));
    }
    public native void print(String str);
}