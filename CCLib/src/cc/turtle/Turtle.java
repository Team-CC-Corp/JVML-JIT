package cc.turtle;

public class Turtle {
	
	static {
		System.load("cc/native/Turtle.lua");
	}
	
	public static native boolean forward();
	public static native boolean back();
	public static native boolean up();
	public static native boolean down();
	
	public static native boolean turnLeft();
	public static native boolean turnRight();
	
	public static native boolean select(int i);
	public static native int getSelectedSlot();

}
