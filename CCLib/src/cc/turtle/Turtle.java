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
	
	public static native int getItemCount(int i);
	public static int getItemCount() {
		return getItemCount(getSelectedSlot());
	}
	public static native int getItemSpace(int i);
	public static int getItemSpace() {
		return getItemSpace(getSelectedSlot());
	}
	
	public static native ItemStack getItemDetail(int i);
	public static ItemStack getItemDetail() {
		return getItemDetail(getSelectedSlot());
	}
	
	//TODO: seems to be buggy (repeated equip/unequip)
	public static native boolean equipLeft();
	public static native boolean equipRight();
	
	public static native boolean place(String signText);
	public static boolean place() {
		return place("");
	}
	public static native boolean placeUp();
	public static native boolean placeDown();
	
	public static native boolean detect();
	public static native boolean detectUp();
	public static native boolean detectDown();
	
	public static native InspectionReport inspect();
	public static native InspectionReport inspectUp();
	public static native InspectionReport inspectDown();

}
