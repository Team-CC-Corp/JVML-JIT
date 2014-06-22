package cc.redstone;

public interface IRedstone {
	boolean getInput();
	boolean getOutput();
	void setOutput(boolean on);

	int getAnalogInput();
	int getAnalogOutput();
	void setAnalogOutput(int val);
}