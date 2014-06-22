package cc.redstone;

public class SidedRedstone implements IRedstone {
	public final String side;

	public SidedRedstone(String side) {
		this.side = side;
	}

	native public boolean getInput();
	native public boolean getOutput();
	native public void setOutput(boolean on);

	native public int getAnalogInput();
	native public int getAnalogOutput();
	native public void setAnalogOutput(int val);

	static {
		System.load("cc/native/SidedRedstone.lua");
	}
}