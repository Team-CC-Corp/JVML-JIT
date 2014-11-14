package cc;

public final class LuaFunction {
	static {
		System.load("cc/native/LuaFunction.lua");
	}
	private LuaFunction()
	{
	}
	public native Object[] call(Object[] args);
    public native int hashCode();
    public native boolean equals(Object other);
}
