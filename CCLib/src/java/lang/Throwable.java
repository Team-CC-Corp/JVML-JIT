package java.lang;

import java.io.PrintStream;

import jvml.util.ArrayList;

public class Throwable {
    private static final String CAUSE_CAPTION = "Caused by: ";
    private static final String SUPPRESSED_CAPTION = "Suppressed: ";

    private String detailMessage;
    private Throwable cause = this;
    private StackTraceElement stackTrace[];
    private ArrayList<Throwable> suppressedExceptions;

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
	
	public Throwable initCause(Throwable e) {
	    if (cause == null) {
	      cause = e;
	      return this;
	    } else {
	      throw new IllegalStateException();
	    }
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

    private void printStackTrace(PrintStream s) {
        ArrayList<Throwable> dejaVu = new ArrayList<Throwable>();
        dejaVu.add(this);

        // Print our stack trace
        s.println(this);
        StackTraceElement[] trace = getStackTrace();
        for (StackTraceElement traceElement : trace)
            s.println("\tat " + traceElement);

        // Print suppressed exceptions, if any
        for (Throwable se : getSuppressed())
            se.printEnclosedStackTrace(s, trace, SUPPRESSED_CAPTION, "\t", dejaVu);

        // Print cause, if any
        Throwable ourCause = getCause();
        if (ourCause != null)
            ourCause.printEnclosedStackTrace(s, trace, CAUSE_CAPTION, "", dejaVu);
    }

    private void printEnclosedStackTrace(PrintStream s,
                                         StackTraceElement[] enclosingTrace,
                                         String caption,
                                         String prefix,
                                         ArrayList<Throwable> dejaVu) {
        if (dejaVu.contains(this)) {
            s.println("\t[CIRCULAR REFERENCE:" + this + "]");
        } else {
            dejaVu.add(this);
            // Common frames between this and enclosing trace
            StackTraceElement[] trace = getStackTrace();
            int m = trace.length - 1;
            int n = enclosingTrace.length - 1;
            while (m >= 0 && n >=0 && trace[m].equals(enclosingTrace[n])) {
                m--; n--;
            }
            int framesInCommon = trace.length - 1 - m;

            // Print stack trace
            s.println(prefix + caption + this);
            for (int i = 0; i <= m; i++)
                s.println(prefix + "\tat " + trace[i]);
            if (framesInCommon != 0)
                s.println(prefix + "\t... " + framesInCommon + " more");

            // Suppressed exceptions
            for (Throwable se : getSuppressed())
                se.printEnclosedStackTrace(s, trace, SUPPRESSED_CAPTION,
                                           prefix +"\t", dejaVu);

            // Print cause, if any
            Throwable ourCause = getCause();
            if (ourCause != null)
                ourCause.printEnclosedStackTrace(s, trace, CAUSE_CAPTION, prefix, dejaVu);
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

    public final Throwable[] getSuppressed() {
        if (suppressedExceptions == null) {
            return new Throwable[0];
        }
        Throwable[] suppressed = new Throwable[suppressedExceptions.size()];
        for (int i = 0; i < suppressedExceptions.size(); ++i) {
            suppressed[i] = suppressedExceptions.get(i);
        }
        return suppressed;
    }

    public final void addSuppressed(Throwable exception) {
        if (suppressedExceptions == null) {
            suppressedExceptions = new ArrayList<Throwable>();
        }
        suppressedExceptions.add(exception);
    }
}