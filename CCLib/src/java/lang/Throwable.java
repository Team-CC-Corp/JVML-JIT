package java.lang;

import java.io.PrintStream;

public class Throwable {
    private String detailMessage;
    private Throwable cause = this;
    private StackTraceElement stackTrace[];

	public Throwable() {
		fillInStackTrace();
	}

	public Throwable(String message) {
		fillInStackTrace();
		detailMessage = message;
	}

	public Throwable(String message, Throwable cause) {
		fillInStackTrace();
		detailMessage = message;
		this.cause = cause;
	}

	public Throwable(Throwable cause) {
		fillInStackTrace();
		detailMessage = (cause==null ? null : cause.toString());
		this.cause = cause;
	}

	public String getMessage() {
        return detailMessage;
    }

    public Throwable getCause() {
        return (cause==this ? null : cause);
    }

    public String toString() {
        String s = getClass().getName();
        String message = getMessage();
        return (message != null) ? (s + ": " + message) : s;
    }

    public void printStackTrace() {
        printStackTrace(System.err);
    }

    public void printStackTrace(PrintStream out) {
    	out.println(this);
        for (int i = stackTrace.length - 1; i >= 0; --i) {
            out.println("\tat " + stackTrace[i].toString());
        }
    }

    public native Throwable fillInStackTrace();

    public StackTraceElement[] getStackTrace() {
    	StackTraceElement stackTraceCopy[] = new StackTraceElement[stackTrace.length];
    	for (int i = 0; i < stackTrace.length; ++i) {
    		stackTraceCopy[i] = stackTrace[i];
    	}
    	return stackTraceCopy;
    }
}