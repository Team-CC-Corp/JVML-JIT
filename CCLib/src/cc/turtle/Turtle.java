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

	public static native boolean compare();
	public static native boolean compareUp();
	public static native boolean compareDown();
	public static native boolean compareTo(int slot);
	
	public static native boolean drop(int count);
	public static boolean drop() {
		return drop(64);
	}
	public static native boolean dropUp(int count);
	public static boolean dropUp() {
		return dropUp(64);
	}
	public static native boolean dropDown(int count);
	public static boolean dropDown() {
		return dropDown(64);
	}
	
	public static native boolean suck(int amount);
	public static boolean suck() {
		return suck(64);
	}
	public static native boolean suckUp(int amount);
	public static boolean suckUp() {
		return suckUp(64);
	}
	public static native boolean suckDown(int amount);
	public static boolean suckDown() {
		return suckDown(64);
	}
	
	public static native boolean refuel(int quantity);
	public static boolean refuel() {
		return refuel(64);
	}
	public static native int getFuelLevel();
	public static native int getFuelLimit();
	
	public static native boolean transferTo(int slot, int quantity);
	public static boolean transferTo(int slot) {
		return transferTo(slot, 64);
	}
	
	// crafty only
	public static native boolean craft(int quantity);
	
	// digging, mining, felling, farming only
	public static native boolean dig();
	public static native boolean digUp();
	public static native boolean digDown();
	
	// all tools
	public static native boolean attack();
	public static native boolean attackUp();
	public static native boolean attackDown();
	
}
