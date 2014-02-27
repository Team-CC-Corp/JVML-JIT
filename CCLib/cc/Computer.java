package cc;
public final class Computer
{
	private Computer() {}
	public static native void shutdown();
	public static native void restart();
	public static native void sleep(double s);
	public static native boolean isTurtle();
	public static native int getTime();
	
	public static String getVersion() {return null;}
	public static int getComputerID() {return 0;}
	public static String getComputerLabel() {return null;}
	public static void setComputerLabel(String label) {}
	public static Event pullEvent(String filter) {return null;}
	public static Event pullEventRaw(String filter) {return null;}
	public static void queueEvent(Event e) {}
	public static double getClock() {return 0D;}
	public static int startTimer(double s) {return 0;}
	public static int setAlarm(int t) {return 0;}
}
