package cc.turtle;

import cc.Computer;

public class Turtle {
	
	static {
		System.load("cc/native/Turtle.lua");
	}
	
	private static Turtle instance;
	
	/**
	 * Returns the Turtle's singleton instance or null if the computer
	 * isn't a turtle.
	 * @return
	 */
	public static Turtle getInstance() {
		if(instance == null) {
			if(Computer.isTurtle()) {
				instance = new Turtle();
			}
		}
		return instance;
	}
	
	private Turtle() {
		
	}
	
	public native boolean forward();
	public native boolean back();
	public native boolean up();
	public native boolean down();
	
	public native boolean turnLeft();
	public native boolean turnRight();
	
	public native boolean select(int i);
	public native int getSelectedSlot();
	
	public native int getItemCount(int i);
	public int getItemCount() {
		return getItemCount(getSelectedSlot());
	}
	public native int getItemSpace(int i);
	public int getItemSpace() {
		return getItemSpace(getSelectedSlot());
	}
	
	public native ItemStack getItemDetail(int i);
	public ItemStack getItemDetail() {
		return getItemDetail(getSelectedSlot());
	}
	
	public native boolean equipLeft();
	public native boolean equipRight();
	
	public native boolean place(String signText);
	public boolean place() {
		return place("");
	}
	public native boolean placeUp();
	public native boolean placeDown();
	
	public native boolean detect();
	public native boolean detectUp();
	public native boolean detectDown();
	
	public native InspectionReport inspect();
	public native InspectionReport inspectUp();
	public native InspectionReport inspectDown();

	public native boolean compare();
	public native boolean compareUp();
	public native boolean compareDown();
	public native boolean compareTo(int slot);
	
	public native boolean drop(int count);
	public boolean drop() {
		return drop(64);
	}
	public native boolean dropUp(int count);
	public boolean dropUp() {
		return dropUp(64);
	}
	public native boolean dropDown(int count);
	public boolean dropDown() {
		return dropDown(64);
	}
	
	public native boolean suck(int amount);
	public boolean suck() {
		return suck(64);
	}
	public native boolean suckUp(int amount);
	public boolean suckUp() {
		return suckUp(64);
	}
	public native boolean suckDown(int amount);
	public boolean suckDown() {
		return suckDown(64);
	}
	
	public native boolean refuel(int quantity);
	public boolean refuel() {
		return refuel(64);
	}
	public native int getFuelLevel();
	public native int getFuelLimit();
	
	public native boolean transferTo(int slot, int quantity);
	public boolean transferTo(int slot) {
		return transferTo(slot, 64);
	}
	
	// crafty only
	public native boolean craft(int quantity);
	
	// digging, mining, felling, farming only
	public native boolean dig();
	public native boolean digUp();
	public native boolean digDown();
	
	// all tools
	public native boolean attack();
	public native boolean attackUp();
	public native boolean attackDown();
	
}
